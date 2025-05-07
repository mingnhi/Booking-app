import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/home_service.dart';
import 'customer_nav_bar.dart'; // Import CustomNavBar

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  int _selectedIndex = 0; // Chỉ số hiện tại của thanh điều hướng

  @override
  void initState() {
    super.initState();
    // Khởi tạo AnimationController và FadeAnimation an toàn
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeService = Provider.of<HomeService>(context, listen: false);
      homeService.fetchHomeData(context);
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home'); // Điều hướng đến Tìm kiếm
        break;
      case 1:
        Navigator.pushNamed(context, '/trip/search'); // Điều hướng đến Vé của tôi
        break;
      case 2:
        Navigator.pushNamed(context, '/my-tickets'); // Điều hướng đến Thông báo
        break;
      case 3:
        Navigator.pushNamed(context, '/auth/profile'); // Điều hướng đến Tài khoản
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true, // Extend gradient behind bottom navigation bar
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/vexere_logo.png', // Đường dẫn đến hình ảnh logo
          height: 40, // Chiều cao logo
          fit: BoxFit.contain, // Điều chỉnh kích thước hình ảnh
        ),
        backgroundColor: Colors.blueAccent.shade100.withOpacity(0.8),
        elevation: 0,
        automaticallyImplyLeading: false, // Xóa nút quay lại
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/auth/profile'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Consumer<HomeService>(
            builder: (context, homeService, _) {
              if (homeService.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (homeService.errorMessage != null) {
                return Center(
                  child: Text(
                    homeService.errorMessage!,
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              if (homeService.featuredTrips.isEmpty && homeService.locations.isEmpty) {
                return Center(
                  child: Text(
                    'Không có dữ liệu để hiển thị.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                );
              }
              if (_fadeAnimation == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnimation!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Khám phá hành trình!',
                              style: GoogleFonts.poppins(
                                color: Colors.blueAccent,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tìm chuyến xe phù hợp với bạn ngay hôm nay',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, '/trip/search'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  'Tìm chuyến đi ngay',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Text(
                          'Chuyến đi nổi bật',
                          style: GoogleFonts.roboto(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                      Container(
                        height: 280,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: homeService.featuredTrips.length,
                          itemBuilder: (context, index) {
                            final trip = homeService.featuredTrips[index];
                            return Container(
                              width: 240,
                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Card(
                                elevation: 12,
                                shadowColor: Colors.blueAccent.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                      color: Colors.blueAccent.shade100.withOpacity(0.5), width: 1),
                                ),
                                color: Colors.white.withOpacity(0.95),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: Container(
                                        height: 160,
                                        width: double.infinity,
                                        color: Colors.blue.shade50,
                                        child: Icon(
                                          Icons.directions_bus,
                                          size: 80,
                                          color: Colors.blueAccent.shade400,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${trip.departureLocation} → ${trip.arrivalLocation}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.blueGrey.shade800,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Giá: ${trip.price.toStringAsFixed(0)} VNĐ',
                                            style: GoogleFonts.poppins(
                                              color: Colors.blueAccent.shade400,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Khởi hành: ${trip.departureTime.hour}:${trip.departureTime.minute.toString().padLeft(2, '0')}',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey.shade600,
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
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Text(
                          'Địa điểm phổ biến',
                          style: GoogleFonts.roboto(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: homeService.locations.length,
                          itemBuilder: (context, index) {
                            final location = homeService.locations[index];
                            return Card(
                              elevation: 10,
                              shadowColor: Colors.blueAccent.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                    color: Colors.blueAccent.shade100.withOpacity(0.5), width: 1),
                              ),
                              color: Colors.white.withOpacity(0.95),
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.blueAccent.shade400,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        location.location,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey.shade800,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: ${location.id}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent.shade400,
        onPressed: () => Navigator.pushNamed(context, '/trip/search'),
        child: const Icon(Icons.search, color: Colors.white),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}