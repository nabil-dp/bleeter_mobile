class Post {
  final String id;
  final String text;
  final String? img; // Bisa null jika tweet tidak ada gambar
  final String username;
  final String fullname;
  final String profileImg;

  Post({
    required this.id,
    required this.text,
    this.img,
    required this.username,
    required this.fullname,
    required this.profileImg,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Backend Burak melakukan populate pada field 'user'
    final user = json['user'] ?? {};

    return Post(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      img: json['img'],
      username: user['username'] ?? 'Unknown',
      fullname: user['fullname'] ?? 'User',
      profileImg: user['profileImg'] ?? '',
    );
  }
}
