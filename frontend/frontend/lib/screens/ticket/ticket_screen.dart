import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ticket_service.dart';
import '../../models/ticket.dart';
import '../home/customer_nav_bar.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  Ticket? _selectedTicket;
  late String tripId;
  late String seatId;
  late String ticketStatus;

  @override
  void initState() {
    super.initState();
    final ticketService = Provider.of<TicketService>(context, listen: false);
    ticketService.fetchTickets();
  }

  Future<void> _refreshTickets() async {
    final ticketService = Provider.of<TicketService>(context, listen: false);
    await ticketService.fetchTickets();
  }

  void _startEditing(Ticket ticket) {
    setState(() {
      _isEditing = true;
      _selectedTicket = ticket;
      tripId = ticket.trip_id;
      seatId = ticket.seat_id;
      ticketStatus = ticket.ticket_status;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _selectedTicket = null;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final ticketService = Provider.of<TicketService>(context, listen: false);
      final ticketData = {
        'trip_id': tripId,
        'seat_id': seatId,
        'ticket_status': ticketStatus,
      };
      final result = await ticketService.updateTicket(_selectedTicket!.id, ticketData);
      if (result != null) {
        setState(() {
          _isEditing = false;
          _selectedTicket = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật vé thành công')),
        );
        await _refreshTickets();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật vé thất bại')),
        );
      }
    }
  }

  Future<void> _deleteTicket(String ticketId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa vé này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ticketService = Provider.of<TicketService>(context, listen: false);
      final success = await ticketService.deleteTicket(ticketId);
      if (success) {
        setState(() {
          _isEditing = false;
          _selectedTicket = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa vé thành công')),
        );
        await _refreshTickets();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa vé thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vé của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTickets,
          ),
        ],
      ),
      body: Consumer<TicketService>(
        builder: (context, ticketService, child) {
          if (ticketService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ticketService.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ticketService.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _refreshTickets,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          if (!_isEditing) {
            if (ticketService.tickets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.directions_bus,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bạn chưa có vé nào',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Hãy đặt vé để bắt đầu hành trình!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            print('Số lượng vé: ${ticketService.tickets.length}'); // Debug log
            return ListView.builder(
              itemCount: ticketService.tickets.length,
              itemBuilder: (context, index) {
                final ticket = ticketService.tickets[index];
                return ListTile(
                  leading: const Icon(Icons.confirmation_number),
                  title: Text('Vé #${index + 1} - Trạng thái: ${ticket.ticket_status}'),
                  subtitle: Text('Chuyến: ${ticket.trip_id} - Ghế: ${ticket.seat_id}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTicket(ticket.id),
                  ),
                  onTap: () => _startEditing(ticket),
                );
              },
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: tripId,
                      decoration: const InputDecoration(labelText: 'Mã chuyến (Trip ID)'),
                      onChanged: (value) => tripId = value,
                      validator: (value) => value!.isEmpty ? 'Vui lòng nhập mã chuyến' : null,
                    ),
                    TextFormField(
                      initialValue: seatId,
                      decoration: const InputDecoration(labelText: 'Mã ghế (Seat ID)'),
                      onChanged: (value) => seatId = value,
                      validator: (value) => value!.isEmpty ? 'Vui lòng nhập mã ghế' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: ticketStatus,
                      decoration: const InputDecoration(labelText: 'Trạng thái vé'),
                      items: ['BOOKED', 'CANCELLED', 'COMPLETED']
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          ticketStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _saveChanges,
                          child: const Text('Lưu thay đổi'),
                        ),
                        ElevatedButton(
                          onPressed: _cancelEditing,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          child: const Text('Hủy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/trip/search');
          } else if (index == 2) {
            // Đã ở màn hình này, không làm gì
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/auth/profile');
          }
        },
      ),
    );
  }
}