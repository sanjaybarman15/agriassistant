import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String profilePic;

  @HiveField(2)
  final int points;

  @HiveField(3)
  final int streakCount;

  User({
    required this.name,
    this.profilePic = '',
    this.points = 0,
    this.streakCount = 0,
  });

  User copyWith({
    String? name,
    String? profilePic,
    int? points,
    int? streakCount,
  }) {
    return User(
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      points: points ?? this.points,
      streakCount: streakCount ?? this.streakCount,
    );
  }
}
