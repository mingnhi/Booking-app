import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/location.dart';

class LocationService extends ChangeNotifier {
  final String baseUrl = 'https://booking-app-1-bzfs.onrender.com'; // Thay bằng URL backend thực tế
  final _storage = FlutterSecureStorage();
  bool isLoading = false;
  List<Location> locations = [];

  Future<void> fetchLocations() async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/location'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        locations = (jsonDecode(response.body) as List).map((e) => Location.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch locations: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching locations: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Location?> createLocation(String location) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/location'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'location': location}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Location.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create location: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating location: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Location?> updateLocation(String id, String location) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/location/$id'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'location': location}),
      );
      if (response.statusCode == 200) {
        return Location.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update location: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating location: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteLocation(String id) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/location/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting location: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}