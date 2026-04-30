import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:habitx/models/task.dart';
import 'package:habitx/models/habit.dart';
import 'package:habitx/utils/persistence_service.dart';
import 'package:uuid/uuid.dart';

class TaskProvider extends ChangeNotifier {
  late Box<Task> _taskBox;
  late Box<Habit> _habitBox;
  
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final _uuid = const Uuid();

  TaskProvider() {
    _taskBox = PersistenceService.getBox<Task>(PersistenceService.taskBoxName);
    _habitBox = PersistenceService.getBox<Habit>(PersistenceService.habitBoxName);
    _initializeDefaultTasks();
  }

  void _initializeDefaultTasks() {
    if (_taskBox.isEmpty) {
      addTask('Welcome to HabitX! 🚀', 'This is your first task. Swipe to delete or tap to complete.');
    }
  }

  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;

  List<Task> get currentTasks {
    final dateKey = _getDateKey(_selectedDay);
    return _taskBox.values.where((task) => task.date == dateKey).toList();
  }

  void updateSelectedDay(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      notifyListeners();
    }
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  void addTask(String title, String description, {String? date, String? time}) {
    final dateKey = date ?? _getDateKey(_selectedDay);
    final id = _uuid.v4();
    final task = Task(
      id: id,
      title: title,
      description: description,
      date: dateKey,
      time: time,
    );
    _taskBox.put(id, task);
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    final task = _taskBox.get(taskId);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.save();
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _taskBox.delete(taskId);
    notifyListeners();
  }

  // --- Habit Logic ---

  List<Habit> get habits => _habitBox.values.toList();

  void addHabit(String title, String description, {String? time}) {
    final habit = Habit(
      id: _uuid.v4(),
      title: title,
      description: description,
      time: time,
    );
    _habitBox.put(habit.id, habit);
    notifyListeners();
  }

  void toggleHabitCompletion(String habitId, DateTime date) {
    final habit = _habitBox.get(habitId);
    if (habit != null) {
      final dateKey = _getDateKey(date);
      final completedDates = List<String>.from(habit.completedDates);
      
      if (completedDates.contains(dateKey)) {
        completedDates.remove(dateKey);
      } else {
        completedDates.add(dateKey);
      }
      
      // Calculate streak (very basic)
      int streak = _calculateStreak(completedDates);
      
      final updatedHabit = habit.copyWith(
        completedDates: completedDates,
        streak: streak,
      );
      _habitBox.put(habitId, updatedHabit);
      notifyListeners();
    }
  }

  bool isHabitCompleted(String habitId, DateTime date) {
    final habit = _habitBox.get(habitId);
    if (habit == null) return false;
    final dateKey = _getDateKey(date);
    return habit.completedDates.contains(dateKey);
  }

  int _calculateStreak(List<String> dates) {
    if (dates.isEmpty) return 0;
    // Simple logic: count consecutive days backwards from today
    DateTime checkDate = DateTime.now();
    final todayKey = _getDateKey(checkDate);
    
    // Check if completed today or yesterday to continue streak
    bool completedToday = dates.contains(todayKey);
    bool completedYesterday = dates.contains(_getDateKey(checkDate.subtract(const Duration(days: 1))));
    
    if (!completedToday && !completedYesterday) return 0;
    
    // Logic for counting... (simplified)
    return dates.length; // placeholder
  }

  // Helper for UI
  List<Map<String, String>> getWeekDays() {
    final days = <Map<String, String>>[];
    final weekStart = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      days.add({
        'day': _getWeekDayName(date.weekday),
        'date': date.day.toString(),
        'isSelected': isSameDay(date, _selectedDay) ? 'true' : 'false',
        'isToday': isSameDay(date, today) ? 'true' : 'false',
      });
    }
    return days;
  }

  String _getWeekDayName(int weekday) {
    return ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][weekday - 1];
  }
}
