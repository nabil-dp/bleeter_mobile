import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/post_model.dart';

class PostService {
  final String baseUrl = "http://10.0.2.2:5000/api/posts";
  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'token');
  }

  Future<List<Post>> getAllPosts() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Post.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat postingan: ${response.body}');
    }
  }

  Future<bool> createPost(String text, {File? image}) async {
    final token = await _getToken();
    String? base64Image;

    if (image != null) {
      final bytes = await image.readAsBytes();
      base64Image = "data:image/png;base64,${base64Encode(bytes)}";
    }

    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'text': text,
        if (base64Image != null) 'img': base64Image,
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> likePost(String postId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/like/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<bool> commentPost(String postId, String text) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/comment/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'text': text}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deletePost(String postId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<List<Post>> getUserPosts(String username) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/user/$username'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Post.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat postingan user');
    }
  }
}
