import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/forum.dart';
import '../../models/forum_comment.dart';
import '../../models/forum_post.dart';
import 'provider/forum_provider.dart';

class ForumDetailScreen extends StatefulWidget {
  const ForumDetailScreen({super.key, required this.forum});

  final Forum forum;

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final forumProvider = context.watch<ForumProvider>();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: forumProvider.forumDetailStream(widget.forum.id),
      builder: (context, snapshot) {
        final forum = snapshot.data == null
            ? widget.forum
            : Forum.fromSnapshot(snapshot.data!);
        return Scaffold(
          appBar: AppBar(
            title: Text(forum.title),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _bookAccentColor(forum.bookTitle)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            forum.bookTitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _bookAccentColor(forum.bookTitle),
                            ),
                          ),
                        ),
                        if (forum.bookAuthor.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            forum.bookAuthor,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      forum.description,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          forum.createdByName,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.forum, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          '${forum.postCount} posts',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: forumProvider.postsStream(widget.forum.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Unable to load posts right now.'),
                      );
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('Start the first discussion.'),
                      );
                    }
                    final posts = docs.map(ForumPost.fromSnapshot).toList();
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final user = forumProvider.currentUser;
                        final hasLiked =
                            user != null && post.likedBy.contains(user.uid);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1F2C34) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                post.content,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              if (post.tags.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: post.tags
                                      .map(
                                        (tag) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            tag,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      post.createdByName.isNotEmpty
                                          ? post.createdByName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    post.createdByName,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () async {
                                      if (user == null) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Sign in to like posts.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      await forumProvider.toggleLike(
                                        forumId: widget.forum.id,
                                        postId: post.id,
                                      );
                                    },
                                    icon: Icon(
                                      hasLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 18,
                                      color: hasLiked
                                          ? Colors.redAccent
                                          : Colors.grey[600],
                                    ),
                                    label: Text(
                                      post.likeCount.toString(),
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      _showCommentsSheet(post);
                                    },
                                    icon: Icon(
                                      Icons.mode_comment_outlined,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    label: Text(
                                      post.commentCount.toString(),
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  Text(
                                    _formatDate(post.createdAt),
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showCreatePostDialog,
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              'New Post',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  Future<void> _showCreatePostDialog() async {
    final forumProvider = context.read<ForumProvider>();
    final user = forumProvider.currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to post in this forum.')),
      );
      return;
    }

    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagsController = TextEditingController();
    var isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: mediaQuery.viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start a discussion',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Post title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'What do you want to discuss?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tagsController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final title = titleController.text.trim();
                              final content = contentController.text.trim();
                              if (title.isEmpty || content.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Add a title and content.'),
                                  ),
                                );
                                return;
                              }
                              setModalState(() {
                                isSubmitting = true;
                              });
                              try {
                                await forumProvider.createPost(
                                  forumId: widget.forum.id,
                                  title: title,
                                  content: content,
                                  tags: _parseTags(tagsController.text),
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              } finally {
                                if (context.mounted) {
                                  setModalState(() {
                                    isSubmitting = false;
                                  });
                                }
                              }
                            },
                      child: Text(isSubmitting ? 'Posting...' : 'Publish'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    contentController.dispose();
    tagsController.dispose();
  }

  Future<void> _showCommentsSheet(ForumPost post) async {
    final forumProvider = context.read<ForumProvider>();
    final commentController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: mediaQuery.viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 280,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: forumProvider.commentsStream(
                    forumId: widget.forum.id,
                    postId: post.id,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Unable to load comments.'),
                      );
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('Start the first comment.'),
                      );
                    }
                    final comments =
                        docs.map(ForumComment.fromSnapshot).toList();
                    return ListView.separated(
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                comment.createdByName.isNotEmpty
                                    ? comment.createdByName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.createdByName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(comment.content),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(comment.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  labelText: 'Write a comment',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) async {
                  await _submitComment(
                    forumProvider,
                    post,
                    commentController,
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _submitComment(
                      forumProvider,
                      post,
                      commentController,
                    );
                  },
                  child: const Text('Post comment'),
                ),
              ),
            ],
          ),
        );
      },
    );

    commentController.dispose();
  }

  Future<void> _submitComment(
    ForumProvider forumProvider,
    ForumPost post,
    TextEditingController controller,
  ) async {
    final user = forumProvider.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to comment.')),
      );
      return;
    }
    final content = controller.text.trim();
    if (content.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a comment first.')),
      );
      return;
    }
    await forumProvider.addComment(
      forumId: widget.forum.id,
      postId: post.id,
      content: content,
    );
    controller.clear();
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Just now';
    }
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  List<String> _parseTags(String raw) {
    return raw
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  Color _bookAccentColor(String seed) {
    final hash = seed.codeUnits.fold<int>(0, (sum, char) => sum + char);
    final colors = [
      const Color(0xFF1D4ED8),
      const Color(0xFF0F766E),
      const Color(0xFFB45309),
      const Color(0xFF9F1239),
      const Color(0xFF7C3AED),
      const Color(0xFF0EA5E9),
    ];
    return colors[hash % colors.length];
  }
}
