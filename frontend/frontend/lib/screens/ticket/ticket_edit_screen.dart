import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ticket_service.dart';
import '../../models/ticket.dart';

class TicketEditScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketEditScreen({super.key, required this.ticket});

  @override
  _TicketEditScreenState createState() => _TicketEditScreenState();
}

class _TicketEditScreenState extends State<TicketEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String tripId;
  late String seatId;
  late String ticketStatus;

  @override
  void initState() {
    super.initState();
    tripId = widget.ticket.trip_id;
    seatId = widget.ticket.seat_id;
    ticketStatus = widget.ticket.ticket_status;
  }

  @override
  Widget build(BuildContext context) {
    final ticketService = Provider.of<TicketService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa vé'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: tripId,
                decoration: const InputDecoration(labelText: 'Trip ID'),
                onChanged: (value) => tripId = value,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập Trip ID' : null,
              ),
              TextFormField(
                initialValue: seatId,
                decoration: const InputDecoration(labelText: 'Seat ID'),
                onChanged: (value) => seatId = value,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập Seat ID' : null,
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
                    final result = await ticketService.updateTicket(widget.ticket.id, ticketData);
                    if (result != null) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cập nhật vé thất bại')),
                      );
                    }
                  }
                },
                child: const Text('Cập nhật vé'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}