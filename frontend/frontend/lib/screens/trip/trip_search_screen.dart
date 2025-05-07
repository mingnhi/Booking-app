import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/trip_service.dart';
import '../../services/location_service.dart';
import '../../services/auth_service.dart';
import '../home/customer_nav_bar.dart'; // Import CustomNavBar

class TripSearchScreen extends StatefulWidget {
  @override
  _TripSearchScreenState createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen> with SingleTickerProviderStateMixin {
  String? _departureId;
  String? _arrivalId;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  int _selectedIndex = 1; // Default to TripSearchScreen

  @override
  void initState() {
    super.initState();
    // Set status bar to match gradient's top color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color(0xFF2474E5).withOpacity(0.8),
      statusBarIconBrightness: Brightness.light,
    ));

    // Khởi tạo AnimationController và FadeAnimation
    Future.microtask(() {
      if (mounted) {
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1000),
        );
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
        );
        _animationController!.forward();
      }
    });

    Provider.of<LocationService>(context, listen: false).fetchLocations();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    // Reset status bar when leaving screen
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Prevent redundant navigation
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
      // Already on TripSearchScreen, no action needed
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/my-tickets');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/auth/profile');
        break;
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
                            'assets/images/vexere_logo.png', // Placeholder for logo
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
                                  Icon(Icons.directions_bus, color: const Color(0xFF2474E5), size: 24),
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
                                    borderSide: const BorderSide(color: Color(0xFF2474E5)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2474E5), width: 2),
                                  ),
                                  prefixIcon: Icon(Icons.location_on, color: const Color(0xFF2474E5)),
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
                                  labelStyle: GoogleFonts.poppins(
                                    color: Colors.blueGrey.shade800,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2474E5)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2474E5), width: 2),
                                  ),
                                  prefixIcon: Icon(Icons.location_on, color: const Color(0xFF2474E5)),
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
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _departureId != null && _arrivalId != null
                                      ? () async {
                                    // Placeholder action (no navigation to /trip/search)
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4A017), // Yellow button
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
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