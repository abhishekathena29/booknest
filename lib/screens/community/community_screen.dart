import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/forum.dart';
import 'forum_detail_screen.dart';
import 'provider/forum_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final forumProvider = context.watch<ForumProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Community Forums',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTabChip('All', 0),
                  _buildTabChip('My Forums', 1),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: forumProvider.forumStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Unable to load forums right now.'),
                    );
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Create the first forum to get started.'),
                    );
                  }
                  final forums = docs.map(Forum.fromSnapshot).toList();
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: forums.length,
                    itemBuilder: (context, index) {
                      return _buildForumCard(
                        context: context,
                        forum: forums[index],
                        isDark: isDark,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateForumDialog,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('New Forum', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTabChip(String label, int index) {
    final forumProvider = context.read<ForumProvider>();
    final isSelected = forumProvider.selectedTab == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          forumProvider.setSelectedTab(index);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildForumCard({
    required BuildContext context,
    required Forum forum,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForumDetailScreen(forum: forum),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2C34) : Colors.white,
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
              forum.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              forum.description,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    forum.createdByName.isNotEmpty
                        ? forum.createdByName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  forum.createdByName,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Icon(Icons.forum, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${forum.postCount} posts',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(forum.lastPostAt),
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateForumDialog() async {
    final forumProvider = context.read<ForumProvider>();
    final user = forumProvider.currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to create a forum.')),
      );
      return;
    }

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final postTitleController = TextEditingController();
    final postContentController = TextEditingController();
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
                    'Create a forum',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Forum title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    textInputAction: TextInputAction.next,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start the first discussion (optional)',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: postTitleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Post title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: postContentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Post content',
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
                              final description =
                                  descriptionController.text.trim();
                              final postTitle = postTitleController.text.trim();
                              final postContent =
                                  postContentController.text.trim();
                              if (title.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Add a forum title.'),
                                  ),
                                );
                                return;
                              }
                              final hasPost =
                                  postTitle.isNotEmpty || postContent.isNotEmpty;
                              if (hasPost &&
                                  (postTitle.isEmpty || postContent.isEmpty)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Add both a post title and content.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setModalState(() {
                                isSubmitting = true;
                              });
                              try {
                                await forumProvider.createForum(
                                  title: title,
                                  description: description,
                                  initialPostTitle: hasPost ? postTitle : null,
                                  initialPostContent:
                                      hasPost ? postContent : null,
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
                      child: Text(isSubmitting ? 'Creating...' : 'Create forum'),
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
    descriptionController.dispose();
    postTitleController.dispose();
    postContentController.dispose();
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
}
