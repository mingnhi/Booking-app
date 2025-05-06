import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/trip_service.dart';
import '../../services/location_service.dart';

class TripSearchScreen extends StatefulWidget {
  @override
  _TripSearchScreenState createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen> {
  String? _departureId;
  String? _arrivalId;

  @override
  void initState() {
    super.initState();
    Provider.of<LocationService>(context, listen: false).fetchLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tìm kiếm chuyến đi')),
      body: Consumer2<TripService, LocationService>(
        builder: (context, tripService, locationService, _) {
          if (locationService.isLoading) return Center(child: CircularProgressIndicator());
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  hint: Text('Chọn điểm đi'),
                  value: _departureId,
                  items: locationService.locations.map((loc) {
                    return DropdownMenuItem<String>(value: loc.id, child: Text(loc.location));
                  }).toList(),
                  onChanged: (value) => setState(() => _departureId = value),
                ),
                DropdownButton<String>(
                  hint: Text('Chọn điểm đến'),
                  value: _arrivalId,
                  items: locationService.locations.map((loc) {
                    return DropdownMenuItem<String>(value: loc.id, child: Text(loc.location));
                  }).toList(),
                  onChanged: (value) => setState(() => _arrivalId = value),
                ),
                ElevatedButton(
                  onPressed: _departureId != null && _arrivalId != null
                      ? () async {
                    await tripService.searchTrips(_departureId!, _arrivalId!);
                  }
                      : null,
                  child: Text('Tìm kiếm'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tripService.trips.length,
                    itemBuilder: (context, index) {
                      final trip = tripService.trips[index];
                      return ListTile(
                        title: Text('${trip.departureLocation} - ${trip.arrivalLocation}'),
                        subtitle: Text('Giá: ${trip.price}'),
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