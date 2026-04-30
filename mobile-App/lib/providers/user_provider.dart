import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:habitx/models/user.dart';
import 'package:habitx/utils/persistence_service.dart';

class UserProvider extends ChangeNotifier {
  late Box<User> _userBox;
  User? _currentUser;
  bool _isDarkMode = false;

  UserProvider() {
    _userBox = PersistenceService.getBox<User>(PersistenceService.userBoxName);
    _currentUser = _userBox.get('currentUser');
    _isDarkMode = Hive.box('settings').get('isDarkMode', defaultValue: false);
  }

  User? get currentUser => _currentUser;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    Hive.box('settings').put('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void updateUserName(String name) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name);
      _saveUser();
    }
  }

  void addPoints(int points) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(points: _currentUser!.points + points);
      _saveUser();
    }
  }

  void updateStreak(int streak) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(streakCount: streak);
      _saveUser();
    }
  }

  Future<void> _saveUser() async {
    if (_currentUser != null) {
      await _userBox.put('currentUser', _currentUser!);
      notifyListeners();
    }
  }
}
