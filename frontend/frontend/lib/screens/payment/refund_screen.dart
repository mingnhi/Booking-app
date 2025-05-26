import 'package:flutter/material.dart';
import 'package:frontend/models/payment.dart';
import 'package:frontend/models/ticket.dart';
import 'package:frontend/services/payment_service.dart';
import 'package:frontend/services/ticket_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RefundScreen extends StatefulWidget {
  final String ticketId;
  final double amount;

  const RefundScreen({
    Key? key,
    required this.ticketId,
    required this.amount,
  }) : super(key: key);

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  bool _isLoading = true;
  Payment? _payment;
  String? _errorMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final payment = await paymentService.getPaymentByTicketId(widget.ticketId);

      if (payment == null) {
        setState(() {
          _errorMessage = 'Không tìm thấy thông tin thanh toán cho vé này';
          _isLoading = false;
        });
        return;
      }

      if (payment.paymentMethod != 'paypal') {
        setState(() {
          _errorMessage = 'Vé này không được thanh toán bằng PayPal';
          _isLoading = false;
        });
        return;
      }

      if (payment.paymentStatus == 'REFUNDED') {
        setState(() {
          _errorMessage = 'Vé này đã được hoàn tiền trước đó';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _payment = payment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải thông tin thanh toán: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _processRefund() async {
    if (_payment == null || _payment!.paypalPaymentId == null) {
      _showSnackBar('Không có thông tin thanh toán PayPal');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final ticketService = Provider.of<TicketService>(context, listen: false);
      
      final success = await paymentService.refundPaypalPayment(
        paymentId: _payment!.id!,
        paypalPaymentId: _payment!.paypalPaymentId!,
        amount: widget.amount,
      );

      if (success) {
        // Cập nhật trạng thái vé thành CANCELLED
        await ticketService.updateTicket(
          widget.ticketId, 
          {'ticket_status': 'CANCELLED'}
        );
        
        if (mounted) {
          _showSnackBar('Hoàn tiền thành công!');
          // Đợi 2 giây trước khi quay lại màn hình trước
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context, true);
        }
      } else {
        _showSnackBar('Hoàn tiền thất bại. Vui lòng thử lại sau.');
      }
    } catch (e) {
      _showSnackBar('Lỗi khi xử lý hoàn tiền: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
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
        title: Text(
          'Hoàn tiền vé',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2474E5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2474E5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Quay lại',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thông tin hoàn tiền',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2474E5),
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 8),
                              _buildInfoRow('Mã vé:', widget.ticketId),
                              _buildInfoRow('Phương thức thanh toán:', 'PayPal'),
                              _buildInfoRow(
                                'Số tiền hoàn trả:',
                                '${widget.amount.toStringAsFixed(2)} USD',
                              ),
                              _buildInfoRow(
                                'Trạng thái thanh toán:',
                                _payment?.paymentStatus ?? 'UNKNOWN',
                              ),
                              _buildInfoRow(
                                'Ngày thanh toán:',
                                _payment?.paymentDate != null
                                    ? '${_payment!.paymentDate!.day}/${_payment!.paymentDate!.month}/${_payment!.paymentDate!.year}'
                                    : 'N/A',
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Lưu ý:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '- Số tiền sẽ được hoàn trả vào tài khoản PayPal của bạn',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              Text(
                                '- Thời gian hoàn tiền có thể mất từ 3-5 ngày làm việc',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              Text(
                                '- Vé sẽ bị hủy sau khi hoàn tiền thành công',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _processRefund,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2474E5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Xác nhận hoàn tiền',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Hủy',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}