import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../data/services/post_service.dart';
import '../../data/services/user_service.dart';
import '../widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  late Future<Map<String, dynamic>> _userProfile;
  late Future<List<Post>> _userPosts;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _userProfile = _userService.getUserProfile(widget.username);
      _userPosts = _postService.getUserPosts(widget.username);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userProfile,
        builder: (context, profileSnap) {
          if (profileSnap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else if (profileSnap.hasError) {
            return Center(
              child: Text(
                "Error: ${profileSnap.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!profileSnap.hasData) {
            return const Center(
              child: Text(
                "Data tidak ditemukan",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final user = profileSnap.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.black,
                  pinned: true,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['fullname'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Posts',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 140,
                            width: double.infinity,
                            color: Colors.grey[900],
                            child: user['coverImg'] != ""
                                ? Image.network(
                                    user['coverImg'],
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: -40,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                  user['profileImg'] ?? "",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['fullname'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '@${user['username']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user['bio'] ?? "No bio yet",
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user['createdAt']?.substring(0, 10) ?? "",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  "${(user['following'] as List).length} ",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "Following",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "${(user['followers'] as List).length} ",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "Followers",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 0.2),
                    ],
                  ),
                ),
                FutureBuilder<List<Post>>(
                  future: _userPosts,
                  builder: (context, postSnap) {
                    if (postSnap.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (postSnap.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            "Error posts: ${postSnap.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    } else if (!postSnap.hasData || postSnap.data!.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "Belum ada post",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => PostCard(
                          post: postSnap.data![index],
                          currentUserId: user['_id'],
                          onDeleteSuccess: _loadData,
                        ),
                        childCount: postSnap.data!.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
