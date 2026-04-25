class Post {
  final String id;
  final String userId;
  final String text;
  final String? img;
  final String username;
  final String fullname;
  final String profileImg;
  final List<String> likes;
  final List<dynamic> comments;

  Post({
    required this.id,
    required this.userId,
    required this.text,
    this.img,
    required this.username,
    required this.fullname,
    required this.profileImg,
    required this.likes,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};

    return Post(
      id: json['_id'] ?? '',
      userId: user['_id'] ?? '',
      text: json['text'] ?? '',
      img: json['img'],
      username: user['username'] ?? 'Unknown',
      fullname: user['fullname'] ?? 'User',
      profileImg: user['profileImg'] ?? '',
      likes: List<String>.from(json['likes'] ?? []),
      comments: json['comments'] ?? [],
    );
  }
}
