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
  const TripSearchScreen({super.key});

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
  int _selectedIndex = 1; // Mặc định là TripSearchScreen
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

    Future.microtask(() async {
      if (mounted) {
        final locationService = Provider.of<LocationService>(context, listen: false);
        await locationService.fetchLocations();
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
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
        Navigator.pushReplacementNamed(context, '/tickets');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/auth/profile');
        break;
    }
  }

  Future<void> _searchTrips() async {
    final tripService = Provider.of<TripService>(context, listen: false);
    final locationService = Provider.of<LocationService>(context, listen: false);
    try {
      if (locationService.locations.isEmpty) {
        throw Exception('Không có danh sách địa điểm để tìm kiếm');
      }

      final departureLocation = _departureId != null
          ? locationService.locations
          .firstWhere(
            (loc) => loc.id == _departureId,
        orElse: () => throw Exception('Không tìm thấy điểm đi với ID: $_departureId'),
      )
          .location
          : null;
      final arrivalLocation = _arrivalId != null
          ? locationService.locations
          .firstWhere(
            (loc) => loc.id == _arrivalId,
        orElse: () => throw Exception('Không tìm thấy điểm đến với ID: $_arrivalId'),
      )
          .location
          : null;

      if (departureLocation == null || arrivalLocation == null) {
        throw Exception('Không thể tìm thấy tên địa điểm cho ID đã chọn');
      }

      final results = await tripService.searchTrips(
        departureLocation: departureLocation,
        arrivalLocation: arrivalLocation,
        departureTime: _departureTime,
      );
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tìm kiếm chuyến đi: $e')),
      );
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
                          side: const BorderSide(color: Color(0xFF2474E5), width: 1),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.directions_bus,
                                    color: Color(0xFF2474E5),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Xe khách',
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF2474E5),
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
                                  labelStyle: GoogleFonts.poppins(color: Colors.blueGrey.shade800),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2474E5)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2474E5), width: 2),
                                  ),
                                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFF2474E5)),
                                ),
                                items: locationService.locations.map((loc) {
                                  return DropdownMenuItem<String>(
                                    value: loc.id,
                                    child: Text(
                                      loc.location,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _departureId = value),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _arrivalId,
                                decoration: InputDecoration(
                                  labelText: 'Điểm Đến',
                                  labelStyle: GoogleFonts.poppins(color: Colors.blueGrey.shade800),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2474E5)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2474E5), width: 2),
                                  ),
                                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFF2474E5)),
                                ),
                                items: locationService.locations.map((loc) {
                                  return DropdownMenuItem<String>(
                                    value: loc.id,
                                    child: Text(
                                      loc.location,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _arrivalId = value),
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                title: const Text('Ngày đi'),
                                subtitle: Text(
                                  _departureTime != null
                                      ? DateFormat('dd/MM/yyyy').format(_departureTime!)
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
                                      _departureTime = DateTime(picked.year, picked.month, picked.day);
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _departureId != null && _arrivalId != null ? _searchTrips : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4A017),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Tìm kiếm',
                                    style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600),
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
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final trip = _searchResults[index];
                          final locationService = Provider.of<LocationService>(context, listen: false);

                          String departureName = 'Không xác định';
                          String arrivalName = 'Không xác định';
                          try {
                            if (_departureId != null) {
                              departureName = locationService.locations
                                  .firstWhere((loc) => loc.id == _departureId)
                                  .location;
                            }
                            if (_arrivalId != null) {
                              arrivalName = locationService.locations
                                  .firstWhere((loc) => loc.id == _arrivalId)
                                  .location;
                            }
                          } catch (e) {
                            print('Lỗi khi ánh xạ ID địa điểm: $e');
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                '$departureName → $arrivalName',
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
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/trip/detail/:id',
                                  arguments: trip.id,
                                );
                              },
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