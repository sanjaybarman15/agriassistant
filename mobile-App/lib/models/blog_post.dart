import 'package:hive/hive.dart';

part 'blog_post.g.dart';

@HiveType(typeId: 3)
class BlogPost extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String author;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final String timestamp;

  @HiveField(5)
  int likes;

  @HiveField(6)
  final String? achievement;

  BlogPost({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.likes,
    this.achievement,
  });

  BlogPost copyWith({
    String? id,
    String? author,
    String? title,
    String? content,
    String? timestamp,
    int? likes,
    String? achievement,
  }) {
    return BlogPost(
      id: id ?? this.id,
      author: author ?? this.author,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      achievement: achievement ?? this.achievement,
    );
  }
}
