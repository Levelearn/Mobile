import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/assessment.dart';
import '../model/learningmaterial.dart';

class ChapterService {
  static const String baseUrl = 'http://172.27.69.224:3000/api';

  static Future<LearningMaterial> getMaterialByChapterId(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/chapter/$id/materials'));
      final body = response.body;
      final result = jsonDecode(body);
      final material = result[0]['materials'][0];
      LearningMaterial chapter = LearningMaterial(
                  id: material['id'],
                  chapterId: material['chapterId'],
                  name: material['name'],
                  content: material['content'],
                  createdAt: DateTime.parse(material['createdAt']),
                  updatedAt: DateTime.parse(material['updatedAt']),
          );
      return chapter;
    } catch(e){
      throw Exception(e.toString());
    }
  }

  static Future<Assessment> getAssessmentByChapterId(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/chapter/$id/assessments'));
      final List<dynamic> result = jsonDecode(response.body);

      if (result.isEmpty || result[0]['assessments'].isEmpty) {
        throw Exception("No assessments found");
      }

      final Map<String, dynamic> assessmentJson = result[0]['assessments'][0];
      final List<dynamic> decodedQuestions = jsonDecode(assessmentJson['questions']);
      List<Question> questions = decodedQuestions.map((q) => Question(
        question: q['question'],
        option: List<String>.from(q['options']),
      )).toList();

      // Decode the answers string into a list of strings.
      final List<String> decodedAnswers = List<String>.from(jsonDecode(assessmentJson['answers']));

      Assessment assessment = Assessment(
        id: assessmentJson['id'],
        chapterId: assessmentJson['chapterId'],
        instruction: assessmentJson['instruction'],
        orderNumber: assessmentJson['orderNumber'],
        questions: questions,
        answers: decodedAnswers,
        createdAt: DateTime.parse(assessmentJson['createdAt']),
        updatedAt: DateTime.parse(assessmentJson['updatedAt']),
      );

      return assessment;
    } catch (e) {
      throw Exception("Error fetching assessment: ${e.toString()}");
    }
  }

}