import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/trip_service.dart';
import '../../services/location_service.dart';

class TripSearchScreen extends StatefulWidget {
  @override
  _TripSearchScreenState createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen> with SingleTickerProviderStateMixin {
  String? _departureId;
  String? _arrivalId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Set status bar to match gradient's top color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent.shade100,
      statusBarIconBrightness: Brightness.light,
    ));
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    Provider.of<LocationService>(context, listen: false).fetchLocations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Reset status bar when leaving screen
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true, // Extend gradient behind bottom navigation bar
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Tìm Kiếm Chuyến Đi',
          style: GoogleFonts.robotoCondensed(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent.shade100.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height, // Full screen height
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
          child: Consumer2<TripService, LocationService>(
            builder: (context, tripService, locationService, _) {
              if (locationService.isLoading) {
                return Center(child: CircularProgressIndicator());
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
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tìm Chuyến Đi Lý Tưởng',
                        style: GoogleFonts.roboto(
                          color: Colors.blueAccent,
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Chọn điểm đi và điểm đến để bắt đầu',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 24),
                      Card(
                        elevation: 12,
                        shadowColor: Colors.blueAccent.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.blueAccent.shade100.withOpacity(0.5), width: 1),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: _departureId,
                                decoration: InputDecoration(
                                  labelText: 'Điểm Đi',
                                  labelStyle: GoogleFonts.poppins(
                                    color: Colors.blueGrey.shade800,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blueAccent.shade400),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blueAccent.shade400, width: 2),
                                  ),
                                  prefixIcon: Icon(Icons.location_on, color: Colors.blueAccent.shade400),
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
                              SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _arrivalId,
                                decoration: InputDecoration(
                                  labelText: 'Điểm Đến',
                                  labelStyle: GoogleFonts.poppins(
                                    color: Colors.blueGrey.shade800,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blueAccent.shade400),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blueAccent.shade400, width: 2),
                                  ),
                                  prefixIcon: Icon(Icons.location_on, color: Colors.blueAccent.shade400),
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
                              SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _departureId != null && _arrivalId != null
                                      ? () async {
                                    await tripService.searchTrips(_departureId!, _arrivalId!);
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent.shade400,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Tìm Kiếm Chuyến Đi',
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
                      SizedBox(height: 24),
                      Text(
                        'Kết Quả Tìm Kiếm',
                        style: GoogleFonts.roboto(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      SizedBox(height: 16),
                      tripService.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : tripService.trips.isEmpty
                          ? Center(
                        child: Text(
                          'Không tìm thấy chuyến đi nào.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: tripService.trips.length,
                        itemBuilder: (context, index) {
                          final trip = tripService.trips[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 10,
                            shadowColor: Colors.blueAccent.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.blueAccent.shade100.withOpacity(0.5), width: 1),
                            ),
                            color: Colors.white.withOpacity(0.95),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              leading: Icon(
                                Icons.directions_bus,
                                color: Colors.blueAccent.shade400,
                                size: 32,
                              ),
                              title: Text(
                                '${trip.departureLocation} → ${trip.arrivalLocation}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    'Giá: ${trip.price.toStringAsFixed(0)} VNĐ',
                                    style: GoogleFonts.poppins(
                                      color: Colors.blueAccent.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 4),
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
    );
  }
}