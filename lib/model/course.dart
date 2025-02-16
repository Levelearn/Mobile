import 'chapter.dart';

const url = 'https://www.globalcareercounsellor.com/blog/wp-content/uploads/2018/05/Online-Career-Counselling-course.jpg';

class Course {
  final int id;
  final String codeCourse;
  final String courseName;
  String? description;
  int? progress = 0;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course ({
    required this.id,
    required this.codeCourse,
    required this.courseName,
    this.description,
    this.progress,
    required this.createdAt,
    required this.updatedAt
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      codeCourse: json['code'],
      courseName: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  int? getProgress() {
    return this.progress;
  }

  void setProgress(int progress) {
    this.progress = progress;
  }
}