import 'package:flutter/material.dart';
import 'package:habitx/models/task.dart';
import 'package:habitx/utils/theme_constants.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(bool?)? onToggle;

  const TaskItem({
    super.key,
    required this.task,
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
                  Text(
                    task.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: ThemeConstants.primaryBlack.withOpacity(0.6),
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.time != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeString(task.time!),
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
                value: task.isCompleted,
                onChanged: onToggle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
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
