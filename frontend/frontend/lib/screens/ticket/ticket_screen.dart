import 'package:flutter/material.dart';
import 'package:frontend/models/seat.dart';
import 'package:frontend/models/ticket.dart';
import 'package:frontend/models/trip.dart';
import 'package:frontend/screens/payment/payment_screen.dart';
import 'package:frontend/screens/payment/refund_screen.dart';
import 'package:frontend/services/seat_service.dart';
import 'package:frontend/services/ticket_service.dart';
import 'package:frontend/services/trip_service.dart';
import 'package:frontend/screens/home/customer_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  Ticket? _selectedTicket;
  String? _selectedTripId;
  String? _selectedSeatId;
  List<Trip> _availableTrips = [];
  List<Seat> _availableSeats = [];

  @override
  void initState() {
    super.initState();
    final ticketService = Provider.of<TicketService>(context, listen: false);
    final tripService = Provider.of<TripService>(context, listen: false);
    final seatService = Provider.of<SeatService>(context, listen: false);

    Future.microtask(() async {
      try {
        await Future.wait([
          ticketService.fetchTickets(),
          tripService.fetchTrips(),
          seatService.fetchSeats(),
        ]);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
      }
    });
  }

  Future<void> _refreshTickets() async {
    final ticketService = Provider.of<TicketService>(context, listen: false);
    final tripService = Provider.of<TripService>(context, listen: false);
    final seatService = Provider.of<SeatService>(context, listen: false);

    try {
      await Future.wait([
        ticketService.fetchTickets(),
        tripService.fetchTrips(),
        seatService.fetchSeats(),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi làm mới dữ liệu: $e')));
    }
  }

  void _startEditing(Ticket ticket) {
    if (ticket.ticket_status == 'COMPLETED') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chỉnh sửa vé đã hoàn thành')),
      );
      return;
    }

    final tripService = Provider.of<TripService>(context, listen: false);
    final seatService = Provider.of<SeatService>(context, listen: false);

    setState(() {
      _isEditing = true;
      _selectedTicket = ticket;
      _selectedTripId = ticket.trip_id;
      _selectedSeatId = ticket.seat_id;
      _availableTrips =
          tripService.trips
              .where((trip) => trip.departure_time.isAfter(DateTime.now()))
              .toList();
      _availableSeats = [];
    });

    seatService
        .fetchAvailableSeatsByTripId(_selectedTripId!)
        .then((_) {
          setState(() {
            _availableSeats = seatService.seats;
            final currentSeat = seatService.seats.firstWhere(
              (seat) => seat.id == _selectedSeatId,
              orElse:
                  () => Seat(
                    id: _selectedSeatId ?? '',
                    tripId: _selectedTripId ?? '',
                    seatNumber: 0,
                    statusSeat: 'BOOKED',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
            );
            if (!_availableSeats.contains(currentSeat) &&
                currentSeat.id.isNotEmpty) {
              _availableSeats.add(currentSeat);
            }
            print('Available trips: ${_availableTrips.length}');
            print('Available seats: ${_availableSeats.length}');
          });
        })
        .catchError((e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi tải ghế: $e')));
          setState(() {
            _availableSeats = [];
          });
        });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _selectedTicket = null;
      _selectedTripId = null;
      _selectedSeatId = null;
      _availableTrips = [];
      _availableSeats = [];
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final ticketService = Provider.of<TicketService>(context, listen: false);
      final seatService = Provider.of<SeatService>(context, listen: false);

      if (_selectedTripId == null || _selectedSeatId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thông tin chuyến đi hoặc ghế không hợp lệ')),
        );
        return;
      }

      final ticketData = {
        'trip_id': _selectedTripId,
        'seat_id': _selectedSeatId,
      };

      try {
        print('Ticket ID gửi đi: ${_selectedTicket!.id}');
        print('Gửi yêu cầu cập nhật vé: $ticketData');
        final updatedTicket = await ticketService.updateTicket(
          _selectedTicket!.id,
          ticketData,
        );
        if (updatedTicket != null) {
          if (_selectedTicket!.seat_id != _selectedSeatId) {
            // Cập nhật ghế cũ thành AVAILABLE
            final oldSeat = seatService.seats.firstWhere(
              (s) => s.id == _selectedTicket!.seat_id,
              orElse:
                  () => Seat(
                    id: _selectedTicket!.seat_id,
                    tripId: _selectedTicket!.trip_id,
                    seatNumber: 0,
                    statusSeat: 'BOOKED',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
            );
            if (oldSeat.id.isNotEmpty) {
              print('Cập nhật ghế cũ ${oldSeat.id} thành AVAILABLE');
              final updatedOldSeat = await seatService.updateSeat(
                oldSeat.id,
                Seat(
                  id: oldSeat.id,
                  tripId: oldSeat.tripId,
                  seatNumber: oldSeat.seatNumber,
                  statusSeat: 'AVAILABLE',
                  createdAt: oldSeat.createdAt,
                  updatedAt: DateTime.now(),
                ),
              );
              if (updatedOldSeat == null) {
                throw Exception('Không thể cập nhật trạng thái ghế cũ');
              }
            }

            // Cập nhật ghế mới thành BOOKED
            final newSeat = seatService.seats.firstWhere(
              (s) => s.id == _selectedSeatId,
              orElse:
                  () => Seat(
                    id: _selectedSeatId!,
                    tripId: _selectedTripId!,
                    seatNumber: 0,
                    statusSeat: 'AVAILABLE',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
            );
            if (newSeat.id.isNotEmpty) {
              print('Cập nhật ghế mới ${newSeat.id} thành BOOKED');
              final updatedNewSeat = await seatService.updateSeat(
                newSeat.id,
                Seat(
                  id: newSeat.id,
                  tripId: newSeat.tripId,
                  seatNumber: newSeat.seatNumber,
                  statusSeat: 'BOOKED',
                  createdAt: newSeat.createdAt,
                  updatedAt: DateTime.now(),
                ),
              );
              if (updatedNewSeat == null) {
                throw Exception('Không thể cập nhật trạng thái ghế mới');
              }
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cập nhật vé thành công',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: const Color(0xFF2474E5),
            ),
          );
          setState(() {
            _isEditing = false;
            _selectedTicket = null;
            _selectedTripId = null;
            _selectedSeatId = null;
            _availableTrips = [];
            _availableSeats = [];
          });
          await _refreshTickets();
        } else {
          throw Exception('Không thể cập nhật vé');
        }
      } catch (e) {
        print('Lỗi khi lưu thay đổi vé: $e');
        String errorMessage = e.toString();
        if (errorMessage.contains('404')) {
          errorMessage =
              'Vé hoặc ghế không tồn tại. Vui lòng làm mới danh sách.';
        } else if (errorMessage.contains('403')) {
          errorMessage = 'Bạn không có quyền cập nhật vé này.';
        } else if (errorMessage.contains('400')) {
          errorMessage = 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật vé thất bại: $errorMessage')),
        );
      }
    } else {
      print('Form xác thực thất bại');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng kiểm tra thông tin nhập')),
      );
    }
  }

  Future<void> _deleteTicket(
    String ticketId,
    String seatId,
    String tripId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận xóa', style: GoogleFonts.poppins()),
            content: Text(
              'Bạn có chắc chắn muốn xóa vé này?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Xóa',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final ticketService = Provider.of<TicketService>(context, listen: false);
      final seatService = Provider.of<SeatService>(context, listen: false);

      try {
        final success = await ticketService.deleteTicket(ticketId);
        if (success) {
          final seat = seatService.seats.firstWhere(
            (s) => s.id == seatId,
            orElse:
                () => Seat(
                  id: seatId,
                  tripId: tripId,
                  seatNumber: 0,
                  statusSeat: 'BOOKED',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
          );
          if (seat.statusSeat == 'BOOKED') {
            final updatedSeat = await seatService.updateSeat(
              seat.id,
              Seat(
                id: seat.id,
                tripId: seat.tripId,
                seatNumber: seat.seatNumber,
                statusSeat: 'AVAILABLE',
                createdAt: seat.createdAt,
                updatedAt: DateTime.now(),
              ),
            );
            if (updatedSeat == null) {
              throw Exception('Không thể cập nhật trạng thái ghế');
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xóa vé thành công', style: GoogleFonts.poppins()),
              backgroundColor: const Color(0xFF2474E5),
            ),
          );
          await _refreshTickets();
        } else {
          throw Exception('Không thể xóa vé');
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Xóa vé thất bại: $e')));
      }
    }
  }

  void _navigateToTicketDetail(Ticket ticket) {
    // Tìm thông tin chuyến đi liên quan đến vé
    final tripService = Provider.of<TripService>(context, listen: false);
    final trip = tripService.trips.firstWhere(
      (t) => t.id == ticket.trip_id,
      orElse: () => Trip(
        id: '',
        vehicle_id: '',
        departure_location: 'Không xác định',
        arrival_location: 'Không xác định',
        departure_time: DateTime.now(),
        arrival_time: DateTime.now(),
        price: 0.0,
        distance: 0.0,
        totalSeats: 0,
      ),
    );

    // Hiển thị thông tin chi tiết vé trong dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết vé', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Mã vé', ticket.id),
              _buildDetailRow('Trạng thái', _getStatusText(ticket.ticket_status)),
              _buildDetailRow('Chuyến đi', '${trip.departure_location} → ${trip.arrival_location}'),
              _buildDetailRow('Thời gian khởi hành', DateFormat('dd/MM/yyyy HH:mm').format(trip.departure_time)),
              _buildDetailRow('Thời gian đến', DateFormat('dd/MM/yyyy HH:mm').format(trip.arrival_time)),
              _buildDetailRow('Giá vé', '${trip.price.toStringAsFixed(0)} VNĐ'),
              _buildDetailRow('Ngày đặt vé', DateFormat('dd/MM/yyyy HH:mm').format(ticket.booked_at)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ thanh toán';
      case 'PAID':
        return 'Đã thanh toán';
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: const Color(0xFF2474E5),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2474E5),
          secondary: Color(0xFF5B9EE5),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2474E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2474E5),
          title: Text(
            'Vé của tôi',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshTickets,
            ),
          ],
        ),
        body: Stack(
          children: [
            Consumer3<TicketService, TripService, SeatService>(
              builder: (
                context,
                ticketService,
                tripService,
                seatService,
                child,
              ) {
                if (ticketService.isLoading ||
                    tripService.isLoading ||
                    seatService.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2474E5)),
                  );
                }

                if (ticketService.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 80, color: Colors.red),
                        const SizedBox(height: 20),
                        Text(
                          ticketService.errorMessage!.contains('404')
                              ? 'Không tìm thấy vé. Vui lòng kiểm tra hoặc liên hệ hỗ trợ.'
                              : ticketService.errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _refreshTickets,
                          child: Text('Thử lại', style: GoogleFonts.poppins()),
                        ),
                      ],
                    ),
                  );
                }

                if (ticketService.tickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_bus,
                          size: 80,
                          color: Color(0xFF2474E5),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Bạn chưa có vé nào',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Hãy đặt vé để bắt đầu hành trình!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshTickets,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: ticketService.tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = ticketService.tickets[index];
                      final trip = tripService.trips.firstWhere(
                        (t) => t.id == ticket.trip_id,
                        orElse:
                            () => Trip(
                              id: '',
                              vehicle_id: '',
                              departure_location: 'Không xác định',
                              arrival_location: 'Không xác định',
                              departure_time: DateTime.now(),
                              arrival_time: DateTime.now(),
                              price: 0.0,
                              distance: 0.0,
                              totalSeats: 0,
                            ),
                      );
                      final seat = seatService.seats.firstWhere(
                        (s) => s.id == ticket.seat_id,
                        orElse:
                            () => Seat(
                              id: ticket.seat_id,
                              tripId: ticket.trip_id,
                              seatNumber: 0,
                              statusSeat: 'BOOKED',
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            ),
                      );

                      final availableSeats =
                          seatService.seats
                              .where(
                                (s) =>
                                    s.tripId == trip.id &&
                                    s.statusSeat == 'AVAILABLE',
                              )
                              .length;

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Vé #${ticket.id.substring(0, 8)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2474E5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                leading: const Icon(
                                  Icons.directions_bus,
                                  color: Color(0xFF2474E5),
                                ),
                                title: Text(
                                  '${trip.departure_location} → ${trip.arrival_location}',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                                subtitle: Text(
                                  'Khoảng cách: ${trip.distance.toStringAsFixed(1)} km',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.event_seat,
                                  color: Color(0xFF2474E5),
                                ),
                                title: Text(
                                  'Ghế: ${seat.seatNumber}',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                                subtitle: Text(
                                  'Còn ${availableSeats}/${trip.totalSeats} ghế trống',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.access_time,
                                  color: Color(0xFF2474E5),
                                ),
                                title: Text(
                                  'Thời gian đi: ${DateFormat('dd/MM/yyyy HH:mm').format(trip.departure_time)}',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.confirmation_number,
                                  color: Color(0xFF2474E5),
                                ),
                                title: Text(
                                  'Trạng thái: ${ticket.ticket_status}',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.attach_money,
                                  color: Color(0xFF2474E5),
                                ),
                                title: Text(
                                  'Giá: ${trip.price.toStringAsFixed(0)} VNĐ',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF2474E5),
                                ),
                                title: Text(
                                  'Đặt lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(ticket.booked_at)}',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (ticket.ticket_status != 'COMPLETED' && ticket.ticket_status != 'CANCELLED')
                                      ElevatedButton(
                                        onPressed: () => _startEditing(ticket),
                                        child: Text(
                                          'Chỉnh sửa',
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    // Thay đổi điều kiện để luôn hiển thị nút thanh toán (chỉ để kiểm tra)
                                    // if (ticket.ticket_status == 'PENDING')
                                    ElevatedButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentScreen(
                                              amount: trip.price,
                                              ticketId: ticket.id,
                                            ),
                                          ),
                                        );
                                        
                                        // Nếu thanh toán thành công, làm mới danh sách vé
                                        if (result == true) {
                                          _refreshTickets();
                                          
                                          // Chuyển đến trang chi tiết vé
                                          _navigateToTicketDetail(ticket);
                                        }
                                      },
                                      child: Text(
                                        'Thanh toán',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                    if (ticket.ticket_status == 'PAID')
                                      ElevatedButton(
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RefundScreen(
                                                ticketId: ticket.id,
                                                amount: trip.price,
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            _refreshTickets();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                        child: Text(
                                          'Hoàn tiền',
                                          style: GoogleFonts.poppins(color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            if (_isEditing)
              ModalBarrier(color: Colors.black54, dismissible: false),
            if (_isEditing)
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Chỉnh sửa vé',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2474E5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedTripId,
                            decoration: InputDecoration(
                              labelText: 'Chuyến đi',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items:
                                _availableTrips.map((trip) {
                                  return DropdownMenuItem<String>(
                                    value: trip.id,
                                    child: Text(
                                      '${trip.departure_location} → ${trip.arrival_location}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTripId = value;
                                _selectedSeatId = null;
                                _availableSeats = [];
                              });
                              Provider.of<SeatService>(context, listen: false)
                                  .fetchAvailableSeatsByTripId(_selectedTripId!)
                                  .then((_) {
                                    setState(() {
                                      _availableSeats =
                                          Provider.of<SeatService>(
                                            context,
                                            listen: false,
                                          ).seats;
                                      if (_selectedTicket!.seat_id != null &&
                                          _availableSeats.every(
                                            (seat) =>
                                                seat.id !=
                                                _selectedTicket!.seat_id,
                                          )) {
                                        final currentSeat = Provider.of<
                                          SeatService
                                        >(
                                          context,
                                          listen: false,
                                        ).seats.firstWhere(
                                          (seat) =>
                                              seat.id ==
                                              _selectedTicket!.seat_id,
                                          orElse:
                                              () => Seat(
                                                id: _selectedTicket!.seat_id,
                                                tripId:
                                                    _selectedTicket!.trip_id,
                                                seatNumber: 0,
                                                statusSeat: 'BOOKED',
                                                createdAt: DateTime.now(),
                                                updatedAt: DateTime.now(),
                                              ),
                                        );
                                        if (currentSeat.id.isNotEmpty) {
                                          _availableSeats.add(currentSeat);
                                        }
                                      }
                                      print(
                                        'Available seats: ${_availableSeats.length}',
                                      );
                                    });
                                  })
                                  .catchError((e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Lỗi khi tải ghế: $e'),
                                      ),
                                    );
                                    setState(() {
                                      _availableSeats = [];
                                    });
                                  });
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Vui lòng chọn chuyến đi'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedSeatId,
                            decoration: InputDecoration(
                              labelText: 'Ghế',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items:
                                _availableSeats.map((seat) {
                                  return DropdownMenuItem<String>(
                                    value: seat.id,
                                    child: Text(
                                      'Ghế ${seat.seatNumber}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSeatId = value;
                              });
                            },
                            validator:
                                (value) =>
                                    value == null ? 'Vui lòng chọn ghế' : null,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _cancelEditing,
                                child: Text(
                                  'Hủy',
                                  style: GoogleFonts.poppins(color: Colors.red),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _saveChanges,
                                child: Text(
                                  'Lưu',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: CustomNavBar(
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/trip/search');
            } else if (index == 2) {
              // Đã ở màn hình này
            } else if (index == 3) {
              Navigator.pushReplacementNamed(context, '/auth/profile');
            }
          },
        ),
      ),
    );
  }
}
