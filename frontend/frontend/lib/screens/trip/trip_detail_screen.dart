import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/trip_service.dart';
import '../../services/seat_service.dart';

class TripDetailScreen extends StatelessWidget {
  final String id;

  TripDetailScreen({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết chuyến đi')),
      body: Consumer2<TripService, SeatService>(
        builder: (context, tripService, seatService, _) {
          if (tripService.isLoading || seatService.isLoading) return Center(child: CircularProgressIndicator());
          final trip = tripService.trips.firstWhere((t) => t.id == id);
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Điểm đi: ${trip.departureLocation}'),
                Text('Điểm đến: ${trip.arrivalLocation}'),
                Text('Thời gian đi: ${trip.departureTime}'),
                Text('Thời gian đến: ${trip.arrivalTime}'),
                Text('Giá: ${trip.price}'),
                Text('Loại xe: ${trip.busType}'),
                Text('Tổng ghế: ${trip.totalSeats}'),
                Text('Ghế ngồi', style: Theme.of(context).textTheme.titleLarge),
                Expanded(
                  child: ListView.builder(
                    itemCount: seatService.seats.length,
                    itemBuilder: (context, index) {
                      final seat = seatService.seats[index];
                      return ListTile(
                        title: Text('Ghế ${seat.seatNumber}'),
                        subtitle: Text('Trạng thái: ${seat.isAvailable ? 'Còn trống' : 'Đã đặt'}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}