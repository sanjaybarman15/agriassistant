import 'package:flutter/material.dart';
import '../../../utils/theme_constants.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ThemeConstants.backgroundPrimary,
        appBar: AppBar(
          title: Text('Leaderboard',
              style: ThemeConstants.headingStyle.copyWith(
                color: ThemeConstants.textSecondary,
              )),
          backgroundColor: ThemeConstants.primaryBlack,
        ),
        body: Column(
          children: [
            // Tab Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                  Tab(text: 'Leaderboard'),
                  Tab(text: 'Achievements'),
                ],
              ),
            ),
            // Tab Bar View
            Expanded(
              child: TabBarView(
                children: [
                  _buildLeaderboardTab(context),
                  _buildAchievementsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performers',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 20),
          _buildLeaderboardItem(context, '1', 'Top User', '1000 points', true),
          const SizedBox(height: 12),
          _buildLeaderboardItem(context, '2', 'John Doe', '950 points', false),
          const SizedBox(height: 12),
          _buildLeaderboardItem(
              context, '3', 'Jane Smith', '920 points', false),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, String rank, String name,
      String points, bool isTop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop
            ? ThemeConstants.accentColor.withOpacity(0.1)
            : ThemeConstants.primaryBlack.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isTop
                  ? ThemeConstants.accentColor
                  : ThemeConstants.primaryBlack.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isTop
                      ? ThemeConstants.primaryBlack
                      : ThemeConstants.primaryBlack,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                points,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Trophies',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 20),
          _buildAchievementItem(
            context,
            'Early Bird',
            'Complete 5 tasks before 9 AM',
            Icons.wb_sunny,
            '2/5 completed',
            0.4,
          ),
          const SizedBox(height: 16),
          _buildAchievementItem(
            context,
            'Streak Master',
            'Maintain a 7-day streak',
            Icons.local_fire_department,
            '5/7 days',
            0.7,
          ),
          const SizedBox(height: 16),
          _buildAchievementItem(
            context,
            'Task Champion',
            'Complete 100 tasks',
            Icons.emoji_events,
            '75/100 tasks',
            0.75,
          ),
          const SizedBox(height: 24),
          Text(
            'Available Trophies',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildLockedTrophy(
            context,
            'Productivity Guru',
            'Complete 50 tasks in a week',
            Icons.stars,
            '1000 points reward',
          ),
          const SizedBox(height: 16),
          _buildLockedTrophy(
            context,
            'Perfect Month',
            'Complete all daily tasks for 30 days',
            Icons.calendar_today,
            '2000 points reward',
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String progress,
    double progressValue,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConstants.primaryBlack.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeConstants.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: ThemeConstants.primaryBlack,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: ThemeConstants.primaryBlack.withOpacity(0.1),
            valueColor:
                AlwaysStoppedAnimation<Color>(ThemeConstants.accentColor),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            progress,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildLockedTrophy(
    BuildContext context,
    String title,
    String requirement,
    IconData icon,
    String reward,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConstants.primaryBlack.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeConstants.primaryBlack.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeConstants.primaryBlack.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: ThemeConstants.primaryBlack.withOpacity(0.5),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ThemeConstants.primaryBlack.withOpacity(0.7),
                      ),
                ),
                Text(
                  requirement,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ThemeConstants.primaryBlack.withOpacity(0.5),
                      ),
                ),
                Text(
                  reward,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeConstants.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline,
            color: ThemeConstants.primaryBlack.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
