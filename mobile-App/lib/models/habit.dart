import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<String> completedDates; // Format: YYYY-MM-DD

  @HiveField(4)
  final int streak;

  @HiveField(5)
  final String? time;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    this.completedDates = const [],
    this.streak = 0,
    this.time,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? completedDates,
    int? streak,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completedDates: completedDates ?? this.completedDates,
      streak: streak ?? this.streak,
      time: time ?? this.time,
    );
  }
}
