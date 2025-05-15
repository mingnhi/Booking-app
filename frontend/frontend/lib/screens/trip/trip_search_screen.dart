import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/trip_service.dart';
import '../../services/location_service.dart';
import '../../services/auth_service.dart';
import '../home/customer_nav_bar.dart';
import '../../models/trip.dart';

class TripSearchScreen extends StatefulWidget {
  @override
  _TripSearchScreenState createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen>
    with SingleTickerProviderStateMixin {
  String? _departureId;
  String? _arrivalId;
  DateTime? _departureTime;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  int _selectedIndex = 1; // Default to TripSearchScreen
  List<Trip> _searchResults = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: const Color(0xFF2474E5).withOpacity(0.8),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    Future.microtask(() async {
      if (mounted) {
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1000),
        );
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeInOut,
          ),
        );
        _animationController!.forward();

        // Đợi fetchLocations hoàn thành
        final locationService = Provider.of<LocationService>(
          context,
          listen: false,
        );
        await locationService.fetchLocations();
      }
    });

    Provider.of<LocationService>(context, listen: false).fetchLocations();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/my-tickets');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/auth/profile');
        break;
    }
  }

  Future<void> _searchTrips() async {
    final tripService = Provider.of<TripService>(context, listen: false);
    final locationService = Provider.of<LocationService>(
      context,
      listen: false,
    );
    try {
      if (locationService.locations.isEmpty) {
        throw Exception('No locations available for search');
      }

      // Lấy tên địa điểm dựa trên ID, xử lý trường hợp không tìm thấy
      String? departureLocation =
          _departureId != null
              ? locationService.locations
                  .firstWhere(
                    (loc) => loc.id == _departureId,
                    orElse:
                        () =>
                            throw Exception(
                              'Departure location not found for ID: $_departureId',
                            ),
                  )
                  .location
              : null;
      String? arrivalLocation =
          _arrivalId != null
              ? locationService.locations
                  .firstWhere(
                    (loc) => loc.id == _arrivalId,
                    orElse:
                        () =>
                            throw Exception(
                              'Arrival location not found for ID: $_arrivalId',
                            ),
                  )
                  .location
              : null;

      if (departureLocation == null || arrivalLocation == null) {
        throw Exception('Could not find location names for the selected IDs');
      }

      final results = await tripService.searchTrips(
        departureLocation: departureLocation,
        arrivalLocation: arrivalLocation,
        departureTime: _departureTime,
      );
      setState(() {
        _searchResults = results;
        print('Search results: $_searchResults'); // Debug log
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
      print('Error searching trips in UI: $e'); // Debug log
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2474E5), Color(0xFFF9F9F9)],
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Consumer3<TripService, LocationService, AuthService>(
            builder: (context, tripService, locationService, authService, _) {
              if (locationService.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (locationService.locations.isEmpty) {
                return Center(
                  child: Text(
                    'Không thể tải danh sách địa điểm.',
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              if (_fadeAnimation == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/vexere_logo.png',
                            height: 40,
                          ),
                          Text(
                            'Chào ${authService.currentUser?.fullName ?? "Khách"}!',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cam kết hoàn 150% nếu nhà xe không cung cấp dịch vụ vận chuyển (*)',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 12,
                        shadowColor: const Color(0xFF2474E5).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Color(0xFF2474E5),
                            width: 1,
                          ),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.directions_bus,
                                    color: const Color(0xFF2474E5),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Xe khách',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF2474E5),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _departureId,
                                decoration: InputDecoration(
                                  labelText: 'Điểm Đi',
                                  labelStyle: GoogleFonts.poppins(
                                    color: Colors.blueGrey.shade800,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2474E5),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2474E5),
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                    color: const Color(0xFF2474E5),
                                  ),
                                ),
                                items:
                                    locationService.locations.map((loc) {
                                      return DropdownMenuItem<String>(
                                        value: loc.id,
                                        child: Text(
                                          loc.location,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged:
                                    (value) =>
                                        setState(() => _departureId = value),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _arrivalId,
                                decoration: InputDecoration(
                                  labelText: 'Điểm Đến',
                                  labelStyle: GoogleFonts.poppins(
                                    color: Colors.blueGrey.shade800,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2474E5),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2474E5),
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                    color: const Color(0xFF2474E5),
                                  ),
                                ),
                                items:
                                    locationService.locations.map((loc) {
                                      return DropdownMenuItem<String>(
                                        value: loc.id,
                                        child: Text(
                                          loc.location,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged:
                                    (value) =>
                                        setState(() => _arrivalId = value),
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                title: Text('Ngày đi'),
                                subtitle: Text(
                                  _departureTime != null
                                      ? DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_departureTime!)
                                      : 'Chọn ngày',
                                ),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _departureTime = DateTime(
                                        picked.year,
                                        picked.month,
                                        picked.day,
                                      );
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _departureId != null && _arrivalId != null
                                          ? () => _searchTrips()
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4A017),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Tìm kiếm',
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_searchResults.isNotEmpty)
                        Text(
                          'Kết quả tìm kiếm (${_searchResults.length} chuyến đi)',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      if (_searchResults.isEmpty && !tripService.isLoading)
                        Center(
                          child: Text(
                            'Không tìm thấy chuyến đi phù hợp.',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      if (tripService.isLoading)
                        const Center(child: CircularProgressIndicator()),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final trip = _searchResults[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Text(
                                '${trip.departure_location} → ${trip.arrival_location}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Thời gian đi: ${DateFormat('dd/MM/yyyy HH:mm').format(trip.departure_time)}',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  Text(
                                    'Thời gian đến: ${DateFormat('dd/MM/yyyy HH:mm').format(trip.arrival_time)}',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  Text(
                                    'Giá: ${trip.price} VNĐ',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  Text(
                                    'Loại xe: ${trip.vehicle_id} - Tổng ghế: ${trip.totalSeats}',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                              onTap:
                                  () => Navigator.pushNamed(
                                    context,
                                    '/trip/detail/${trip.id}',
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
