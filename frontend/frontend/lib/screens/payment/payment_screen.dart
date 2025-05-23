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
  }

  Future<void> _initiatePayment() async {
    setState(() {
      isLoading = true;
    });

    try {
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
        final success = await paymentService.executePayment(executeUrl!, payerId);
        if (success) {
          _showSnackBar('Thanh toán thành công!');
        } else {
          _showSnackBar('Thanh toán thất bại. Vui lòng thử lại.');
        }
      } catch (e) {
        _showSnackBar('Lỗi khi thực hiện thanh toán: $e');
      }
    } else {
      _showSnackBar('Không tìm thấy URL thực thi thanh toán.');
    }
    Navigator.pop(context);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        centerTitle: true,
      ),
      body: isLoading
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
                      approvalUrl = null; // Reset approvalUrl khi chọn tiền mặt
                      isLoading = false;
                    });
                  },
                ),
                const Text('Tiền mặt'),
              ],
            ),
          ),
          Expanded(
            child: selectedMethod == 'paypal'
                ? approvalUrl != null
                ? InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(approvalUrl!),
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStop: (controller, url) async {
                if (url == null) return;
                final uri = Uri.parse(url.toString());
                if (uri.toString().startsWith(PayPalConfig.returnUrl)) {
                  final payerId = uri.queryParameters['PayerID'];
                  if (payerId != null) {
                    await _handleSuccess(payerId);
                  }
                } else if (uri.toString().startsWith(PayPalConfig.cancelUrl)) {
                  _showSnackBar('Thanh toán đã bị hủy.');
                  Navigator.pop(context);
                }
              },
              onLoadError: (controller, url, code, message) {
                _showSnackBar('Lỗi tải trang thanh toán: $message');
                setState(() {
                  isLoading = false;
                });
              },
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