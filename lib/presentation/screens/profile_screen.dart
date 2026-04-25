import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/post_provider.dart';
import '../widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final userProv = context.read<UserProvider>();
    final postProv = context.read<PostProvider>();

    await Future.wait([
      userProv.fetchUserProfile(widget.username),
      postProv.fetchUserPosts(widget.username),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final postProv = context.watch<PostProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(userProv, postProv),
    );
  }

  Widget _buildBody(UserProvider userProv, PostProvider postProv) {
    if (userProv.isLoading && userProv.userProfile == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    if (userProv.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Error: ${userProv.errorMessage}",
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }

    final user = userProv.userProfile;
    if (user == null)
      return const Center(
        child: Text(
          "User tidak ditemukan",
          style: TextStyle(color: Colors.white),
        ),
      );

    return RefreshIndicator(
      color: Colors.blue,
      onRefresh: _refreshData,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            pinned: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['fullname'] ?? "Profile",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${postProv.userPosts.length} Posts',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                      child:
                          (user['coverImg'] != null && user['coverImg'] != "")
                          ? Image.network(user['coverImg'], fit: BoxFit.cover)
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
                            "Joined ${user['createdAt']?.substring(0, 10) ?? ""}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildFollowCount(
                            user['following']?.length ?? 0,
                            "Following",
                          ),
                          const SizedBox(width: 12),
                          _buildFollowCount(
                            user['followers']?.length ?? 0,
                            "Followers",
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

          _buildPostList(postProv, user['_id']),
        ],
      ),
    );
  }

  Widget _buildFollowCount(int count, String label) {
    return Row(
      children: [
        Text(
          "$count ",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildPostList(PostProvider postProv, String userId) {
    if (postProv.isLoading && postProv.userPosts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (postProv.userPosts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              "Belum ada postingan",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => PostCard(
          post: postProv.userPosts[index],
          currentUserId: userId,
          onDeleteSuccess: _refreshData,
        ),
        childCount: postProv.userPosts.length,
      ),
    );
  }
}
