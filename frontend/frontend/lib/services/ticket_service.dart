import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/ticket.dart';

class TicketService extends ChangeNotifier {
  final String baseUrl = 'https://booking-app-1-bzfs.onrender.com';
  final _storage = FlutterSecureStorage();
  bool isLoading = false;
  List<Ticket> tickets = [];

  Future<void> fetchTickets() async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        tickets = (jsonDecode(response.body) as List)
            .map((e) => Ticket.fromJson(e))
            .toList();
      } else {
        throw Exception('Lấy danh sách ticket thất bại: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi lấy danh sách ticket: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Ticket?> createTicket(Map<String, dynamic> ticketData) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(ticketData),
      );
      if (response.statusCode == 200) {
        final newTicket = Ticket.fromJson(jsonDecode(response.body));
        tickets.add(newTicket);
        return newTicket;
      } else {
        throw Exception('Tạo ticket thất bại: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi tạo ticket: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Ticket?> updateTicket(String id, Map<String, dynamic> ticketData) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tickets/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(ticketData),
      );
      if (response.statusCode == 200) {
        final updatedTicket = Ticket.fromJson(jsonDecode(response.body));
        final index = tickets.indexWhere((ticket) => ticket.id == id);
        if (index != -1) {
          tickets[index] = updatedTicket;
        }
        return updatedTicket;
      } else {
        throw Exception('Cập nhật ticket thất bại: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi cập nhật ticket: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTicket(String id) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tickets/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        tickets.removeWhere((ticket) => ticket.id == id);
        return true;
      } else {
        throw Exception('Xóa ticket thất bại: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi xóa ticket: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Ticket?> fetchTicketById(String id) async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Lấy ticket thất bại: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi lấy ticket theo id: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}