import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/post_model.dart';

class PostService {
  final String baseUrl = "http://10.0.2.2:5000/api/posts";
  final storage = const FlutterSecureStorage();

  // Mengambil token yang disimpan saat login
  Future<String?> _getToken() async {
    return await storage.read(key: 'token');
  }

  // Mengambil semua post untuk Feed
  Future<List<Post>> getAllPosts() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Kirim token di sini
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Post.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat postingan: ${response.body}');
    }
  }

  // Membuat post baru (Teks saja untuk versi awal)
  Future<bool> createPost(String text) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'text': text}),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }
}
