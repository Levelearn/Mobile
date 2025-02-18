import 'package:app/model/assessment.dart';

import 'assessment.dart';
import 'assignment.dart';

class Chapter {
  int id;
  String name;
  String description;
  int level;
  int courseId;
  double? progress = 0.0;
  DateTime createdAt;
  DateTime updatedAt;

  Chapter ({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.courseId,
    required this.createdAt,
    required this.updatedAt,
    this.progress
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

  double? getProgress() {
    return this.progress;
  }

  void setProgress(double progress) {
    this.progress = progress;
  }
}