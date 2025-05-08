import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trip.dart';
import '../../services/trip_service.dart';
import '../../services/location_service.dart';

class TripCreateScreen extends StatefulWidget {
  @override
  _TripCreateScreenState createState() => _TripCreateScreenState();
}

class _TripCreateScreenState extends State<TripCreateScreen> {
  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _priceController = TextEditingController();
  final _busTypeController = TextEditingController();
  final _totalSeatsController = TextEditingController();
  DateTime _departureTime = DateTime.now();
  DateTime _arrivalTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    Provider.of<LocationService>(context, listen: false).fetchLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tạo chuyến đi')),
      body: Consumer<LocationService>(
        builder: (context, locationService, _) {
          if (locationService.isLoading)
            return Center(child: CircularProgressIndicator());
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: [
                DropdownButton<String>(
                  hint: Text('Điểm đi'),
                  value:
                      _departureController.text.isNotEmpty
                          ? _departureController.text
                          : null,
                  items:
                      locationService.locations.map((loc) {
                        return DropdownMenuItem<String>(
                          value: loc.location,
                          child: Text(loc.location),
                        );
                      }).toList(),
                  onChanged:
                      (value) =>
                          setState(() => _departureController.text = value!),
                ),
                DropdownButton<String>(
                  hint: Text('Điểm đến'),
                  value:
                      _arrivalController.text.isNotEmpty
                          ? _arrivalController.text
                          : null,
                  items:
                      locationService.locations.map((loc) {
                        return DropdownMenuItem<String>(
                          value: loc.location,
                          child: Text(loc.location),
                        );
                      }).toList(),
                  onChanged:
                      (value) =>
                          setState(() => _arrivalController.text = value!),
                ),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Giá'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _busTypeController,
                  decoration: InputDecoration(labelText: 'Loại xe'),
                ),
                TextField(
                  controller: _totalSeatsController,
                  decoration: InputDecoration(labelText: 'Tổng ghế'),
                  keyboardType: TextInputType.number,
                ),
                ListTile(
                  title: Text('Thời gian đi'),
                  subtitle: Text('${_departureTime}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _departureTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _departureTime = picked);
                  },
                ),
                ListTile(
                  title: Text('Thời gian đến'),
                  subtitle: Text('${_arrivalTime}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _arrivalTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _arrivalTime = picked);
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    final tripService = Provider.of<TripService>(
                      context,
                      listen: false,
                    );
                    final trip = Trip(
                      id: '',
                      departureLocation: _departureController.text,
                      arrivalLocation: _arrivalController.text,
                      departureTime: _departureTime,
                      arrivalTime: _arrivalTime,
                      price: double.parse(_priceController.text),
                      busType: _busTypeController.text,
                      totalSeats: int.parse(_totalSeatsController.text),
                      createdAt: null,
                    );
                    if (await tripService.createTrip(trip) != null) {
                      Navigator.pushReplacementNamed(context, '/trip');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tạo chuyến đi thất bại')),
                      );
                    }
                  },
                  child: Text('Lưu'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
