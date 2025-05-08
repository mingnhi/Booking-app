import 'package:flutter/material.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SeatManagementScreen extends StatefulWidget {
  const SeatManagementScreen({Key? key}) : super(key: key);

  @override
  _SeatManagementScreenState createState() => _SeatManagementScreenState();
}

class _SeatManagementScreenState extends State<SeatManagementScreen> {
  List<dynamic> seats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    final adminService = Provider.of<AdminService>(context, listen: false);
    final fetchedSeats = await adminService.getSeats();
    setState(() {
      seats = fetchedSeats;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : seats.isEmpty
              ? _buildEmptyState()
              : _buildSeatList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Hiển thị form thêm ghế
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm ghế mới',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_seat, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Chưa có ghế nào',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để thêm ghế mới',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatList() {
    return RefreshIndicator(
      onRefresh: _loadSeats,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: seats.length,
        itemBuilder: (context, index) {
          final seat = seats[index];
          return Card(
            elevation: 2,
            child: InkWell(
              onTap: () {
                // Hiển thị chi tiết ghế
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ghế ${seat['seatNumber']}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: seat['isAvailable'] ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            seat['isAvailable'] ? 'Trống' : 'Đã đặt',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      'Loại: ${seat['seatType']}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chuyến: ${seat['tripId']}',
                      style: GoogleFonts.poppins(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}