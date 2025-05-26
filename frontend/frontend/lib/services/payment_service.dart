import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/config/paypal_config.dart';
import 'package:frontend/models/payment.dart';
import 'package:http/http.dart' as http;
// import '../models/payment_model.dart';

class PaymentService extends ChangeNotifier {
  final String baseUrl = "https://booking-app-1-bzfs.onrender.com"; // replace!
  final _storage = FlutterSecureStorage();
  bool isLoading = false;

  Future<String?> _getAccessToken() async {
    final auth = base64Encode(
      utf8.encode('${PayPalConfig.clientId}:${PayPalConfig.secret}'),
    );
    final response = await http.post(
      Uri.parse('${PayPalConfig.baseUrl}/v1/oauth2/token'),
      headers: {
        'Authorization': 'Basic $auth',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'];
    } else {
      print('Lỗi lấy token: ${response.body}');
      return null;
    }
  }

  Future<Map<String, String>?> createAndSavePaypalPayment({
    required String ticketId,
    required double amount,
    required String paymentMethod,
    required String paymentStatus,
  }) async {
    isLoading = true;
    notifyListeners();
    
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) return null;

      print('Creating PayPal payment for ticket: $ticketId, amount: $amount');
      
      // Bước 1: Tạo payment trên PayPal
      final response = await http.post(
        Uri.parse('${PayPalConfig.baseUrl}/v1/payments/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "intent": "sale",
          "payer": {"payment_method": "paypal"},
          "transactions": [
            {
              "amount": {"total": amount.toStringAsFixed(2), "currency": "USD"},
              "description": "Bus ticket payment for ticket ID: $ticketId",
            },
          ],
          "redirect_urls": {
            "return_url": PayPalConfig.returnUrl,
            "cancel_url": PayPalConfig.cancelUrl,
          },
        }),
      );

      print('PayPal create payment response status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('PayPal payment created with ID: ${data['id']}');
        
        final approvalUrl = data['links'].firstWhere(
          (link) => link['rel'] == 'approval_url',
        )['href'];
        
        final executeUrl = data['links'].firstWhere(
          (link) => link['rel'] == 'execute',
        )['href'];
        
        final paypalPaymentId = data['id']; // ID của giao dịch PayPal

        // Bước 2: Gửi dữ liệu về backend
        final token = await _storage.read(key: 'accessToken');
        if (token == null) {
          print('Không tìm thấy token');
          return null;
        }

        final body = {
          'ticket_id': ticketId,
          'amount': amount,
          'payment_method': paymentMethod,
          'payment_status': paymentStatus,
          'paypal_payment_id': paypalPaymentId,
        };
        
        print('Sending payment data to backend: ${jsonEncode(body)}');
        
        final backendResponse = await http.post(
          Uri.parse('$baseUrl/payment'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );

        print('Backend payment creation response: ${backendResponse.statusCode}');
        
        if (backendResponse.statusCode == 201 || backendResponse.statusCode == 200) {
          print('Payment saved to backend successfully');
          return {'approvalUrl': approvalUrl, 'executeUrl': executeUrl};
        } else {
          print('Error saving payment to backend: ${backendResponse.body}');
          return null;
        }
      } else {
        print('Error creating PayPal payment: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in createAndSavePaypalPayment: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<Map<String, String>?> createPaypalPayment(double amount) async {
  //   final accessToken = await _getAccessToken();
  //   if (accessToken == null) return null;

  //   final response = await http.post(
  //     Uri.parse('${PayPalConfig.baseUrl}/v1/payments/payment'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $accessToken',
  //     },
  //     body: jsonEncode({
  //       "intent": "sale",
  //       "payer": {"payment_method": "paypal"},
  //       "transactions": [
  //         {
  //           "amount": {"total": amount.toStringAsFixed(2), "currency": "USD"},
  //           "description": "Bus ticket payment",
  //         },
  //       ],
  //       "redirect_urls": {
  //         "return_url": PayPalConfig.returnUrl,
  //         "cancel_url": PayPalConfig.cancelUrl,
  //       },
  //     }),
  //   );

  //   if (response.statusCode == 201) {
  //     final data = jsonDecode(response.body);
  //     final approvalUrl =
  //         data['links'].firstWhere(
  //           (link) => link['rel'] == 'approval_url',
  //         )['href'];
  //     final executeUrl =
  //         data['links'].firstWhere((link) => link['rel'] == 'execute')['href'];
  //     return {'approvalUrl': approvalUrl, 'executeUrl': executeUrl};
  //   } else {
  //     print('Lỗi tạo thanh toán: ${response.body}');
  //     return null;
  //   }
  // }

  Future<bool> executePayment(String executeUrl, String payerId) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) return false;

    try {
      print('Executing payment with URL: $executeUrl');
      print('Payer ID: $payerId');
      
      final response = await http.post(
        Uri.parse(executeUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'payer_id': payerId}),
      );

      print('Execute payment response status: ${response.statusCode}');
      print('Execute payment response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Lấy saleId từ response
        String? saleId;
        if (data['transactions'] != null && 
            data['transactions'].isNotEmpty && 
            data['transactions'][0]['related_resources'] != null && 
            data['transactions'][0]['related_resources'].isNotEmpty && 
            data['transactions'][0]['related_resources'][0]['sale'] != null) {
          saleId = data['transactions'][0]['related_resources'][0]['sale']['id'];
          print('Sale ID: $saleId');
        } else {
          print('Không tìm thấy Sale ID trong response');
        }
        
        // Cập nhật trạng thái thanh toán
        await _updatePaymentAfterExecution(data['id'], saleId);
        
        return true;
      } else {
        print('Lỗi xác nhận thanh toán: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception khi thực hiện thanh toán: $e');
      return false;
    }
  }

  // Thêm phương thức mới để cập nhật thông tin thanh toán sau khi execute
  Future<void> _updatePaymentAfterExecution(String paypalPaymentId, String? saleId) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      print('Không tìm thấy token');
      return;
    }

    try {
      // Tìm payment với paypal_payment_id
      final response = await http.get(
        Uri.parse('$baseUrl/payment/paypal/$paypalPaymentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final payment = Payment.fromJson(jsonDecode(response.body));
        
        // Cập nhật trạng thái và saleId
        final updateData = {
          'payment_status': 'COMPLETED',
        };
        
        if (saleId != null) {
          updateData['sale_id'] = saleId;
        }
        
        final updateResponse = await http.put(
          Uri.parse('$baseUrl/payment/${payment.id}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(updateData),
        );
        
        if (updateResponse.statusCode == 200) {
          print('Đã cập nhật trạng thái thanh toán thành COMPLETED');
        } else {
          print('Lỗi khi cập nhật trạng thái thanh toán: ${updateResponse.body}');
        }
      } else {
        print('Không tìm thấy payment với paypal_payment_id: $paypalPaymentId');
      }
    } catch (e) {
      print('Lỗi khi cập nhật payment sau khi execute: $e');
    }
  }

  // Future<void> savePaymentToBackend({
  //   required String ticketId,
  //   required double amount,
  //   required String paymentMethod,
  //   String? paypalPaymentId,
  // }) async {
  //   final token = await _storage.read(key: 'accessToken');
  //   print("Token gửi lên: $token");
  //   if (token == null) {
  //     print('Không tìm thấy token');
  //     return;
  //   }

  //   final body = {
  //     'ticket_id': ticketId,
  //     'amount': amount,
  //     'payment_method': paymentMethod,
  //     'payment_status': paymentMethod == 'paypal' ? 'COMPLETED' : 'PENDING',
  //   };

  //   if (paymentMethod == 'paypal' && paypalPaymentId != null) {
  //     body['paypal_payment_id'] = paypalPaymentId;
  //   }
  //   print('Dữ liệu gửi lên backend: ${jsonEncode(body)}');

  //   final response = await http.post(
  //     Uri.parse('$baseUrl/payment'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(body),
  //   );

  //   print('Mã phản hồi: ${response.statusCode}');
  //   print('Phản hồi từ backend: ${response.body}');

  //   if (response.statusCode != 201 && response.statusCode != 200) {
  //     print(' Gửi về backend thất bại: ${response.body}');
  //   } else {
  //     print(' Gửi payment thành công về backend');
  //   }
  // }

  Future<bool> refundPaypalPayment({
    required String paymentId,
    required String paypalPaymentId,
    required double amount,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) return false;

      // Bước 1: Tạo hoàn tiền trên PayPal
      final response = await http.post(
        Uri.parse(
          '${PayPalConfig.baseUrl}/v1/payments/sale/$paypalPaymentId/refund',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "amount": {"total": amount.toStringAsFixed(2), "currency": "USD"},
          "description": "Refund for bus ticket",
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final refundId = data['id']; // ID của giao dịch hoàn tiền PayPal

        // Bước 2: Cập nhật trạng thái thanh toán trong backend
        final token = await _storage.read(key: 'accessToken');
        if (token == null) {
          print('Không tìm thấy token');
          return false;
        }

        final updateResponse = await http.put(
          Uri.parse('$baseUrl/payment/$paymentId/refund'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'payment_status': 'REFUNDED',
            'refund_id': refundId,
          }),
        );

        if (updateResponse.statusCode == 200) {
          print('Đã cập nhật trạng thái thanh toán thành REFUNDED');
          return true;
        } else {
          print(
            'Lỗi khi cập nhật trạng thái thanh toán: ${updateResponse.body}',
          );
          return false;
        }
      } else {
        print('Lỗi hoàn tiền PayPal: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi trong quá trình hoàn tiền: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Thêm phương thức để lấy thông tin thanh toán theo ticket_id
  Future<Payment?> getPaymentByTicketId(String ticketId) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      print('Không tìm thấy token');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment/ticket/$ticketId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data);
      } else {
        print('Lỗi khi lấy thông tin thanh toán: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy thông tin thanh toán: $e');
      return null;
    }
  }
}
