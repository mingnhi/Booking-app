import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/location_service.dart';

class LocationCreateScreen extends StatefulWidget {
  const LocationCreateScreen({super.key});

  @override
  State<LocationCreateScreen> createState() => _LocationCreateScreenState();
}

class _LocationCreateScreenState extends State<LocationCreateScreen> {
  final _locationController = TextEditingController();
  bool _isLoading = false;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _createLocation() async {
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên địa điểm')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final locationService = Provider.of<LocationService>(
        context,
        listen: false,
      );
      final result = await locationService.createLocation(
        _locationController.text.toUpperCase(),
      );

      if (!mounted || _isDisposed) return;

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        if (!mounted || _isDisposed) return;
        
        Navigator.of(context).pop(true); // Trả về true để báo hiệu thành công
      } else {
        if (!mounted || _isDisposed) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo địa điểm thất bại')),
        );
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo địa điểm')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
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
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createLocation,
                    child: const Text('Lưu'),
                  ),
                ],
              ),
      ),
    );
  }
}
