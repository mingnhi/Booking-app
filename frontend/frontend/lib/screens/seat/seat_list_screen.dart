import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/seat_service.dart';

class SeatListScreen extends StatelessWidget {
  const SeatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách ghế')),
      body: Consumer<SeatService>(
        builder: (context, seatService, _) {
          if (seatService.isLoading) return Center(child: CircularProgressIndicator());
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: seatService.seats.length,
            itemBuilder: (context, index) {
              final seat = seatService.seats[index];
              return ListTile(
                title: Text('Ghế ${seat.seatNumber}'),
                subtitle: Text('Trạng thái: ${seat.isAvailable ? 'Còn trống' : 'Đã đặt'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => Navigator.pushNamed(context, '/seat/edit/${seat.id}'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await seatService.deleteSeat(seat.id);
                        seatService.fetchSeats();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/seat/create'),
        child: Icon(Icons.add),
      ),
    );
  }
}