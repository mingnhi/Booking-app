import 'package:flutter/material.dart';
import 'package:frontend/screens/admin/trip_create_form.dart';
import 'package:frontend/screens/admin/trip_edit_form.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:frontend/models/trip.dart'; // Thêm import cho model Trip
import 'package:frontend/services/location_service.dart'; // Thêm import cho LocationService
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TripManagementScreen extends StatefulWidget {
  const TripManagementScreen({Key? key}) : super(key: key);

  @override
  State<TripManagementScreen> createState() => _TripManagementScreenState();
}

class _TripManagementScreenState extends State<TripManagementScreen> {
  List<Trip> trips = []; // Thay đổi kiểu dữ liệu thành List<Trip>
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTrips();
    // Tải danh sách địa điểm để hiển thị tên
    Provider.of<LocationService>(context, listen: false).fetchLocations();
  }

  Future<void> _loadTrips() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);
      final fetchedTripsData = await adminService.getTrips();

      // Chuyển đổi dữ liệu thô thành danh sách Trip
      final List<Trip> fetchedTrips =
<<<<<<< HEAD
          fetchedTripsData.map((tripData) {
            return Trip.fromJson(tripData);
          }).toList();
=======
      fetchedTripsData.map((tripData) {
        return Trip.fromJson(tripData);
      }).toList();
>>>>>>> 60d88a48252e53f6c09afec0693649d7f779f123

      setState(() {
        trips = fetchedTrips;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Phương thức để lấy tên địa điểm từ ID
  Future<String> _getLocationName(String locationId) async {
    if (locationId.isEmpty) {
      return 'N/A';
    }

    try {
      final locationService = Provider.of<LocationService>(
        context,
        listen: false,
      );
      final locations = locationService.locations;

      for (var loc in locations) {
        if (loc.id == locationId) {
          return loc.location;
        }
      }

      return locationId;
    } catch (e) {
      print('Error getting location name: $e');
      return locationId;
    }
  }

  // Phương thức hiển thị dialog xác nhận xóa
  void _showDeleteConfirmation(BuildContext context, String tripId) {
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
<<<<<<< HEAD
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  'Xác nhận xóa',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'Bạn có chắc chắn muốn xóa chuyến đi này không?',
                  style: GoogleFonts.poppins(),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Hủy', style: GoogleFonts.poppins()),
                  ),
                  ElevatedButton(
                    onPressed:
                        isSubmitting
                            ? null
                            : () async {
                              setState(() {
                                isSubmitting = true;
                              });

                              try {
                                final adminService = Provider.of<AdminService>(
                                  context,
                                  listen: false,
                                );

                                // Gọi API xóa chuyến đi
                                final success = await adminService.deleteTrip(
                                  tripId,
                                );

                                // Đóng dialog
                                Navigator.of(context).pop();

                                if (success) {
                                  // Hiển thị thông báo thành công
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Đã xóa chuyến đi thành công',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  // Tải lại danh sách chuyến đi
                                  _loadTrips();
                                } else {
                                  // Hiển thị thông báo lỗi
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Không thể xóa chuyến đi',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Hiển thị thông báo lỗi
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Lỗi: ${e.toString()}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );

                                setState(() {
                                  isSubmitting = false;
                                });
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      'Xóa chuyến đi',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
=======
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Xác nhận xóa',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Bạn có chắc chắn muốn xóa chuyến đi này không?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Hủy', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed:
                isSubmitting
                    ? null
                    : () async {
                  setState(() {
                    isSubmitting = true;
                  });

                  try {
                    final adminService = Provider.of<AdminService>(
                      context,
                      listen: false,
                    );

                    // Gọi API xóa chuyến đi
                    final success = await adminService.deleteTrip(
                      tripId,
                    );

                    // Đóng dialog
                    Navigator.of(context).pop();

                    if (success) {
                      // Hiển thị thông báo thành công
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã xóa chuyến đi thành công',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Tải lại danh sách chuyến đi
                      _loadTrips();
                    } else {
                      // Hiển thị thông báo lỗi
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Không thể xóa chuyến đi',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    // Hiển thị thông báo lỗi
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Lỗi: ${e.toString()}',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );

                    setState(() {
                      isSubmitting = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  'Xóa chuyến đi',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
>>>>>>> 60d88a48252e53f6c09afec0693649d7f779f123
    );
  }

  // Phương thức hiển thị chi tiết chuyến đi
  void _showTripDetails(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (context) {
        final formatter = DateFormat('dd/MM/yyyy HH:mm');

        return AlertDialog(
          title: Text(
            'Chi tiết chuyến đi',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('ID:', trip.id),
                FutureBuilder<String>(
                  future: _getLocationName(trip.departure_location),
                  builder: (context, snapshot) {
                    return _buildDetailItem(
                      'Điểm đi:',
                      snapshot.data ?? trip.departure_location,
                    );
                  },
                ),
                FutureBuilder<String>(
                  future: _getLocationName(trip.arrival_location),
                  builder: (context, snapshot) {
                    return _buildDetailItem(
                      'Điểm đến:',
                      snapshot.data ?? trip.arrival_location,
                    );
                  },
                ),
                _buildDetailItem(
                  'Thời gian đi:',
                  formatter.format(trip.departure_time),
                ),
                _buildDetailItem(
                  'Thời gian đến:',
                  formatter.format(trip.arrival_time),
                ),
                _buildDetailItem(
                  'Giá vé:',
                  '${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(trip.price)}',
                ),
                _buildDetailItem('Loại xe:', trip.vehicle_id),
                _buildDetailItem('Tổng số ghế:', '${trip.totalSeats}'),
                _buildDetailItem('Khoảng cách:', '${trip.distance} km'),
                if (trip.createdAt != null)
                  _buildDetailItem(
                    'Ngày tạo:',
                    formatter.format(trip.createdAt!),
                  ),
                if (trip.updatedAt != null)
                  _buildDetailItem(
                    'Cập nhật lần cuối:',
                    formatter.format(trip.updatedAt!),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Đóng', style: GoogleFonts.poppins()),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _editTrip(context, trip.id);
              },
              icon: const Icon(Icons.edit),
              label: Text('Sửa', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  // Phương thức để mở màn hình chỉnh sửa chuyến đi
  void _editTrip(BuildContext context, String tripId) async {
    try {
      setState(() {
        isLoading = true;
      });

      final adminService = Provider.of<AdminService>(context, listen: false);
      final tripData = await adminService.getTripDetail(tripId);

      setState(() {
        isLoading = false;
      });

      // Mở form chỉnh sửa với dữ liệu đã lấy
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripEditForm(tripData: tripData),
        ),
      );

      // Nếu chỉnh sửa thành công, tải lại danh sách
      if (result == true) {
        _loadTrips();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Phương thức để mở form tạo chuyến đi mới
  void _createNewTrip(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripCreateForm()),
    );

    // Nếu tạo thành công, tải lại danh sách
    if (result == true) {
      _loadTrips();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error!,
                style: GoogleFonts.poppins(),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTrips,
              icon: const Icon(Icons.refresh),
              label: Text('Thử lại', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    }

    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_bus_filled_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có chuyến đi nào',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _createNewTrip(context),
              icon: const Icon(Icons.add),
              label: Text('Thêm chuyến đi mới', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTrips,
        child: ListView.builder(
          itemCount: trips.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final trip = trips[index];
            final formatter = DateFormat('dd/MM/yyyy HH:mm');

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<String>(
                            future: _getLocationName(trip.departure_location),
                            builder: (context, departureSnapshot) {
                              final departureName =
                                  departureSnapshot.data ??
<<<<<<< HEAD
                                  trip.departure_location;
=======
                                      trip.departure_location;
>>>>>>> 60d88a48252e53f6c09afec0693649d7f779f123
                              return FutureBuilder<String>(
                                future: _getLocationName(trip.arrival_location),
                                builder: (context, arrivalSnapshot) {
                                  final arrivalName =
                                      arrivalSnapshot.data ??
<<<<<<< HEAD
                                      trip.arrival_location;
=======
                                          trip.arrival_location;
>>>>>>> 60d88a48252e53f6c09afec0693649d7f779f123
                                  return Text(
                                    '$departureName → $arrivalName',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: 'đ',
                          ).format(trip.price),
                          style: GoogleFonts.poppins(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Khởi hành',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formatter.format(trip.departure_time),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đến nơi',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formatter.format(trip.arrival_time),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Loại xe',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                trip.vehicle_id,
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Số ghế',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${trip.totalSeats}',
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showTripDetails(context, trip),
                          icon: const Icon(Icons.visibility),
                          label: Text('Chi tiết', style: GoogleFonts.poppins()),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _editTrip(context, trip.id),
                          icon: const Icon(Icons.edit),
                          label: Text('Sửa', style: GoogleFonts.poppins()),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed:
                              () => _showDeleteConfirmation(context, trip.id),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          label: Text('Xóa', style: GoogleFonts.poppins()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewTrip(context),
        child: const Icon(Icons.add),
        tooltip: 'Thêm chuyến đi mới',
      ),
    );
  }
}
