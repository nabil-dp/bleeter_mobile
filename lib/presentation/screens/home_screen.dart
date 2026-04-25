import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../data/services/post_service.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  late Future<List<Post>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _refreshPosts();
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
        title: const Icon(
          Icons.flutter_dash,
          color: Colors.blue,
          size: 30,
        ), // Ganti logo X
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[900],
            height: 1.0,
          ), // Garis pembatas
        ),
      ),
      body: FutureBuilder<List<Post>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
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
            onRefresh: () async => _refreshPosts(),
            child: ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey[900], thickness: 1),
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundImage: post.profileImg.isNotEmpty
                        ? NetworkImage(post.profileImg)
                        : const AssetImage('assets/default_avatar.png')
                              as ImageProvider, // Siapkan gambar default
                    backgroundColor: Colors.grey,
                  ),
                  title: Row(
                    children: [
                      Text(
                        post.fullname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '@${post.username}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      post.text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          // Navigasi ke halaman buat post, tunggu hasilnya, jika true (berhasil post), refresh feed
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
          if (result == true) {
            _refreshPosts();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
