import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ticket_service.dart';
import '../../models/ticket.dart';
import 'ticket_edit_screen.dart';
import 'ticket_create_screen.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketService = Provider.of<TicketService>(context, listen: false);
    ticketService.fetchTickets();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách vé'),
      ),
      body: Consumer<TicketService>(
        builder: (context, ticketService, child) {
          if (ticketService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ticketService.tickets.isEmpty) {
            return const Center(child: Text('Không có vé nào'));
          }
          return ListView.builder(
            itemCount: ticketService.tickets.length,
            itemBuilder: (context, index) {
              final ticket = ticketService.tickets[index];
              return ListTile(
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketEditScreen(ticket: ticket),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TicketCreateScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}