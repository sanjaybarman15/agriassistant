import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/theme_constants.dart';
import '../../screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundPrimary,
      appBar: AppBar(
        title: Text('Profile',
            style: ThemeConstants.headingStyle.copyWith(
              color: ThemeConstants.textSecondary,
            )),
        backgroundColor: ThemeConstants.primaryBlack,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: ThemeConstants.accentColor,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: ThemeConstants.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'John Doe',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'john.doe@example.com',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              _buildProfileCard(
                context,
                'Streak',
                '7 days',
                Icons.local_fire_department,
              ),
              const SizedBox(height: 16),
              _buildProfileCard(
                context,
                'Completed Habits',
                '42',
                Icons.check_circle,
              ),
              const SizedBox(height: 16),
              _buildProfileCard(
                context,
                'Current Goals',
                '3 active',
                Icons.flag,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConstants.primaryBlack.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: ThemeConstants.primaryBlack,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
