import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ticket_service.dart';
import '../../models/ticket.dart';
import '../home/customer_nav_bar.dart';
import 'ticket_edit_screen.dart';


class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketService = Provider.of<TicketService>(context, listen: false);
    ticketService.fetchTickets();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vé của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ticketService.fetchTickets(),
          ),
        ],
      ),
      body: Consumer<TicketService>(
        builder: (context, ticketService, child) {
          if (ticketService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ticketService.tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_bus,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bạn chưa có hành lý',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Hãy kiểm tra chuyến đặt trước\ntrong 3 tháng gần nhất',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
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
                  onPressed: () async {
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
                      await ticketService.deleteTicket(ticket.id);
                    }
                  },
                ),
                // onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => TicketEditScreen(ticket: ticket),
                //     ),
                //   );
                // },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 2, // Đảm bảo index là 2
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