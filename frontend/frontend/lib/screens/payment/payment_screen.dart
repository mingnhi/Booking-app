import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:frontend/config/paypal_config.dart';
import 'package:frontend/services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String ticketId;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.ticketId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedMethod = 'paypal';
  InAppWebViewController? webViewController;
  late PaymentService paymentService;
  String? approvalUrl;
  String? executeUrl;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    paymentService = PaymentService();
    _initiatePayment();
    isLoading = false;
  }

  Future<void> _initiatePayment() async {
    final approval = await paymentService.createAndSavePaypalPayment(
      ticketId: widget.ticketId,
      amount: widget.amount,
      paymentMethod: 'paypal',
      paymentStatus: 'PENDING',
    );

    if (approval != null) {
      setState(() {
        approvalUrl = approval;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tạo thanh toán.')));
      Navigator.pop(context);
    }
  }

  // Future<void> _handleSuccess(String payerId) async {
  //   if (executeUrl != null) {
  //     final success = await paymentService.executePayment(executeUrl!, payerId);
  //     if (success) {
  //       final paypalId = executeUrl!.split('/').last;
  //       await paymentService.savePaymentToBackend(
  //         ticketId: widget.ticketId,
  //         amount: widget.amount,
  //         paymentMethod: 'paypal',
  //         paypalPaymentId: paypalId,
  //       );

  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Thanh toán thành công!')));
  //     } else {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Thanh toán thất bại.')));
  //     }
  //   }
  //   Navigator.pop(context);
  // }

  Future<void> _handleSuccess(String payerId) async {
    if (executeUrl != null) {
      final success = await paymentService.executePayment(executeUrl!, payerId);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Thanh toán thành công!')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Thanh toán thất bại.')));
      }
    }
    Navigator.pop(context);
  }

  Future<void> _handleCashPayment() async {
    await paymentService.createAndSavePaypalPayment(
      ticketId: widget.ticketId,
      amount: widget.amount,
      paymentMethod: 'cash',
      paymentStatus: 'PENDING',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thanh toán bằng tiền mặt đã được ghi nhận!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text('Chọn phương thức thanh toán:'),
                        Radio<String>(
                          value: 'paypal',
                          groupValue: selectedMethod,
                          onChanged: (String? value) async {
                            setState(() {
                              selectedMethod = value;
                              isLoading = true;
                            });
                            if (value == 'paypal') {
                              await _initiatePayment(); // chỉ gọi khi người dùng chọn PayPal
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                        ),
                        Text('Paypal'),
                        Radio<String>(
                          value: 'cash',
                          groupValue: selectedMethod,
                          onChanged: (String? value) {
                            setState(() {
                              selectedMethod = value;
                              isLoading = false;
                            });
                          },
                        ),
                        Text('Tiền mặt'),
                      ],
                    ),
                  ),
                  selectedMethod == 'paypal'
                      ? InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri(approvalUrl ?? ''),
                        ),
                        onLoadStop: (controller, url) {
                          final uri = Uri.parse(url.toString());
                          if (uri.toString().startsWith(
                            PayPalConfig.returnUrl,
                          )) {
                            final payerId = uri.queryParameters['PayerID'];
                            if (payerId != null) {
                              _handleSuccess(payerId);
                            }
                          } else if (uri.toString().startsWith(
                            PayPalConfig.cancelUrl,
                          )) {
                            Navigator.pop(context);
                          }
                        },
                      )
                      : ElevatedButton(
                        onPressed: _handleCashPayment,
                        child: Text('Thanh toán bằng tiền mặt'),
                      ),
                ],
              ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text('Thanh toán PayPal')),
  //     body:
  //         isLoading
  //             ? Center(child: CircularProgressIndicator())
  //             : InAppWebView(
  //               initialUrlRequest: URLRequest(url: WebUri(approvalUrl!)),
  //               onLoadStop: (controller, url) {
  //                 final uri = Uri.parse(url.toString());
  //                 if (uri.toString().startsWith(PayPalConfig.returnUrl)) {
  //                   final payerId = uri.queryParameters['PayerID'];
  //                   if (payerId != null) {
  //                     _handleSuccess(payerId);
  //                   }
  //                 } else if (uri.toString().startsWith(
  //                   PayPalConfig.cancelUrl,
  //                 )) {
  //                   Navigator.pop(context);
  //                 }
  //               },
  //             ),
  //   );
  // }
