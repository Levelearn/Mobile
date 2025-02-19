
class Assessment {
  final int id;
  final int chapterId;
  final String instruction;
  final int orderNumber;
  final List<Question> questions;
  final List<String> answers;
  final DateTime createdAt;
  final DateTime updatedAt;

  Assessment({
    required this.id,
    required this.chapterId,
    required this.instruction,
    required this.orderNumber,
    required this.questions,
    required this.answers,
    required this.createdAt,
    required this.updatedAt
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'],
      chapterId: json['chapterId'],
      instruction: json['instruction'],
      orderNumber: json['orderNumber'],
      questions: json['questions'],
      answers: json['answers'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Question {
  String question;
  List<String> option;

  String _type = 'pg';
  String _selectedAnswer = '';
  List<String> _selectedMultiAnswer = [];

  Question({
    required this.question,
    required this.option,
  });

  String get selectedAnswer => _selectedAnswer;
  String get type => _type;
  List<String> get selectedMultAnswer => _selectedMultiAnswer;

  set type(String value) {
    _type = value;
  }
  set selectedAnswer(String value) {
    _selectedAnswer = value;
  }
  set selectedMultiAnswer(List<String> list) {
    _selectedMultiAnswer = list;
  }





}