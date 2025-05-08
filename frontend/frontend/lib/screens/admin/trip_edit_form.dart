import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../services/location_service.dart';

class TripEditForm extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const TripEditForm({Key? key, required this.tripData}) : super(key: key);

  @override
  _TripEditFormState createState() => _TripEditFormState();
}

class _TripEditFormState extends State<TripEditForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _priceController = TextEditingController();
  final _busTypeController = TextEditingController();
  final _totalSeatsController = TextEditingController();

  // Trip data
  String _departureLocationId = '';
  String _arrivalLocationId = '';
  DateTime _departureTime = DateTime.now();
  DateTime _arrivalTime = DateTime.now().add(const Duration(hours: 2));

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    // Không gọi fetchLocations() trực tiếp ở đây, để Consumer xử lý
  }

  void _initializeFormData() {
    final tripData = widget.tripData;

    _departureLocationId = tripData['departure_location'] ?? '';
    _arrivalLocationId = tripData['arrival_location'] ?? '';
    _priceController.text = tripData['price']?.toString() ?? '';
    _busTypeController.text = tripData['bus_type'] ?? '';
    _totalSeatsController.text = tripData['total_seats']?.toString() ?? '';

    if (tripData['departure_time'] != null) {
      _departureTime = DateTime.parse(tripData['departure_time']);
    }

    if (tripData['arrival_time'] != null) {
      _arrivalTime = DateTime.parse(tripData['arrival_time']);
    }
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _departureTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_departureTime),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _departureTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          // Ensure arrival time is after departure time
          if (_arrivalTime.isBefore(_departureTime)) {
            _arrivalTime = _departureTime.add(const Duration(hours: 2));
          }
        });
      }
    }
  }

  Future<void> _selectArrivalDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _arrivalTime.isBefore(_departureTime)
              ? _departureTime.add(const Duration(hours: 2))
              : _arrivalTime,
      firstDate: _departureTime,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_arrivalTime),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _arrivalTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);

      final tripData = {
        'departure_location': _departureLocationId,
        'arrival_location': _arrivalLocationId,
        'departure_time': _departureTime.toIso8601String(),
        'arrival_time': _arrivalTime.toIso8601String(),
        'price': double.parse(_priceController.text),
        'bus_type': _busTypeController.text,
        'total_seats': int.parse(_totalSeatsController.text),
      };

      await adminService.updateTrip(widget.tripData['_id'], tripData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật chuyến đi thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _busTypeController.dispose();
    _totalSeatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa chuyến đi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Consumer<LocationService>(
                builder: (context, locationService, _) {
                  if (locationService.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final locations = locationService.locations;

                  return Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thông tin cơ bản',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Điểm đi',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.location_on),
                                  ),
                                  value:
                                      _departureLocationId.isNotEmpty
                                          ? _departureLocationId
                                          : null,
                                  items:
                                      locations.map((location) {
                                        return DropdownMenuItem<String>(
                                          value: location.id,
                                          child: Text(location.location),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    if (value != null && mounted) {
                                      setState(() {
                                        _departureLocationId = value;
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng chọn điểm đi';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Điểm đến',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.location_on),
                                  ),
                                  value:
                                      _arrivalLocationId.isNotEmpty
                                          ? _arrivalLocationId
                                          : null,
                                  items:
                                      locations.map((location) {
                                        return DropdownMenuItem<String>(
                                          value: location.id,
                                          child: Text(location.location),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    if (value != null && mounted) {
                                      setState(() {
                                        _arrivalLocationId = value;
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng chọn điểm đến';
                                    }
                                    if (value == _departureLocationId) {
                                      return 'Điểm đến không được trùng với điểm đi';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thời gian',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  title: const Text('Thời gian khởi hành'),
                                  subtitle: Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(_departureTime),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.calendar_today),
                                  onTap: () => _selectDepartureDate(context),
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text('Thời gian đến'),
                                  subtitle: Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(_arrivalTime),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.calendar_today),
                                  onTap: () => _selectArrivalDate(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thông tin khác',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Giá vé (VND)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập giá vé';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Giá vé phải là số';
                                    }
                                    if (double.parse(value) <= 0) {
                                      return 'Giá vé phải lớn hơn 0';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _busTypeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Loại xe',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.directions_bus),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập loại xe';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _totalSeatsController,
                                  decoration: const InputDecoration(
                                    labelText: 'Tổng số ghế',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.event_seat),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập tổng số ghế';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Tổng số ghế phải là số nguyên';
                                    }
                                    if (int.parse(value) <= 0) {
                                      return 'Tổng số ghế phải lớn hơn 0';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveTrip,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    'Lưu thay đổi',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
