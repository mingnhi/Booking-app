import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ticket_service.dart';
import '../home/customer_nav_bar.dart';


class TicketCreateScreen extends StatefulWidget {
  const TicketCreateScreen({super.key});

  @override
  _TicketCreateScreenState createState() => _TicketCreateScreenState();
}

class _TicketCreateScreenState extends State<TicketCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String tripId = '';
  String seatId = '';
  String ticketStatus = 'BOOKED';

  @override
  Widget build(BuildContext context) {
    final ticketService = Provider.of<TicketService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo vé mới'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mã chuyến (Trip ID)'),
                onChanged: (value) => tripId = value,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập mã chuyến' : null,
              ),
              TextFormField(
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
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final ticketData = {
                      'trip_id': tripId,
                      'seat_id': seatId,
                      'ticket_status': ticketStatus,
                    };
                    final result = await ticketService.createTicket(ticketData);
                    if (result != null) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tạo vé thất bại')),
                      );
                    }
                  }
                },
                child: const Text('Tạo vé'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 2, // Đảm bảo index là 2
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/trip/search');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/tickets');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/auth/profile');
          }
        },
      ),
    );
  }
}