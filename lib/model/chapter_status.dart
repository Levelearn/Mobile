import 'dart:convert';

class ChapterStatus {
  int id;
  int userId;
  int chapterId;
  bool isCompleted;
  bool materialDone;
  bool assessmentDone;
  bool assignmentDone;
  List<String> assessmentAnswer;
  int assessmentGrade;
  String? submission;
  DateTime createdAt;
  DateTime updatedAt;

  ChapterStatus({
    required this.id,
    required this.userId,
    required this.chapterId,
    required this.isCompleted,
    required this.materialDone,
    required this.assessmentDone,
    required this.assignmentDone,
    required this.assessmentAnswer,
    required this.assessmentGrade,
    this.submission,
    required this.createdAt,
    required this.updatedAt
  });

  factory ChapterStatus.fromJson(Map<String, dynamic> json) {
    return ChapterStatus(
      id: json['id'],
      userId: json['userId'],
      chapterId: json['chapterId'],
      isCompleted: json['isCompleted'],
      materialDone: json['materialDone'],
      assessmentDone: json['assessmentDone'],
      assignmentDone: json['assignmentDone'],
      assessmentAnswer: json['assessmentAnswer'],
      assessmentGrade: json['assessmentGrade'],
      submission: json['submission'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'chapterId': chapterId,
      'isCompleted': isCompleted,
      'materialDone': materialDone,
      'assessmentDone': assessmentDone,
      'assignmentDone': assignmentDone,
      'assessmentAnswer': assessmentAnswer,
      'assessmentGrade': assessmentGrade,
      'submission': submission,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}