import 'package:app/model/chapter_status.dart';

class Chapter {
  final int id;
  final String name;
  final String description;
  final int level;
  final int courseId;
  ChapterStatus? status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chapter ({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.courseId,
    required this.createdAt,
    required this.updatedAt,
    this.status,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      level: json['level'],
      courseId: json['courseId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  ChapterStatus? getProgress() {
    return this.status;
  }

  void setProgress(ChapterStatus status) {
    this.status = status;
  }
}