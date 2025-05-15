import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/trip_service.dart';
import '../../services/seat_service.dart';
import '../../services/location_service.dart';
import '../../services/ticket_service.dart';
import '../../services/auth_service.dart';
import '../../models/location.dart';
import '../../models/ticket.dart';
import '../../models/seat.dart';
import '../../models/trip.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key});

  static const routeName = '/trip/detail/:id';

  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  static const Color primaryColor = Color(0xFF2474E5);
  String? _selectedSeatId;
  bool _isBooking = false;
  String? _tripId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments;
    String? tripId;

    if (arguments is String) {
      tripId = arguments;
    } else if (arguments is Map<String, dynamic>) {
      tripId = arguments['_id'] as String?;
    } else {
      print('Invalid tripId format: $arguments');
      return;
    }

    if (tripId != null && tripId != _tripId) {
      _tripId = tripId;
      Future.microtask(() async {
        final seatService = Provider.of<SeatService>(context, listen: false);
        final tripService = Provider.of<TripService>(context, listen: false);
        try {
          await Future.wait([
            seatService.fetchSeats(),
            tripService.fetchTripById(tripId!),
          ]);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi tải thông tin chuyến đi: $e')),
          );
        }
      });
    }
  }

  Future<void> _bookTicket(String tripId, String userId, BuildContext context) async {
    if (_selectedSeatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ghế trước khi đặt vé!')),
      );
      return;
    }

    setState(() => _isBooking = true);

    final ticketService = Provider.of<TicketService>(context, listen: false);
    final seatService = Provider.of<SeatService>(context, listen: false);

    final ticketData = {
      "trip_id": tripId,
      "seat_id": _selectedSeatId,
    };

    try {
      final newTicket = await ticketService.createTicket(ticketData);
      if (newTicket != null) {
        final seat = seatService.seats.firstWhere((s) => s.id == _selectedSeatId);
        await seatService.updateSeat(seat.id, Seat(
          id: seat.id,
          tripId: seat.tripId,
          seatNumber: seat.seatNumber,
          statusSeat: 'BOOKED',
          createdAt: seat.createdAt,
          updatedAt: DateTime.now(),
        ));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt vé thành công!', style: GoogleFonts.poppins()),
            backgroundColor: primaryColor,
          ),
        );
        setState(() {
          _selectedSeatId = null;
        });
        await seatService.fetchSeats();
      } else {
        throw Exception('Không thể tạo vé');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đặt vé thất bại: $e')),
      );
    } finally {
      setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tripId == null || _tripId!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'ID chuyến đi không hợp lệ',
            style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: const Color(0xFF5B9EE5),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            'Chi tiết chuyến đi',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer4<TripService, SeatService, LocationService, TicketService>(
          builder: (context, tripService, seatService, locationService, ticketService, _) {
            if (tripService.isLoading || seatService.isLoading || locationService.isLoading || _isBooking) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }

            final trip = tripService.trips.firstWhere(
                  (t) => t.id == _tripId,
              orElse: () => Trip(
                id: '',
                vehicle_id: '',
                departure_location: '',
                arrival_location: '',
                departure_time: DateTime.now(),
                arrival_time: DateTime.now(),
                price: 0,
                distance: 0,
                totalSeats: 0,
              ),
            );

            if (trip.id.isEmpty) {
              return Center(
                child: Text(
                  'Không tìm thấy thông tin chuyến đi',
                  style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 16),
                ),
              );
            }

            final location = locationService.locations.firstWhere(
                  (loc) => loc.id == trip.vehicle_id,
              orElse: () => Location(id: '', location: 'Không xác định', contact_phone: ''),
            );

            final authService = Provider.of<AuthService>(context, listen: false);
            final userId = authService.currentUser?.id;

            if (userId == null) {
              return Center(
                child: Text(
                  'Vui lòng đăng nhập để đặt vé',
                  style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 16),
                ),
              );
            }

            final availableSeats = seatService.seats
                .where((seat) => seat.tripId == _tripId && seat.statusSeat == 'AVAILABLE')
                .toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin chuyến đi',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              leading: const Icon(Icons.location_on, color: primaryColor),
                              title: Text('Địa điểm: ${location.location}', style: GoogleFonts.poppins(fontSize: 16)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.arrow_forward, color: primaryColor),
                              title: Text('Điểm đi: ${trip.departure_location}', style: GoogleFonts.poppins(fontSize: 16)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.arrow_back, color: primaryColor),
                              title: Text('Điểm đến: ${trip.arrival_location}', style: GoogleFonts.poppins(fontSize: 16)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.access_time, color: primaryColor),
                              title: Text('Thời gian đi: ${trip.departure_time.toString()}', style: GoogleFonts.poppins(fontSize: 16)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.access_time_filled, color: primaryColor),
                              title: Text('Thời gian đến: ${trip.arrival_time.toString()}', style: GoogleFonts.poppins(fontSize: 16)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.attach_money, color: primaryColor),
                              title: Text('Giá: ${trip.price.toStringAsFixed(0)} VNĐ', style: GoogleFonts.poppins(fontSize: 16)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.directions_bus, color: primaryColor),
                              title: Text('Loại xe: ${trip.vehicle_id}', style: GoogleFonts.poppins(fontSize: 16)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.event_seat, color: primaryColor),
                              title: Text('Tổng ghế: ${trip.totalSeats}', style: GoogleFonts.poppins(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Chọn ghế',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (availableSeats.isEmpty)
                      Text(
                        'Không có ghế khả dụng. Vui lòng chọn chuyến khác.',
                        style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 16),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedSeatId,
                        hint: Text('Chọn ghế', style: GoogleFonts.poppins(fontSize: 14)),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items: availableSeats.map((seat) => DropdownMenuItem<String>(
                          value: seat.id,
                          child: Text('Ghế ${seat.seatNumber}', style: GoogleFonts.poppins(fontSize: 14)),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSeatId = value;
                          });
                        },
                      ),
                    const SizedBox(height: 20),
                    AnimatedOpacity(
                      opacity: _isBooking ? 0.7 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: ElevatedButton(
                        onPressed: availableSeats.isEmpty || _isBooking
                            ? null
                            : () => _bookTicket(_tripId!, userId!, context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          elevation: 3,
                        ),
                        child: _isBooking
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text('Đặt vé ngay'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}