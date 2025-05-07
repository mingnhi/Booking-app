import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/auth.dart';

class AuthService extends ChangeNotifier {
  final String baseUrl = 'https://booking-app-1-bzfs.onrender.com';
  final _storage = FlutterSecureStorage(); // Vẫn giữ private
  bool isLoading = false;
  String? errorMessage;
  User? currentUser;

  // Thêm phương thức public để lấy token
  Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<LoginResponse?> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refresh_token']);
        return LoginResponse.fromJson(data);
      } else {
        throw Exception('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error logging in: $e');
      errorMessage = e.toString().contains('Login failed')
          ? jsonDecode(e.toString().split(' - ')[1])['message']
          : e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(RegisterRequest request) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Registration failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error registering: $e');
      errorMessage = e.toString().contains('Registration failed')
          ? jsonDecode(e.toString().split(' - ')[1])['message']
          : e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> getProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      errorMessage = 'No access token found';
      isLoading = false;
      notifyListeners();
      return null;
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        print('Profile Response: ${response.body}'); // Log để kiểm tra
        currentUser = User.fromJson(jsonDecode(response.body));
        return currentUser;
      } else {
        throw Exception('Failed to get profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting profile: $e');
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<LoginResponse?> refreshToken() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) {
      errorMessage = 'No refresh token found';
      isLoading = false;
      notifyListeners();
      return null;
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refresh_token']);
        return LoginResponse.fromJson(data);
      } else {
        throw Exception('Failed to refresh token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error refreshing token: $e');
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    currentUser = null;
    notifyListeners();
  }
}