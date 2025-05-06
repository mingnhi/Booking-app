import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/seat.dart';
import '../../services/seat_service.dart';
import '../../services/trip_service.dart';

class SeatCreateScreen extends StatefulWidget {
  @override
  _SeatCreateScreenState createState() => _SeatCreateScreenState();
}

class _SeatCreateScreenState extends State<SeatCreateScreen> {
  final _tripIdController = TextEditingController();
  final _seatNumberController = TextEditingController();
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    Provider.of<TripService>(context, listen: false).fetchTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tạo ghế')),
      body: Consumer<TripService>(
        builder: (context, tripService, _) {
          if (tripService.isLoading) return Center(child: CircularProgressIndicator());
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  hint: Text('Chọn chuyến đi'),
                  value: _tripIdController.text.isNotEmpty ? _tripIdController.text : null,
                  items: tripService.trips.map((trip) {
                    return DropdownMenuItem<String>(value: trip.id, child: Text('${trip.departureLocation} - ${trip.arrivalLocation}'));
                  }).toList(),
                  onChanged: (value) => setState(() => _tripIdController.text = value!),
                ),
                TextField(controller: _seatNumberController, decoration: InputDecoration(labelText: 'Số ghế'), keyboardType: TextInputType.number),
                SwitchListTile(
                  title: Text('Còn trống'),
                  value: _isAvailable,
                  onChanged: (value) => setState(() => _isAvailable = value),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final seatService = Provider.of<SeatService>(context, listen: false);
                    final seat = Seat(
                      id: '',
                      tripId: _tripIdController.text,
                      seatNumber: int.parse(_seatNumberController.text),
                      isAvailable: _isAvailable,
                      createdAt: null,
                      updatedAt: null,
                    );
                    if (await seatService.createSeat(seat) != null) {
                      Navigator.pushReplacementNamed(context, '/seat');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tạo ghế thất bại')));
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