import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../models/location.dart';
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

    // Khởi tạo locale cho 'vi_VN'
    initializeDateFormatting('vi_VN', null).then((_) {
      Future.microtask(() async {
        if (mounted) {
          final locationService = Provider.of<LocationService>(context, listen: false);
          await locationService.fetchLocations();
          setState(() {});
        }
      });
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

      // Lưu tìm kiếm gần đây với tripId nếu có kết quả
      if (_departureId != null && _arrivalId != null && results.isNotEmpty) {
        // Lấy tripId từ chuyến đi đầu tiên trong kết quả
        final tripId = results[0].id;
        tripService.addRecentSearch(
          _departureId!,
          _arrivalId!,
          DateTime.now(),
          tripId: tripId, // Lưu tripId
        );
      }

      Navigator.pushNamed(
        context,
        '/trip/list',
        arguments: {
          'trips': results,
          'departureId': _departureId,
          'arrivalId': _arrivalId,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tìm kiếm chuyến đi: $e')),
      );
    }
  }

  void _selectRecentSearch(Map<String, dynamic> search) {
    setState(() {
      _departureId = search['departureId'];
      _arrivalId = search['arrivalId'];
      _departureTime = null; // Không cần ngày
    });
  }

  void _navigateToTripDetail(String tripId) {
    Navigator.pushNamed(
      context,
      '/trip/detail/id',
      arguments: tripId, // Truyền tripId trực tiếp
    );
  }

  void _viewAllRecentSearches() {
    print("Xem tất cả tìm kiếm gần đây");
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
              print('Recent searches length: ${tripService.recentSearches.length}');
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
                                  prefixIcon: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF2474E5), // Màu xanh
                                        ),
                                      ),
                                      Container(
                                        width: 10,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
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
                                  prefixIcon: const Icon(Icons.location_on, color: Colors.redAccent, size: 30),
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
                              InkWell(
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
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Ngày đi',
                                    labelStyle: GoogleFonts.poppins(color: Colors.blueGrey.shade800),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF2474E5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF2474E5), width: 2),
                                    ),
                                    prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF2474E5)),
                                  ),
                                  child: Text(
                                    _departureTime != null
                                        ? DateFormat('dd/MM/yyyy').format(_departureTime!)
                                        : 'Chọn ngày',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _departureId != null && _arrivalId != null ? _searchTrips : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD333),
                                    foregroundColor: Colors.black,
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
                      // Phần Tìm kiếm gần đây
                      if (tripService.recentSearches.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tìm kiếm gần đây',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100, // Chiều cao cố định cho danh sách ngang
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal, // Chuyển sang chiều ngang
                            itemCount: tripService.recentSearches.length,
                            itemBuilder: (context, index) {
                              final search = tripService.recentSearches[index];
                              final departureLoc = locationService.locations
                                  .firstWhere(
                                    (loc) => loc.id == search['departureId'],
                                orElse: () => Location(id: '', location: 'Không rõ', contact_phone: ''),
                              )
                                  .location;
                              final arrivalLoc = locationService.locations
                                  .firstWhere(
                                    (loc) => loc.id == search['arrivalId'],
                                orElse: () => Location(id: '', location: 'Không rõ', contact_phone: ''),
                              )
                                  .location;

                              final tripId = search['tripId'] as String?;

                              return GestureDetector(
                                onTap:_departureId != null && _arrivalId != null ? _searchTrips : null,
                                child: Card(
                                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  child: Container(
                                    width: 200, // Chiều rộng cố định
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Cột chứa Điểm đi và Điểm đến
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Khung 1: Điểm đi
                                              Row(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        width: 15,
                                                        height: 12,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: const Color(0xFF2474E5), // Màu xanh
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 4,
                                                        height: 4,
                                                        decoration: const BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      departureLoc,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Đường đứt đứng giữa hai khung
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: List.generate(3, (index) => const Icon(
                                                    Icons.circle,
                                                    size: 4,
                                                    color: Colors.grey,
                                                  )).map((dot) => Padding(
                                                    padding: const EdgeInsets.only(bottom: 2.0),
                                                    child: dot,
                                                  )).toList(),
                                                ),
                                              ),
                                              // Khung 3: Điểm đến
                                              Row(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        width: 15,
                                                        height: 12,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.redAccent, // Màu đỏ
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 4,
                                                        height: 4,
                                                        decoration: const BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      arrivalLoc,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Dấu mũi tên ở góc phải
                                        const Icon(
                                          Icons.arrow_forward,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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