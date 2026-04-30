import 'package:hive_flutter/hive_flutter.dart';
import 'package:habitx/models/user.dart';
import 'package:habitx/models/habit.dart';
import 'package:habitx/models/task.dart';
import 'package:habitx/models/blog_post.dart';

class PersistenceService {
  static const String userBoxName = 'userBox';
  static const String habitBoxName = 'habitBox';
  static const String taskBoxName = 'taskBox';
  static const String blogBoxName = 'blogBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(HabitAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TaskAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(BlogPostAdapter());

    // Open Boxes
    await Hive.openBox<User>(userBoxName);
    await Hive.openBox<Habit>(habitBoxName);
    await Hive.openBox<Task>(taskBoxName);
    await Hive.openBox<BlogPost>(blogBoxName);
    await Hive.openBox('settings');

    // Initialize default user if not exists
    final userBox = Hive.box<User>(userBoxName);
    if (userBox.isEmpty) {
      await userBox.put('currentUser', User(
        name: 'HabitX User',
        points: 0,
        streakCount: 0,
      ));
    }
  }

  // Generic methods
  static Box<T> getBox<T>(String name) => Hive.box<T>(name);
}
