import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/trip.dart';

class TripService extends ChangeNotifier {
  final String baseUrl = 'https://booking-app-1-bzfs.onrender.com'; // Thay bằng URL backend thực tế
  final _storage = FlutterSecureStorage();
  bool isLoading = false;
  List<Trip> trips = [];

  Future<void> fetchTrips() async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trip'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        trips = (jsonDecode(response.body) as List).map((e) => Trip.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch trips: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching trips: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Trip>> searchTrips(String departureId, String arrivalId) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trip/search?departure=$departureId&arrival=$arrivalId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List).map((e) => Trip.fromJson(e)).toList();
      } else {
        throw Exception('Failed to search trips: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error searching trips: $e');
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Trip?> createTrip(Trip trip) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/trip'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode(trip.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Trip.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create trip: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating trip: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Trip?> updateTrip(String id, Trip trip) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/trip/$id'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode(trip.toJson()),
      );
      if (response.statusCode == 200) {
        return Trip.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update trip: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating trip: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTrip(String id) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/trip/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting trip: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}