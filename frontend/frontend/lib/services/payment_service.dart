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

  Future<String?> createAndSavePaypalPayment({
    required String ticketId,
    required double amount,
    required String paymentMethod,
    required String paymentStatus,
  }) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) return null;

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
            "description": "Bus ticket payment",
          },
        ],
        "redirect_urls": {
          "return_url": PayPalConfig.returnUrl,
          "cancel_url": PayPalConfig.cancelUrl,
        },
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final approvalUrl =
          data['links'].firstWhere(
            (link) => link['rel'] == 'approval_url',
          )['href'];
      final executeUrl =
          data['links'].firstWhere((link) => link['rel'] == 'execute')['href'];
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
      print('Body gửi lên backend: ${jsonEncode(body)}');
      final backendResponse = await http.post(
        Uri.parse('$baseUrl/payment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (backendResponse.statusCode == 201 ||
          backendResponse.statusCode == 200) {
        print('Đã lưu thanh toán PayPal thành công vào backend.');
      } else {
        print('Lỗi khi lưu thanh toán vào backend: ${backendResponse.body}');
      }

      return approvalUrl;
    } else {
      print('Lỗi tạo thanh toán PayPal: ${response.body}');
      return null;
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

    final response = await http.post(
      Uri.parse(executeUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'payer_id': payerId}),
    );

    if (response.statusCode == 200) {
      print('Thanh toán thành công!');
      return true;
    } else {
      print(' Lỗi xác nhận thanh toán: ${response.body}');
      return false;
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
}