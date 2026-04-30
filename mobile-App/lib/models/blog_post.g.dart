// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlogPostAdapter extends TypeAdapter<BlogPost> {
  @override
  final int typeId = 3;

  @override
  BlogPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BlogPost(
      id: fields[0] as String,
      author: fields[1] as String,
      title: fields[2] as String,
      content: fields[3] as String,
      timestamp: fields[4] as String,
      likes: fields[5] as int,
      achievement: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BlogPost obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.author)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.likes)
      ..writeByte(6)
      ..write(obj.achievement);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlogPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
