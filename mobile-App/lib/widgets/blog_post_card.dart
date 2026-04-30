import 'package:flutter/material.dart';
import 'package:habitx/models/blog_post.dart';
import 'package:habitx/utils/theme_constants.dart';

class BlogPostCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback? onLike;

  const BlogPostCard({
    super.key,
    required this.post,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeConstants.primaryBlack.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: ThemeConstants.accentColor,
                      child: Text(
                        post.author.isNotEmpty ? post.author[0] : 'U',
                        style: const TextStyle(
                          color: ThemeConstants.primaryBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          post.timestamp,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: ThemeConstants.primaryBlack
                                        .withOpacity(0.5),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (post.achievement != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeConstants.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🏆 ${post.achievement!}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ThemeConstants.primaryBlack,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: ThemeConstants.primaryBlack.withOpacity(0.1),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onLike,
                    child: Row(
                      children: [
                        Icon(
                          post.likes > 24 ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: post.likes > 24 ? Colors.red : ThemeConstants.primaryBlack.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likes}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: ThemeConstants.primaryBlack.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: ThemeConstants.primaryBlack.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Comment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ThemeConstants.primaryBlack.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
