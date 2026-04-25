import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../data/services/post_service.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String currentUserId;
  final VoidCallback onDeleteSuccess;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onDeleteSuccess,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostService _postService = PostService();
  late bool isLiked;
  late int likeCount;

  void _handleLike() async {
    setState(() {
      isLiked = !isLiked;
      isLiked ? likeCount++ : likeCount--;
    });

    bool success = await _postService.likePost(widget.post.id);

    if (!success) {
      if (!mounted) return;
      setState(() {
        isLiked = !isLiked;
        isLiked ? likeCount++ : likeCount--;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal memperbarui Like")));
    }
  }

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.likes.contains(widget.currentUserId);
    likeCount = widget.post.likes.length;
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Hapus Post?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Tindakan ini tidak dapat dibatalkan.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              bool success = await _postService.deletePost(widget.post.id);
              if (success && mounted) {
                Navigator.pop(context);
                widget.onDeleteSuccess();
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCommentModal() {
    final TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "COMMENTS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildCommentItem(
                    username: widget.post.username,
                    fullname: widget.post.fullname,
                    text: widget.post.text,
                    profileImg: widget.post.profileImg,
                    showLine: true,
                  ),

                  ...widget.post.comments.map((comment) {
                    return _buildCommentItem(
                      username: comment['user']['username'] ?? 'user',
                      fullname: comment['user']['fullname'] ?? 'User',
                      text: comment['text'] ?? '',
                      profileImg: comment['user']['profileImg'] ?? '',
                      showLine: true,
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9BF0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        if (_commentController.text.isNotEmpty) {
                          bool success = await _postService.commentPost(
                            widget.post.id,
                            _commentController.text,
                          );
                          if (success) {
                            if (mounted) {
                              Navigator.pop(context);
                              widget.onDeleteSuccess();
                            }
                          }
                        }
                      },
                      child: const Text(
                        "Post",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentItem({
    required String username,
    required String fullname,
    required String text,
    required String profileImg,
    bool showLine = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: profileImg.isNotEmpty
                      ? NetworkImage(profileImg)
                      : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                ),
                if (showLine)
                  Container(width: 2, height: 30, color: Colors.grey[800]),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: fullname,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: " @$username",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(text, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.post.userId == widget.currentUserId;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(widget.post.profileImg)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
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
                    ),
                    if (isOwner)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: _confirmDelete,
                      ),
                  ],
                ),
                Text(
                  widget.post.text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconButton(
                      Icons.chat_bubble_outline,
                      widget.post.comments.length.toString(),
                      _showCommentModal,
                    ),
                    _iconButton(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      likeCount.toString(),
                      _handleLike,
                      color: isLiked ? Colors.pink : Colors.grey,
                    ),
                    const Icon(
                      Icons.share_outlined,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color color = Colors.grey,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
