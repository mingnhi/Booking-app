import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/trip_service.dart';

class TripListScreen extends StatelessWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách chuyến đi')),
      body: Consumer<TripService>(
        builder: (context, tripService, _) {
          if (tripService.isLoading) return Center(child: CircularProgressIndicator());
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: tripService.trips.length,
            itemBuilder: (context, index) {
              final trip = tripService.trips[index];
              return ListTile(
                title: Text('${trip.departureLocation} - ${trip.arrivalLocation}'),
                subtitle: Text('Giá: ${trip.price} - ${trip.departureTime}'),
                onTap: () => Navigator.pushNamed(context, '/trip/detail/${trip.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => Navigator.pushNamed(context, '/trip/edit/${trip.id}'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await tripService.deleteTrip(trip.id);
                        tripService.fetchTrips();
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
        onPressed: () => Navigator.pushNamed(context, '/trip/create'),
        child: Icon(Icons.add),
      ),
    );
  }
}