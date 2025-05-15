import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminService extends ChangeNotifier {
  // Sử dụng URL giống với các service khác
  final String baseUrl = 'https://booking-app-1-bzfs.onrender.com';
  final _storage = const FlutterSecureStorage();
  bool isLoading = false;
  String? error;

  // Trips
  Future<List<dynamic>> getTrips() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/trip'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load trips: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error in getTrips: $e');
      return [];
    }
  }

  // Users - Cập nhật endpoint chính xác
  Future<List<dynamic>> getUsers() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error in getUsers: $e');
      return [];
    }
  }
  //Cập nhật user

  Future<void> updateUser(Map<String, dynamic> updatedUser) async {
    final String userId = updatedUser['_id'];
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
    }
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

  // Tickets - Cập nhật endpoint chính xác
  Future<List<dynamic>> getTickets() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      // Dựa vào backend/src/ticket/ticket.controller.ts, endpoint là /tickets
      final response = await http.get(
        Uri.parse('$baseUrl/admin/ticket'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error in getTickets: $e');
      return [];
    }
  }

  // Xem chi tiết vé
  Future<dynamic> getTicketDetail(String ticketId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/ticket/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load ticket details: ${response.statusCode}',
        );
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error in getTicketDetail: $e');
      throw e;
    }
  }

  // Seats - Cập nhật endpoint chính xác
  Future<List<dynamic>> getSeats() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      // Dựa vào backend/src/seat/seat.controller.ts, endpoint là /seats
      final response = await http.get(
        Uri.parse('$baseUrl/admin/seat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load seats: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error in getSeats: $e');
      return [];
    }
  }

  // Cập nhật trạng thái vé
  Future<void> updateTicketStatus(String ticketId, String status) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/admin/ticket/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'ticket_status': status}),
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
      } else {
        throw Exception(
          'Failed to update ticket status: ${response.statusCode}',
        );
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error in updateTicketStatus: $e');
      throw e;
    }
  }

  // Xóa vé
  Future<void> deleteTicket(String ticketId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/admin/ticket/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to delete ticket: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error in deleteTicket: $e');
      throw e;
    }
  }

  // Thêm phương thức lấy chi tiết chuyến đi
  Future<dynamic> getTripDetail(String tripId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/trip/$tripId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load trip details: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error in getTripDetail: $e');
      throw e;
    }
  }

  // Thêm phương thức cập nhật chuyến đi
  Future<dynamic> updateTrip(
      String tripId,
      Map<String, dynamic> tripData,
      ) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      print('Calling PUT $baseUrl/trip/$tripId with data: $tripData');

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
        final data = jsonDecode(response.body);
        isLoading = false;
        notifyListeners();
        return data;
      } else {
        throw Exception(
          'Failed to update trip: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error in updateTrip: $e');
      throw e;
    }
  }

  // Thêm phương thức xóa chuyến đi
  Future<bool> deleteTrip(String tripId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      print('Calling DELETE $baseUrl/trip/$tripId');

      final response = await http.delete(
        Uri.parse('$baseUrl/admin/trip/$tripId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to delete trip: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error in deleteTrip: $e');
      return false;
    }
  }

  // Thêm phương thức tạo chuyến đi mới
  Future<dynamic> createTrip(Map<String, dynamic> tripData) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

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
        final data = jsonDecode(response.body);
        isLoading = false;
        notifyListeners();
        return data;
      } else {
        throw Exception(
          'Failed to create trip: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error in createTrip: $e');
      throw e;
    }
  }
}
