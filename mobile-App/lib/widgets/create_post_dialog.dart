import 'package:flutter/material.dart';
import 'package:habitx/utils/theme_constants.dart';
import 'dart:ui';

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: ThemeConstants.primaryBlack.withOpacity(0.5),
      builder: (BuildContext context) {
        return const CreatePostDialog();
      },
    );
  }

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  String? _selectedAchievement;
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

  void _resetForm() {
    setState(() {
      _selectedAchievement = null;
      _titleController.clear();
      _contentController.clear();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryBlack,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: ThemeConstants.primaryBlack.withOpacity(0.9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    _buildForm(context),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ThemeConstants.primaryWhite.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.celebration,
                color: ThemeConstants.primaryWhite,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Share Achievement',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ThemeConstants.primaryWhite,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: ThemeConstants.primaryWhite.withOpacity(0.7),
            ),
            onPressed: () {
              _resetForm();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAchievementDropdown(context),
            const SizedBox(height: 16),
            _buildTitleInput(context),
            const SizedBox(height: 16),
            _buildContentInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Achievement',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: ThemeConstants.primaryWhite,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryWhite.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedAchievement,
              hint: Text(
                'Choose your achievement',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ThemeConstants.primaryWhite.withOpacity(0.7),
                    ),
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: ThemeConstants.primaryWhite,
              ),
              dropdownColor: ThemeConstants.primaryBlack,
              items: _achievements.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ThemeConstants.primaryWhite,
                        ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAchievement = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: ThemeConstants.primaryWhite,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryWhite.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _titleController,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeConstants.primaryWhite,
                ),
            decoration: InputDecoration(
              hintText: 'Give your achievement a title',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeConstants.primaryWhite.withOpacity(0.5),
                  ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Story',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: ThemeConstants.primaryWhite,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryWhite.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _contentController,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeConstants.primaryWhite,
                ),
            decoration: InputDecoration(
              hintText: 'Share your journey and inspire others...',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeConstants.primaryWhite.withOpacity(0.5),
                  ),
              border: InputBorder.none,
            ),
            maxLines: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ThemeConstants.primaryWhite.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              _resetForm();
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeConstants.primaryWhite.withOpacity(0.7),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              if (_selectedAchievement != null &&
                  _titleController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty) {
                // Add the new post logic here
                _resetForm();
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.accentColor,
              foregroundColor: ThemeConstants.primaryBlack,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration, size: 20),
                const SizedBox(width: 8),
                const Text('Share Achievement'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
