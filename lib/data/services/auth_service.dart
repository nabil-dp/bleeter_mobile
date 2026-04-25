import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:5000/api/auth";
  final storage = const FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await storage.write(key: 'token', value: data['token']);

      if (token != null) {
        await storage.write(key: 'token', value: token);
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  Future<bool> signup(
    String username,
    String fullname,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'fullname': fullname,
        'email': email,
        'password': password,
      }),
    );
    return response.statusCode == 201;
  }
}
