import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/home_service.dart';
import '../../services/auth_service.dart';
import 'customer_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _bounceAnimation;
  int _selectedIndex = 0;

  static const Color primaryColor = Color(0xFF2474E5);
  static const Color backgroundColor = Color(0xFFF9F9F9);
  static const Color primaryTextColor = Color(0xFF1A2525);
  static const Color secondaryTextColor = Color(0xFF607D8B);
  static const Color accentColor = Color(0xFFD4A017);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1200),
        );
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeInOut,
          ),
        );
        _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
          ),
        );
        _animationController!.forward();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final homeService = Provider.of<HomeService>(context, listen: false);
        homeService.fetchHomeData(context);
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
      // Đã ở Home, không cần làm gì
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/trip/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/tickets'); // Điều hướng đến TicketScreen
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
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Consumer2<HomeService, AuthService>(
          builder: (context, homeService, authService, _) {
            if (homeService.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }
            if (homeService.errorMessage != null) {
              return Center(
                child: Text(
                  homeService.errorMessage!,
                  style: GoogleFonts.poppins(
                    color: primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            if (homeService.featuredTrips.isEmpty &&
                homeService.locations.isEmpty) {
              return Center(
                child: Text(
                  'Không có dữ liệu để hiển thị.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: secondaryTextColor,
                  ),
                ),
              );
            }
            if (_fadeAnimation == null) {
              return Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }
            return SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 60.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Chào mừng, ${authService.currentUser?.fullName ?? "Khách"}!',
                            style: GoogleFonts.poppins(
                              color: primaryTextColor,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  offset: const Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 100,
                            height: 6,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Chúng tôi rất vinh dự được đồng hành cùng bạn trên mọi hành trình!',
                            style: GoogleFonts.poppins(
                              color: secondaryTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          AnimatedBuilder(
                            animation: _bounceAnimation!,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _bounceAnimation!.value,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Khám phá ngay',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Text(
                        'Chuyến đi nổi bật',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    Container(
                      height: 300,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                        homeService.featuredTrips.length > 2
                            ? 2
                            : homeService.featuredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = homeService.featuredTrips[index];
                          return Container(
                            width: 280,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Card(
                              elevation: 4,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Container(
                                      height: 160,
                                      width: double.infinity,
                                      color: primaryColor.withOpacity(0.05),
                                      child: Icon(
                                        Icons.directions_bus,
                                        size: 80,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${trip.departure_location} → ${trip.arrival_location}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: primaryTextColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Giá: ${trip.price.toStringAsFixed(0)} VNĐ',
                                          style: GoogleFonts.poppins(
                                            color: accentColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Khởi hành: ${trip.departure_time.hour}:${trip.departure_time.minute.toString().padLeft(2, '0')}',
                                          style: GoogleFonts.poppins(
                                            color: secondaryTextColor,
                                            fontSize: 12,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Text(
                        'Địa điểm phổ biến',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                        homeService.locations.length > 4
                            ? 4
                            : homeService.locations.length,
                        itemBuilder: (context, index) {
                          final location = homeService.locations[index];
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Card(
                              elevation: 4,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              color: Colors.white,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: primaryColor,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        location.location,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: primaryTextColor,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'ID: ${location.id}',
                                        style: GoogleFonts.poppins(
                                          color: secondaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}