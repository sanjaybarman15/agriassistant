import 'package:flutter/material.dart';
import 'package:habitx/providers/user_provider.dart';
import 'package:habitx/widgets/trophy_accordion.dart';
import 'package:provider/provider.dart';
import 'package:habitx/utils/theme_constants.dart';
import 'package:habitx/screens/tabs/todo_screen.dart';
import 'package:habitx/screens/tabs/blog_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showTrophyDialog(BuildContext context) {
    TrophyAccordion.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ThemeConstants.backgroundPrimary,
        body: SafeArea(
          child: Column(
            children: [
              // Top Section with Profile and Icons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side - Profile and Icons
                    Row(
                      children: [
                        // Profile Image
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                ThemeConstants.primaryYellow.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 32,
                            color: ThemeConstants.primaryBlack,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Dynamic greeting
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.name ?? "User"}',
                              style: textTheme.bodyLarge?.copyWith(
                                color: ThemeConstants.primaryBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (user != null && user.streakCount > 0)
                              Text(
                                '${user.streakCount} Day Streak 🔥',
                                style: textTheme.bodySmall?.copyWith(
                                  color: ThemeConstants.primaryBlack.withOpacity(0.6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // Right side - Trophy and More
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showTrophyDialog(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  ThemeConstants.primaryBlack.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.emoji_events_outlined,
                              color: ThemeConstants.primaryBlack,
                              size: 25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ],
                ),
              ),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: TabBar(
                  padding: const EdgeInsets.all(4),
                  indicator: BoxDecoration(
                    color: ThemeConstants.primaryBlack,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: ThemeConstants.primaryWhite,
                  unselectedLabelColor:
                      ThemeConstants.primaryBlack.withOpacity(0.5),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: textTheme.bodyMedium,
                  tabs: const [
                    Tab(text: 'Todo List'),
                    Tab(text: 'Write Blogs'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tab Bar View
              const Expanded(
                child: TabBarView(
                  children: [
                    TodoScreen(),
                    BlogScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
