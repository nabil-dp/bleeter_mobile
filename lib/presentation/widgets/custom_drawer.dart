import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../../data/services/user_service.dart';
import '../screens/login_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String userId;
  final String profileImg;
  final String fullname;
  final String username;
  final int followingCount;
  final int followersCount;

  const CustomDrawer({
    super.key,
    required this.userId,
    required this.profileImg,
    required this.fullname,
    required this.username,
    required this.followingCount,
    required this.followersCount,
  });

  void _showLogoutDialog(BuildContext context) {
    final UserService userService = UserService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Apakah Anda yakin ingin keluar?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () async {
              await userService.logout();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: profileImg.isNotEmpty
                        ? NetworkImage(profileImg)
                        : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fullname,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '@$username',
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '$followingCount ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Following',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$followersCount ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Followers',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            ListTile(
              leading: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(username: username),
                  ),
                );
              },
            ),
            const Divider(color: Colors.grey, height: 1),
            const Spacer(),
            const Divider(color: Colors.grey, height: 1),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.redAccent,
                size: 28,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent, fontSize: 18),
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
