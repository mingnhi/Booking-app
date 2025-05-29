import 'package:flutter/material.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({Key? key}) : super(key: key);

  @override
  State<VehicleManagementScreen> createState() =>
      _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  List<dynamic> vehicles = [];
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);
      final fetchedVehicles = await adminService.getVehicles();
      setState(() {
        vehicles = fetchedVehicles;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải danh sách xe: $e')));
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showAddVehicleDialog() {
    _licensePlateController.clear();
    _descriptionController.clear();
    _showVehicleDialog(null);
  }

  void _showEditVehicleDialog(dynamic vehicle) {
    _licensePlateController.text = vehicle['license_plate'] ?? '';
    _descriptionController.text = vehicle['description'] ?? '';
    _showVehicleDialog(vehicle);
  }

  void _showVehicleDialog(dynamic vehicle) {
    final isEditing = vehicle != null;
    final title = isEditing ? 'Chỉnh sửa xe' : 'Thêm xe mới';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _licensePlateController,
                      decoration: const InputDecoration(
                        labelText: 'Biển số xe',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập biển số xe';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed:
                    () => _saveVehicle(isEditing ? vehicle['_id'] : null),
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveVehicle(String? vehicleId) async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      setState(() {
        isLoading = true;
      });

      final adminService = Provider.of<AdminService>(context, listen: false);
      final vehicleData = {
        'license_plate': _licensePlateController.text,
        'description': _descriptionController.text,
      };

      try {
        if (vehicleId != null) {
          // Cập nhật xe
          await adminService.updateVehicle(vehicleData, vehicleId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật xe thành công')),
          );
        } else {
          // Thêm xe mới
          await adminService.createVehicle(vehicleData);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Thêm xe thành công')));
        }
        _loadVehicles();
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _confirmDeleteVehicle(
    String vehicleId,
    String licensePlate,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Xác nhận xóa',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text('Bạn có chắc chắn muốn xóa xe "$licensePlate"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (result == true) {
      setState(() {
        isLoading = true;
      });

      try {
        final adminService = Provider.of<AdminService>(context, listen: false);
        await adminService.deleteVehicle(vehicleId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Xóa xe thành công')));
        _loadVehicles();
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa xe: $e')));
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_bus, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Chưa có xe nào',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để thêm xe mới',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList() {
    return RefreshIndicator(
      onRefresh: _loadVehicles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
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
                        child: Text(
                          vehicle['license_plate'] ?? 'Không có biển số',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditVehicleDialog(vehicle),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => _confirmDeleteVehicle(
                              vehicle['_id'],
                              vehicle['license_plate'] ?? 'Không có biển số',
                            ),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (vehicle['description'] != null &&
                      vehicle['description'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Mô tả: ${vehicle['description']}',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  if (vehicle['createdAt'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Ngày tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(vehicle['createdAt']))}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý xe',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : vehicles.isEmpty
              ? _buildEmptyState()
              : _buildVehicleList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVehicleDialog,
        tooltip: 'Thêm xe mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}
