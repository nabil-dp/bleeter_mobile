import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../data/services/post_service.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String currentUserId;

  const PostCard({super.key, required this.post, required this.currentUserId});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostService _postService = PostService();
  late bool isLiked;
  late int likeCount;
  late int commentCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.likes.contains(widget.currentUserId);
    likeCount = widget.post.likes.length;
    commentCount = widget.post.comments.length;
  }

  void _handleLike() async {
    setState(() {
      isLiked = !isLiked;
      isLiked ? likeCount++ : likeCount--;
    });

    bool success = await _postService.likePost(widget.post.id);
    if (!success) {
      setState(() {
        isLiked = !isLiked;
        isLiked ? likeCount++ : likeCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: widget.post.profileImg.isNotEmpty
                ? NetworkImage(widget.post.profileImg)
                : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
            backgroundColor: Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.fullname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '@${widget.post.username}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.post.text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                if (widget.post.img != null && widget.post.img!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.post.img!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInteractionIcon(
                      Icons.chat_bubble_outline,
                      commentCount.toString(),
                      Colors.grey,
                      () {},
                    ),
                    _buildInteractionIcon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      likeCount.toString(),
                      isLiked ? Colors.pink : Colors.grey,
                      _handleLike,
                    ),
                    _buildInteractionIcon(Icons.share, "", Colors.grey, () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionIcon(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          if (label.isNotEmpty)
            Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
