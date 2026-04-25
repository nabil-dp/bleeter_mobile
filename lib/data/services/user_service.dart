import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final String authUrl = "http://10.0.2.2:5000/api/auth";
  final String userUrl = "http://10.0.2.2:5000/api/user";
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'token');

  Future<Map<String, dynamic>> getUserProfile(String username) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$userUrl/profile/$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      throw Exception('User tidak ditemukan atau rute salah (404)');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$authUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      await _storage.write(key: 'username', value: userData['username']);
      return userData;
    } else {
      throw Exception('Gagal mendapatkan data user login');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'profileImg');
  }
}
