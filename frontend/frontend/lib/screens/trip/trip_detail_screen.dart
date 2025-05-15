import 'package:flutter/material.dart';
import 'package:frontend/models/location.dart';
import 'package:provider/provider.dart';
import '../../services/trip_service.dart';
import '../../services/seat_service.dart';
import '../../services/location_service.dart';

class TripDetailScreen extends StatelessWidget {
  final String id;

  TripDetailScreen({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết chuyến đi')),
      body: Consumer3<TripService, SeatService, LocationService>(
        builder: (context, tripService, seatService, locationService, _) {
          if (tripService.isLoading ||
              seatService.isLoading ||
              locationService.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          final trip = tripService.trips.firstWhere((t) => t.id == id);
          final location = locationService.locations.firstWhere(
            (loc) => loc.id == trip.vehicle_id,
            orElse: () => Location(id: trip.vehicle_id, location: 'Unknown', contact_phone: ''),
          );
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Địa điểm: ${location.location}'),
                Text('Điểm đi: ${trip.departure_location}'),
                Text('Điểm đến: ${trip.arrival_location}'),
                Text('Thời gian đi: ${trip.departure_time}'),
                Text('Thời gian đến: ${trip.arrival_time}'),
                Text('Giá: ${trip.price}'),
                Text('Loại xe: ${trip.distance}'),
                Text('Tổng ghế: ${trip.totalSeats}'),
                Text('Ghế ngồi', style: Theme.of(context).textTheme.titleLarge),
                Expanded(
                  child: ListView.builder(
                    itemCount: seatService.seats.length,
                    itemBuilder: (context, index) {
                      final seat = seatService.seats[index];
                      return ListTile(
                        title: Text('Ghế ${seat.seatNumber}'),
                        subtitle: Text(
                          'Trạng thái: ${seat.isAvailable ? 'Còn trống' : 'Đã đặt'}',
                        ),
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
