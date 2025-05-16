import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminService extends ChangeNotifier {
  final String baseUrl = 'https://booking-app-1-bzfs.onrender.com';
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> _getValidToken() async {
    var token = await _storage.read(key: 'accessToken');
    if (token == null) {
      throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/check-token'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      final refreshToken = await _storage.read(key: 'refreshToken');
      if (refreshToken == null) {
        throw Exception('Không tìm thấy refresh token.');
      }

      final refreshResponse = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (refreshResponse.statusCode == 200) {
        final newToken = jsonDecode(refreshResponse.body)['accessToken'];
        await _storage.write(key: 'accessToken', value: newToken);
        return newToken;
      } else {
        throw Exception('Không thể refresh token.');
      }
    }

    return token;
  }

  Future<List<dynamic>> getTrips() async {
    _isLoading = true;
    _error = null;
    // Không gọi notifyListeners() ở đây

    try {
      final token = await _getValidToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/trip'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load trips: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error in getTrips: $e');
      rethrow; // Ném lại lỗi để widget xử lý
    }
  }

  Future<List<dynamic>> getUsers() async {
    _isLoading = true;
    _error = null;

    try {
      final token = await _getValidToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error in getUsers: $e');
      rethrow;
    }
  }

  Future<void> updateUser(Map<String, dynamic> updatedUser) async {
    final String userId = updatedUser['_id'];
    final token = await _getValidToken();
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedUser),
    );

    if (response.statusCode != 200) {
      throw Exception('Cập nhật người dùng thất bại');
    }
  }

  Future<List<dynamic>> getTickets() async {
    _isLoading = true;
    _error = null;

    try {
      final token = await _getValidToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/ticket'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error in getTickets: $e');
      rethrow;
    }
  }

  Future<dynamic> getTicketDetail(String ticketId) async {
    _isLoading = true;
    _error = null;

    try {
      final token = await _getValidToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/ticket/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load ticket details: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error in getTicketDetail: $e');
      throw e;
    }
  }

  Future<List<dynamic>> getSeats() async {
    _isLoading = true;
    _error = null;

    try {
      final token = await _getValidToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/seat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load seats: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error in getSeats: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTicketStatus(String ticketId, String status) async {
    _isLoading = true;
    _error = null;

    try {
      final token = await _getValidToken();
      print('Calling PUT $baseUrl/admin/ticket/$ticketId with status: $status');

      final response = await http.put(
        Uri.parse('$baseUrl/admin/ticket/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'ticket_status': status}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        _isLoading = false;
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to update ticket status: ${response.statusCode} - ${errorBody['message'] ?? response.body}',
        );
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error in updateTicketStatus: $e');
      throw e;
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    _isLoading = true;
    _error = null;

    try {
      final token = await _getValidToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/ticket/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
      } else {
        throw Exception('Failed to delete ticket: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error in deleteTicket: $e');
      throw e;
    }
  }

  Future<dynamic> getTripDetail(String tripId) async {
    _isLoading = true;
    _error = null;

    try {
      final token = await _getValidToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/trip/$tripId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load trip details: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error in getTripDetail: $e');
      throw e;
    }
  }

  Future<dynamic> updateTrip(String tripId, Map<String, dynamic> tripData) async {
    _isLoading = true;
    _error = null;

    try {
      final token = await _getValidToken();
      print('Calling PUT $baseUrl/admin/trip/$tripId with data: $tripData');

      final response = await http.put(
        Uri.parse('$baseUrl/admin/trip/$tripId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(tripData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        _isLoading = false;
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to update trip: ${response.statusCode} - ${errorBody['message'] ?? response.body}',
        );
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error in updateTrip: $e');
      throw e;
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    _isLoading = true;
    _error = null;

    try {
      final token = await _getValidToken();
      print('Calling DELETE $baseUrl/admin/trip/$tripId');

      final response = await http.delete(
        Uri.parse('$baseUrl/admin/trip/$tripId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        _isLoading = false;
        return true;
      } else {
        throw Exception('Failed to delete trip: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error in deleteTrip: $e');
      rethrow;
    }
  }

  Future<dynamic> createTrip(Map<String, dynamic> tripData) async {
    _isLoading = true;
    _error = null;

    try {
      final token = await _getValidToken();
      print('Calling POST $baseUrl/admin/trip with data: $tripData');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/trip'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(tripData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        _isLoading = false;
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create trip: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Error in createTrip: $e');
      throw e;
    }
  }
}