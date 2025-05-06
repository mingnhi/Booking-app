import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://booking-app-1-bzfs.onrender.com';

  // Future<List<dynamic>> getUsers() async {
  //   final url = Uri.parse('$baseUrl/users');
  //   final response = await http.get(url);
  //
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to load users: ${response.statusCode}');
  //   }
  // }
  //
  // Future<Map<String, dynamic>> login(String email, String password) async {
  //   final url = Uri.parse('$baseUrl/auth/login');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'email': email, 'password': password}),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Login failed: ${response.body}');
  //   }
  // }
}
