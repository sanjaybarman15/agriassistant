import 'package:flutter/material.dart';
import 'package:habitx/models/blog_post.dart';
import 'package:habitx/utils/theme_constants.dart';
import 'package:habitx/widgets/blog_post_card.dart';
import 'dart:ui';
import 'package:habitx/providers/blog_provider.dart';
import 'package:habitx/providers/user_provider.dart';
import 'package:provider/provider.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<String> _achievements = [
    'Early Bird',
    '7-Day Streak',
    'Task Champion',
    '30-Day Meditation',
    'Productivity Master',
    'Perfect Week',
    'Reading Goal',
    'Exercise Milestone',
  ];

  String? _selectedAchievement;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showCreatePostDialog(BlogProvider blogProvider, UserProvider userProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: ThemeConstants.primaryBlack.withOpacity(0.5),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
                  decoration: BoxDecoration(
                    color: ThemeConstants.primaryBlack,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Share Achievement',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: ThemeConstants.primaryWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      // Form
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Achievement', style: const TextStyle(color: Colors.white70)),
                              DropdownButton<String>(
                                isExpanded: true,
                                dropdownColor: Colors.black,
                                value: _selectedAchievement,
                                items: _achievements.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: const TextStyle(color: Colors.white)),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _selectedAchievement = value),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _titleController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(hintText: 'Title', hintStyle: TextStyle(color: Colors.white38)),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _contentController,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 4,
                                decoration: const InputDecoration(hintText: 'Your Story', hintStyle: TextStyle(color: Colors.white38)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Actions
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_titleController.text.isNotEmpty) {
                              blogProvider.addPost(
                                author: userProvider.currentUser?.name ?? "User",
                                title: _titleController.text,
                                content: _contentController.text,
                                achievement: _selectedAchievement,
                              );
                              _titleController.clear();
                              _contentController.clear();
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Share Achievement'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final blogProvider = Provider.of<BlogProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          _buildCreatePostButton(context, blogProvider, userProvider),
          const SizedBox(height: 24),
          ...blogProvider.posts.map((post) => FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: BlogPostCard(
                      post: post,
                      onLike: () => blogProvider.toggleLike(post.id),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCreatePostButton(BuildContext context, BlogProvider blogProvider, UserProvider userProvider) {
    return InkWell(
      onTap: () => _showCreatePostDialog(blogProvider, userProvider),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ThemeConstants.primaryBlack,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.edit_note, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Share Your Journey', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
