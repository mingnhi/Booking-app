import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';

class TripService extends ChangeNotifier {
  final String baseUrl = 'https://booking-app-1-bzfs.onrender.com';
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
        final List<dynamic> data = jsonDecode(response.body);
        trips = data.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to fetch trips: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching trips: $e');
      trips = [];
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Trip>> searchTrips({
    String? departureLocation,
    String? arrivalLocation,
    DateTime? departureTime,
  }) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');
    try {
      final body = {
        if (departureLocation != null) 'departure_location': departureLocation,
        if (arrivalLocation != null) 'arrival_location': arrivalLocation,
        if (departureTime != null) 'departure_time': DateFormat('yyyy-MM-dd').format(departureTime),
      };
      print('Search trips request body (TripService): $body');
      final response = await http.post(
        Uri.parse('$baseUrl/trip/search'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      print('Search trips response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        trips = data.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
        return trips;
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

  Future<void> fetchTripById(String tripId) async {
    if (tripId.isEmpty) {
      throw Exception('Trip ID cannot be empty');
    }
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');
    try {
      print('Fetching trip with ID: $tripId');
      final response = await http.get(
        Uri.parse('$baseUrl/trip/$tripId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Fetch trip response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final trip = Trip.fromJson(data);
        final index = trips.indexWhere((t) => t.id == tripId);
        if (index != -1) {
          trips[index] = trip;
        } else {
          trips.add(trip);
        }
      } else {
        throw Exception('Failed to fetch trip: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching trip by ID: $e');
      rethrow;
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
        Uri.parse('$baseUrl/admin/trip'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode(trip.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final newTrip = Trip.fromJson(data);
        trips.add(newTrip);
        return newTrip;
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
        Uri.parse('$baseUrl/admin/trip/$id'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode(trip.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final updatedTrip = Trip.fromJson(data);
        final index = trips.indexWhere((t) => t.id == id);
        if (index != -1) {
          trips[index] = updatedTrip;
        }
        return updatedTrip;
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
        Uri.parse('$baseUrl/admin/trip/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        trips.removeWhere((t) => t.id == id);
        return true;
      } else {
        throw Exception('Failed to delete trip: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error deleting trip: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}