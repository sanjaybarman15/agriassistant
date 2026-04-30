import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:habitx/models/blog_post.dart';
import 'package:habitx/utils/persistence_service.dart';
import 'package:uuid/uuid.dart';

class BlogProvider extends ChangeNotifier {
  late Box<BlogPost> _blogBox;
  final _uuid = const Uuid();

  BlogProvider() {
    _blogBox = PersistenceService.getBox<BlogPost>(PersistenceService.blogBoxName);
    _initializeDummyData();
  }

  List<BlogPost> get posts => _blogBox.values.toList().reversed.toList();

  void _initializeDummyData() {
    if (_blogBox.isEmpty) {
      final dummyPosts = [
        BlogPost(
          id: _uuid.v4(),
          author: "Sarah Parker",
          title: "Achieved 30-Day Meditation Streak! 🎯",
          content: "Finally hit my goal of meditating every day for a month. Started with just 5 minutes and now doing 20 minutes daily.",
          timestamp: "2 hours ago",
          likes: 24,
          achievement: "30-Day Streak",
        ),
        BlogPost(
          id: _uuid.v4(),
          author: "Mike Chen",
          title: "Morning Routine Success 🌅",
          content: "Waking up at 5 AM for the past week has completely changed my productivity. Highly recommend!",
          timestamp: "5 hours ago",
          likes: 18,
          achievement: "Early Bird",
        ),
      ];
      for (var post in dummyPosts) {
        _blogBox.put(post.id, post);
      }
    }
  }

  void addPost({
    required String author,
    required String title,
    required String content,
    String? achievement,
  }) {
    final post = BlogPost(
      id: _uuid.v4(),
      author: author,
      title: title,
      content: content,
      timestamp: "Just now",
      likes: 0,
      achievement: achievement,
    );
    _blogBox.put(post.id, post);
    notifyListeners();
  }

  void toggleLike(String postId) {
    final post = _blogBox.get(postId);
    if (post != null) {
      post.likes += 1; // Simplistic like logic for now
      post.save();
      notifyListeners();
    }
  }

  void deletePost(String postId) {
    _blogBox.delete(postId);
    notifyListeners();
  }
}
