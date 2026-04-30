import 'package:flutter/material.dart';
import 'package:habitx/providers/user_provider.dart';
import 'package:habitx/utils/theme_constants.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showEditProfileDialog(BuildContext context, UserProvider userProvider) {
    final controller = TextEditingController(text: userProvider.currentUser?.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              userProvider.updateUserName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Account',
            [
              _buildSettingTile(
                context,
                'Profile Information',
                Icons.person_outline,
                onTap: () => _showEditProfileDialog(context, userProvider),
                subtitle: userProvider.currentUser?.name,
              ),
              _buildSettingTile(
                context,
                'Privacy',
                Icons.lock_outline,
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            context,
            'Preferences',
            [
              _buildSettingTile(
                context,
                'Theme',
                Icons.palette_outlined,
                onTap: () => userProvider.toggleTheme(),
                trailing: Switch(
                  value: userProvider.isDarkMode,
                  onChanged: (value) => userProvider.toggleTheme(),
                ),
                subtitle: userProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
              ),
              _buildSettingTile(
                context,
                'Notifications',
                Icons.notifications_outlined,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                'Language',
                Icons.language_outlined,
                onTap: () {},
                subtitle: 'English',
              ),
            ],
          ),
          _buildSection(
            context,
            'Other',
            [
              _buildSettingTile(
                context,
                'Help & Support',
                Icons.help_outline,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                'About',
                Icons.info_outline,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ThemeConstants.primaryBlack.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryBlack.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    IconData icon, {
    required VoidCallback onTap,
    String? subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: ThemeConstants.primaryBlack.withOpacity(0.7),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: ThemeConstants.primaryBlack.withOpacity(0.3),
          ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
