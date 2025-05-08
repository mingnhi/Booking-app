import 'package:flutter/material.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LocationManagementScreen extends StatefulWidget {
  const LocationManagementScreen({Key? key}) : super(key: key);

  @override
  State<LocationManagementScreen> createState() => _LocationManagementScreenState();
}

class _LocationManagementScreenState extends State<LocationManagementScreen> {
  List<dynamic> locations = [];
  List<dynamic> filteredLocations = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final adminService = Provider.of<AdminService>(context, listen: false);
      final fetchedLocations = await adminService.getLocations();
      
      setState(() {
        locations = fetchedLocations;
        filteredLocations = fetchedLocations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('Error loading locations: $e');
    }
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredLocations = locations;
      } else {
        filteredLocations = locations.where((location) {
          final locationName = location['location']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          
          return locationName.contains(searchLower);
        }).toList();
      }
    });
  }

  void _showLocationDetails(BuildContext context, dynamic location) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    final createdAt = location['createdAt'] != null 
        ? DateTime.parse(location['createdAt']) 
        : null;
    final updatedAt = location['updatedAt'] != null 
        ? DateTime.parse(location['updatedAt']) 
        : null;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Chi tiết địa điểm',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('ID:', location['_id'] ?? 'N/A'),
              _buildDetailItem('Tên địa điểm:', location['location'] ?? 'N/A'),
              _buildDetailItem('Ngày tạo:', createdAt != null 
                ? formatter.format(createdAt)
                : 'N/A'),
              _buildDetailItem('Cập nhật lần cuối:', updatedAt != null 
                ? formatter.format(updatedAt)
                : 'N/A'),
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
              _editLocation(context, location);
            },
            icon: const Icon(Icons.edit),
            label: Text('Sửa', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _createNewLocation(BuildContext context) async {
    final TextEditingController _locationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tạo địa điểm mới',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Tên địa điểm',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Hủy', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_locationController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tên địa điểm'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              try {
                setState(() {
                  isLoading = true;
                });
                
                final adminService = Provider.of<AdminService>(context, listen: false);
                await adminService.createLocation(_locationController.text.trim().toUpperCase());
                
                setState(() {
                  isLoading = false;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tạo địa điểm thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                _loadLocations();
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
            },
            child: Text('Tạo', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _editLocation(BuildContext context, dynamic location) {
    final TextEditingController _locationController = TextEditingController(
      text: location['location'] ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Chỉnh sửa địa điểm',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Tên địa điểm',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Hủy', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_locationController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tên địa điểm'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              try {
                setState(() {
                  isLoading = true;
                });
                
                final adminService = Provider.of<AdminService>(context, listen: false);
                await adminService.updateLocation(
                  location['_id'], 
                  _locationController.text.trim().toUpperCase()
                );
                
                setState(() {
                  isLoading = false;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cập nhật địa điểm thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                _loadLocations();
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
            },
            child: Text('Cập nhật', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String? locationId) {
    if (locationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa: ID địa điểm không hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xác nhận xóa',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa địa điểm này không? Hành động này không thể hoàn tác.',
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
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteLocation(locationId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Xóa',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLocation(String locationId) async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final adminService = Provider.of<AdminService>(context, listen: false);
      await adminService.deleteLocation(locationId);
      
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa địa điểm thành công'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadLocations();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý địa điểm',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLocations,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm địa điểm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _filterLocations,
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewLocation(context),
        child: const Icon(Icons.add),
        tooltip: 'Thêm địa điểm mới',
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: GoogleFonts.poppins(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLocations,
              child: Text('Thử lại', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    }

    if (filteredLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Không có địa điểm nào',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thêm địa điểm mới bằng nút + bên dưới',
              style: GoogleFonts.poppins(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _buildLocationList();
  }

  Widget _buildLocationList() {
    return RefreshIndicator(
      onRefresh: _loadLocations,
      child: ListView.builder(
        itemCount: filteredLocations.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final location = filteredLocations[index];
          final createdAt = location['createdAt'] != null 
              ? DateTime.parse(location['createdAt']) 
              : null;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Icon(Icons.location_on, color: Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location['location'] ?? 'Chưa đặt tên',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (createdAt != null)
                              Text(
                                'Tạo ngày: ${DateFormat('dd/MM/yyyy').format(createdAt)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editLocation(context, location),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(context, location['_id']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
