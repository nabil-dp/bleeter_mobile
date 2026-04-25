import 'package:flutter/material.dart';
import '../data/models/post_model.dart';
import '../data/services/post_service.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();

  List<Post> _homePosts = [];
  List<Post> _userPosts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Post> get homePosts => _homePosts;
  List<Post> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHomePosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _homePosts = await _postService.getAllPosts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserPosts(String username) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userPosts = await _postService.getUserPosts(username);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
