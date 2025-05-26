import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:frontend/config/paypal_config.dart';
import 'package:frontend/services/payment_service.dart';
import 'package:frontend/services/ticket_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    paymentService = PaymentService();
    _initiatePayment();
  }

  Future<void> _initiatePayment() async {
    setState(() {
      isLoading = true;
    });

    try {
      final paymentData = await paymentService.createAndSavePaypalPayment(
        ticketId: widget.ticketId,
        amount: widget.amount,
        paymentMethod: 'paypal',
        paymentStatus: 'PENDING',
      );

      if (paymentData != null) {
        print('Payment data received: $paymentData');
        print('Approval URL: ${paymentData['approvalUrl']}');
        print('Execute URL: ${paymentData['executeUrl']}');

        setState(() {
          approvalUrl = paymentData['approvalUrl'];
          executeUrl = paymentData['executeUrl'];
          isLoading = false;
        });

        print('WebView will be loaded with approval URL');
      } else {
        _showSnackBar('Không thể tạo thanh toán. Vui lòng thử lại.');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Lỗi khi khởi tạo thanh toán: $e');
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  Future<void> _handleSuccess(String payerId) async {
    if (executeUrl != null) {
      try {
        print('Executing payment with payerId: $payerId');
        final success = await paymentService.executePayment(
          executeUrl!,
          payerId,
        );

        if (success) {
          // Cập nhật trạng thái vé thành PAID
          final ticketService = Provider.of<TicketService>(
            context,
            listen: false,
          );
          await ticketService.updateTicket(widget.ticketId, {
            'ticket_status': 'PAID',
          });

          _showSnackBar('Thanh toán thành công!');
        } else {
          _showSnackBar('Thanh toán thất bại. Vui lòng thử lại.');
        }
      } catch (e) {
        print('Error executing payment: $e');
        _showSnackBar('Lỗi khi thực hiện thanh toán: $e');
      }
    } else {
      _showSnackBar('Không tìm thấy URL thực thi thanh toán.');
    }
  }

  Future<void> _handleCashPayment() async {
    try {
      await paymentService.createAndSavePaypalPayment(
        ticketId: widget.ticketId,
        amount: widget.amount,
        paymentMethod: 'cash',
        paymentStatus: 'PENDING',
      );
      _showSnackBar('Thanh toán bằng tiền mặt đã được ghi nhận!');
    } catch (e) {
      _showSnackBar('Lỗi khi ghi nhận thanh toán bằng tiền mặt: $e');
    }
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán', style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Chọn phương thức thanh toán:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'paypal',
                          groupValue: selectedMethod,
                          onChanged: (String? value) async {
                            setState(() {
                              selectedMethod = value;
                              isLoading = true;
                            });
                            if (value == 'paypal') {
                              await _initiatePayment();
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                        ),
                        const Text('Paypal'),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'cash',
                          groupValue: selectedMethod,
                          onChanged: (String? value) {
                            setState(() {
                              selectedMethod = value;
                              approvalUrl = null;
                              isLoading = false;
                            });
                          },
                        ),
                        const Text('Tiền mặt'),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        selectedMethod == 'paypal'
                            ? approvalUrl != null
                                ? Column(
                                  children: [
                                    // Thêm nút để mở URL trong trình duyệt bên ngoài nếu WebView không hoạt động
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final uri = Uri.parse(approvalUrl!);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(
                                              uri,
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
                                            );
                                            _showSnackBar(
                                              'Đang mở PayPal trong trình duyệt...',
                                            );
                                          } else {
                                            _showSnackBar(
                                              'Không thể mở URL PayPal',
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Mở trong trình duyệt nếu WebView không hoạt động',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InAppWebView(
                                        initialUrlRequest: URLRequest(
                                          url: WebUri(approvalUrl!),
                                          headers: {
                                            'Accept':
                                                'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                                            'Accept-Language': 'en-US,en;q=0.5',
                                          },
                                        ),
                                        initialOptions: InAppWebViewGroupOptions(
                                          crossPlatform: InAppWebViewOptions(
                                            useShouldOverrideUrlLoading: true,
                                            mediaPlaybackRequiresUserGesture:
                                                false,
                                            javaScriptEnabled: true,
                                            javaScriptCanOpenWindowsAutomatically:
                                                true,
                                            clearCache: true,
                                          ),
                                        ),
                                        onWebViewCreated: (controller) {
                                          webViewController = controller;
                                          print(
                                            'WebView created with controller: $controller',
                                          );

                                          // Thêm log để kiểm tra URL hiện tại
                                          controller.getUrl().then((url) {
                                            print(
                                              'Initial WebView URL: ${url?.toString()}',
                                            );
                                          });
                                        },
                                        onLoadStart: (controller, url) {
                                          final urlString = url.toString();
                                          print(
                                            'WebView loading URL: $urlString',
                                          );

                                          // Thêm log để kiểm tra trạng thái WebView
                                          controller.getProgress().then((
                                            progress,
                                          ) {
                                            print(
                                              'Current WebView progress: $progress',
                                            );
                                          });
                                        },
                                        shouldOverrideUrlLoading: (
                                          controller,
                                          navigationAction,
                                        ) async {
                                          final urlString =
                                              navigationAction.request.url
                                                  .toString();
                                          print(
                                            'Should override URL loading: $urlString',
                                          );

                                          // Kiểm tra chi tiết hơn về request
                                          print(
                                            'Navigation type: ${navigationAction.navigationType}',
                                          );
                                          print(
                                            'Request headers: ${navigationAction.request.headers}',
                                          );

                                          // Tập trung logic xử lý URL redirect vào đây
                                          if (urlString.contains(
                                            '/payment/success',
                                          )) {
                                            print(
                                              'Payment success URL detected: $urlString',
                                            );
                                            final uri = Uri.parse(urlString);
                                            final payerId =
                                                uri.queryParameters['PayerID'];
                                            final paymentId =
                                                uri.queryParameters['paymentId'];

                                            print(
                                              'PayerID: $payerId, PaymentID: $paymentId',
                                            );

                                            if (payerId != null) {
                                              // Hiển thị thông báo đang xử lý
                                              _showSnackBar(
                                                'Đang xử lý thanh toán...',
                                              );

                                              try {
                                                // Xử lý thanh toán
                                                print(
                                                  'Executing payment with payerId: $payerId',
                                                );
                                                final success =
                                                    await paymentService
                                                        .executePayment(
                                                          executeUrl!,
                                                          payerId,
                                                        );

                                                if (success) {
                                                  print(
                                                    'Payment execution successful',
                                                  );
                                                  // Cập nhật trạng thái vé thành PAID
                                                  final ticketService =
                                                      Provider.of<
                                                        TicketService
                                                      >(context, listen: false);
                                                  await ticketService
                                                      .updateTicket(
                                                        widget.ticketId,
                                                        {
                                                          'ticket_status':
                                                              'PAID',
                                                        },
                                                      );

                                                  _showSnackBar(
                                                    'Thanh toán thành công!',
                                                  );

                                                  // Đợi 1 giây trước khi quay lại để người dùng thấy thông báo
                                                  await Future.delayed(
                                                    const Duration(seconds: 1),
                                                  );

                                                  // Quay lại màn hình trước với kết quả thành công
                                                  if (mounted) {
                                                    print(
                                                      'Navigating back with result: true',
                                                    );
                                                    Navigator.pop(
                                                      context,
                                                      true,
                                                    );
                                                  }
                                                } else {
                                                  print(
                                                    'Payment execution failed',
                                                  );
                                                  _showSnackBar(
                                                    'Thanh toán thất bại. Vui lòng thử lại.',
                                                  );
                                                }
                                              } catch (e) {
                                                print(
                                                  'Error executing payment: $e',
                                                );
                                                _showSnackBar(
                                                  'Lỗi khi thực hiện thanh toán: $e',
                                                );
                                              }

                                              // Luôn hủy việc tải URL redirect để tránh chuyển hướng
                                              return NavigationActionPolicy
                                                  .CANCEL;
                                            }
                                          } else if (urlString.contains(
                                            '/payment/cancel',
                                          )) {
                                            print('Payment cancelled by user');
                                            _showSnackBar(
                                              'Thanh toán đã bị hủy',
                                            );

                                            // Quay lại màn hình trước với kết quả thất bại
                                            if (mounted) {
                                              Navigator.pop(context, false);
                                            }

                                            return NavigationActionPolicy
                                                .CANCEL;
                                          }

                                          // Cho phép tải các URL khác
                                          return NavigationActionPolicy.ALLOW;
                                        },
                                        onLoadStop: (controller, url) {
                                          print(
                                            'WebView finished loading: ${url.toString()}',
                                          );

                                          // Kiểm tra nếu URL chứa PayPal và đã hoàn tất tải
                                          if (url.toString().contains(
                                            'paypal.com',
                                          )) {
                                            print(
                                              'PayPal page loaded successfully',
                                            );

                                            // Thêm JavaScript để theo dõi chuyển hướng
                                            controller
                                                .evaluateJavascript(
                                                  source: '''
                                          console.log('JavaScript injection successful');
                                          // Theo dõi khi form được submit
                                          document.addEventListener('submit', function(e) {
                                            console.log('Form submitted');
                                          });
                                        ''',
                                                )
                                                .then(
                                                  (value) => print(
                                                    'JavaScript evaluation result: $value',
                                                  ),
                                                )
                                                .catchError(
                                                  (error) => print(
                                                    'JavaScript evaluation error: $error',
                                                  ),
                                                );
                                          }
                                        },
                                        onProgressChanged: (
                                          controller,
                                          progress,
                                        ) {
                                          print(
                                            'WebView loading progress: $progress%',
                                          );
                                        },
                                        onReceivedError: (
                                          controller,
                                          request,
                                          error,
                                        ) {
                                          print(
                                            'WebView error: ${error.description} (${error.type})',
                                          );
                                          print('Error URL: ${request.url}');

                                          // Xử lý lỗi WebView
                                          if (error.type ==
                                                  WebResourceErrorType
                                                      .TIMEOUT ||
                                              error.type ==
                                                  WebResourceErrorType
                                                      .FAILED_SSL_HANDSHAKE ||
                                              error.type ==
                                                  WebResourceErrorType
                                                      .HOST_LOOKUP) {
                                            _showSnackBar(
                                              'Lỗi kết nối: ${error.description}. Vui lòng thử lại sau.',
                                            );
                                          }
                                        },
                                        onConsoleMessage: (
                                          controller,
                                          consoleMessage,
                                        ) {
                                          print(
                                            'WebView console: ${consoleMessage.message}',
                                          );
                                        },
                                      ),
                                    ),
                                    // Thêm nút kiểm tra trạng thái thanh toán
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            final payment = await paymentService
                                                .getPaymentByTicketId(
                                                  widget.ticketId,
                                                );
                                            if (payment != null) {
                                              _showSnackBar(
                                                'Trạng thái thanh toán: ${payment.paymentStatus}',
                                              );

                                              if (payment.paymentStatus ==
                                                  'COMPLETED') {
                                                // Cập nhật trạng thái vé thành PAID
                                                final ticketService =
                                                    Provider.of<TicketService>(
                                                      context,
                                                      listen: false,
                                                    );
                                                await ticketService
                                                    .updateTicket(
                                                      widget.ticketId,
                                                      {'ticket_status': 'PAID'},
                                                    );

                                                // Quay lại màn hình trước với kết quả thành công
                                                if (mounted) {
                                                  Navigator.pop(context, true);
                                                }
                                              }
                                            } else {
                                              _showSnackBar(
                                                'Không tìm thấy thông tin thanh toán',
                                              );
                                            }
                                          } catch (e) {
                                            _showSnackBar(
                                              'Lỗi khi kiểm tra trạng thái thanh toán: $e',
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Kiểm tra trạng thái thanh toán',
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : const Center(
                                  child: Text(
                                    'Không thể tải trang thanh toán PayPal.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                            : Center(
                              child: ElevatedButton(
                                onPressed: _handleCashPayment,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text(
                                  'Xác nhận thanh toán bằng tiền mặt',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                  ),
                ],
              ),
    );
  }
}
