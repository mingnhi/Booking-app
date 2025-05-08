import 'package:flutter/material.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TicketManagementScreen extends StatefulWidget {
  const TicketManagementScreen({Key? key}) : super(key: key);

  @override
  _TicketManagementScreenState createState() => _TicketManagementScreenState();
}

class _TicketManagementScreenState extends State<TicketManagementScreen> {
  List<dynamic> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final adminService = Provider.of<AdminService>(context, listen: false);
    final fetchedTickets = await adminService.getTickets();
    setState(() {
      tickets = fetchedTickets;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
          ? _buildEmptyState()
          : _buildTicketList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có vé nào',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vé sẽ được tạo khi người dùng đặt chỗ',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList() {
    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.builder(
        itemCount: tickets.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          final purchaseDate = DateTime.parse(ticket['booked_at']);
          final formatter = DateFormat('dd/MM/yyyy HH:mm');

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Vé #${ticket['_id'].substring(0, 8).toUpperCase()}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ticket['ticket_status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(ticket['ticket_status']),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          _showTicketDetails(context, ticket);
                        },
                        icon: const Icon(Icons.visibility),
                        label: Text('Chi tiết', style: GoogleFonts.poppins()),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showUpdateStatusDialog(context, ticket);
                        },
                        icon: const Icon(Icons.edit),
                        label: Text('Cập nhật', style: GoogleFonts.poppins()),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          _showDeleteConfirmation(context, ticket['_id']);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        label: Text('Xóa', style: GoogleFonts.poppins()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Đã xác nhận';
      case 'pending':
        return 'Đang chờ';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  void _showTicketDetails(BuildContext context, dynamic ticket) {
    final purchaseDate = DateTime.parse(ticket['purchaseDate']);
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(
          'Chi tiết vé',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', ticket['_id']),
              _buildDetailRow(
                'Trạng thái',
                _getStatusText(ticket['status']),
              ),
              _buildDetailRow(
                'Người dùng',
                ticket['user'] != null
                    ? ticket['user']['username'] ?? ticket['userId']
                    : ticket['userId'],
              ),
              _buildDetailRow(
                'Chuyến đi',
                ticket['trip'] != null
                    ? "${ticket['trip']['departureLocation']} → ${ticket['trip']['arrivalLocation']}"
                    : ticket['tripId'],
              ),
              _buildDetailRow(
                'Ghế',
                ticket['seat'] != null
                    ? ticket['seat']['seatNumber']
                    : ticket['seatId'],
              ),
              _buildDetailRow('Ngày mua', formatter.format(purchaseDate)),
              _buildDetailRow(
                'Giá',
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: 'đ',
                ).format(ticket['price']),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, dynamic ticket) {
    String selectedStatus = ticket['status'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(
          'Cập nhật trạng thái vé',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('Đã xác nhận', style: GoogleFonts.poppins()),
              value: 'confirmed',
              groupValue: selectedStatus,
              onChanged: (value) {
                selectedStatus = value!;
                Navigator.pop(context);
                _showUpdateStatusDialog(context, {
                  ...ticket,
                  'status': selectedStatus,
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Đang chờ', style: GoogleFonts.poppins()),
              value: 'pending',
              groupValue: selectedStatus,
              onChanged: (value) {
                selectedStatus = value!;
                Navigator.pop(context);
                _showUpdateStatusDialog(context, {
                  ...ticket,
                  'status': selectedStatus,
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Đã hủy', style: GoogleFonts.poppins()),
              value: 'cancelled',
              groupValue: selectedStatus,
              onChanged: (value) {
                selectedStatus = value!;
                Navigator.pop(context);
                _showUpdateStatusDialog(context, {
                  ...ticket,
                  'status': selectedStatus,
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              _updateTicketStatus(ticket['_id'], selectedStatus);
              Navigator.pop(context);
            },
            child: Text('Cập nhật', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTicketStatus(String ticketId, String status) async {
    final adminService = Provider.of<AdminService>(context, listen: false);

    try {
      await adminService.updateTicketStatus(ticketId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái vé thành công')),
      );
      _loadTickets(); // Reload tickets after update
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  void _showDeleteConfirmation(BuildContext context, String ticketId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(
          'Xác nhận xóa',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa vé này không? Hành động này không thể hoàn tác.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteTicket(ticketId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Xóa', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTicket(String ticketId) async {
    final adminService = Provider.of<AdminService>(context, listen: false);

    try {
      await adminService.deleteTicket(ticketId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xóa vé thành công')));
      _loadTickets(); // Reload tickets after deletion
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }
}