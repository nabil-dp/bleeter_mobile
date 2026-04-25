import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/post_model.dart';
import '../../data/services/post_service.dart';
import '../../data/services/user_service.dart';
import '../widgets/post_card.dart';
import '../widgets/custom_drawer.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final _storage = const FlutterSecureStorage();

  late Future<List<Post>> _futurePosts;
  Future<Map<String, dynamic>>? _futureCurrentUser;
  String _currentUserId = "";

  @override
  void initState() {
    super.initState();
    _refreshPosts();
    _futureCurrentUser = _userService.getCurrentUser().then((user) {
      _currentUserId = user['_id'];
      return user;
    });
  }

  void _initData() async {
    String? id = await _storage.read(key: 'userId');
    if (id != null) {
      setState(() {
        _currentUserId = id;
        _futureCurrentUser = _userService.getUserProfile(id);
        _futurePosts = _postService.getAllPosts();
      });
    }
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
      drawer: FutureBuilder<Map<String, dynamic>>(
        future: _futureCurrentUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer(
              backgroundColor: Colors.black,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Drawer(
              backgroundColor: Colors.black,
              child: Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final user = snapshot.data!;
          return CustomDrawer(
            userId: user['_id'],
            fullname: user['fullName'] ?? "User",
            username: user['username'] ?? "username",
            profileImg: user['profileImg'] ?? "",
            followersCount: (user['followers'] as List?)?.length ?? 0,
            followingCount: (user['following'] as List?)?.length ?? 0,
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _futureCurrentUser,
                builder: (context, snapshot) => CircleAvatar(
                  backgroundImage: NetworkImage(
                    snapshot.data?['profileImg'] ?? "",
                  ),
                ),
              ),
            ),
          ),
        ),
        title: SvgPicture.asset(
          'assets/logo_svg.svg',
          height: 25,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        centerTitle: true,
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
                  onDeleteSuccess: _refreshPosts,
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
