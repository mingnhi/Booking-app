import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/location_service.dart';

class LocationEditScreen extends StatefulWidget {
  final String id;

  const LocationEditScreen({super.key, required this.id});

  @override
  State<LocationEditScreen> createState() => _LocationEditScreenState();
}

class _LocationEditScreenState extends State<LocationEditScreen> {
  final _locationController = TextEditingController();
  bool _isLoading = false;
  bool _isDisposed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chuyển logic từ initState sang didChangeDependencies để đảm bảo context sẵn sàng
    final locationService = Provider.of<LocationService>(
      context,
      listen: false,
    );
    final location = locationService.locations.firstWhere(
      (loc) => loc.id == widget.id,
      orElse:
          () => throw Exception('Không tìm thấy địa điểm với ID: ${widget.id}'),
    );
    _locationController.text = location.location ?? '';
  }

  Future<void> _updateLocation() async {
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên địa điểm')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Hiển thị loading
    });

    try {
      final locationService = Provider.of<LocationService>(
        context,
        listen: false,
      );
      final result = await locationService.updateLocation(
        widget.id,
        _locationController.text,
      );

      // Kiểm tra xem widget còn mounted không trước khi cập nhật state
      if (!mounted || _isDisposed) return;

      setState(() {
        _isLoading = false;
      });
      
      if (result != null) {
        // Đánh dấu là đã xử lý thành công
        if (!mounted || _isDisposed) return;
        
        // Điều hướng sau khi API hoàn tất
        Navigator.of(context).pop(true); // Trả về true để báo hiệu thành công
      } else {
        if (!mounted || _isDisposed) return;
        
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại')));
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa địa điểm')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Tên địa điểm',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateLocation,
                      child: const Text('Cập nhật'),
                    ),
                  ],
                ),
      ),
    );
  }
}
