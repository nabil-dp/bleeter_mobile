import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/post_model.dart';
import '../../data/services/post_service.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final _storage = const FlutterSecureStorage();
  late Future<List<Post>> _futurePosts;
  String _currentUserId = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _refreshPosts();
  }

  Future<void> _loadUserData() async {
    String? id = await _storage.read(key: 'userId');
    setState(() {
      _currentUserId = id ?? "";
    });
  }

  void _refreshPosts() {
    setState(() {
      _futurePosts = _postService.getAllPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: SvgPicture.asset(
          'assets/logo_svg.svg',
          height: 30,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: Colors.grey[900], height: 0.5),
        ),
      ),
      body: FutureBuilder<List<Post>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada postingan.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final posts = snapshot.data!;
          return RefreshIndicator(
            color: Colors.blue,
            onRefresh: () async => _refreshPosts(),
            child: ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey[900], height: 1),
              itemBuilder: (context, index) {
                return PostCard(
                  post: posts[index],
                  currentUserId: _currentUserId,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
          if (result == true) _refreshPosts();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Gagal memuat feed',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          TextButton(onPressed: _refreshPosts, child: const Text("Coba Lagi")),
        ],
      ),
    );
  }
}
