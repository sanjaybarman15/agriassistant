import 'package:flutter/material.dart';
import 'package:habitx/models/habit.dart';
import 'package:habitx/utils/theme_constants.dart';
import 'package:intl/intl.dart';

class HabitItem extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final Function(bool?)? onToggle;

  const HabitItem({
    super.key,
    required this.habit,
    required this.isCompleted,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        habit.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (habit.streak > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${habit.streak} 🔥',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: ThemeConstants.primaryBlack.withOpacity(0.6),
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (habit.time != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeString(habit.time!),
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: isCompleted,
                onChanged: onToggle,
                shape: const CircleBorder(),
                activeColor: ThemeConstants.primaryBlack,
                side: BorderSide(
                  color: ThemeConstants.primaryBlack.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeString(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2022, 1, 1, hour, minute);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return time;
    }
  }
}
