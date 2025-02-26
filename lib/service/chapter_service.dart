import 'dart:convert';
import 'package:app/global_var.dart';
import 'package:app/model/assignment.dart';
import 'package:http/http.dart' as http;
import '../model/assessment.dart';
import '../model/learning_material.dart';

class ChapterService {

  static Future<LearningMaterial> getMaterialByChapterId(int id) async {
    try {
      final response = await http.get(Uri.parse('${GlobalVar.baseUrl}/chapter/$id/materials'));
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
      final response = await http.get(Uri.parse('${GlobalVar.baseUrl}/chapter/$id/assessments'));
      final result = jsonDecode(response.body);
      final decodeResult = result[0]['assessments'][0];

      if (result.isEmpty) {
        throw Exception("No assessments found");
      }

      final List<dynamic> decodeQuestion = jsonDecode(decodeResult['questions']);
      List<Question> questions = decodeQuestion.map((q) => Question(
        question: q['question'],
        option: List<String>.from(q['options']),
        correctedAnswer: q['answer'],
        type: q['type']
      )).toList();

      // Decode answers safely (null-safe handling)
      final List<String>? decodedAnswers = decodeResult['answers'] != null
          ? List<String>.from(jsonDecode(decodeResult['answers']))
          : null;

      Assessment assessment = Assessment(
        id: decodeResult['id'],
        chapterId: decodeResult['chapterId'],
        instruction: decodeResult['instruction'],
        questions: questions,
        answers: decodedAnswers,
        createdAt: DateTime.parse(decodeResult['createdAt']),
        updatedAt: DateTime.parse(decodeResult['updatedAt']),
      );

      return assessment;
    } catch (e) {
      throw Exception("Error fetching assessment: ${e.toString()}");
    }
  }

  static Future<Assignment> getAssignmentByChapterId(int id) async {
    try {
      final response = await http.get(Uri.parse('${GlobalVar.baseUrl}/chapter/$id/assignments'));
      final result = jsonDecode(response.body);
      final decodeResult = result[0]['assignments'][0];

      if (result.isEmpty) {
        throw Exception("No assignment found");
      }

      Assignment assignment = Assignment.fromJson(decodeResult);

      return assignment;
    } catch (e) {
      throw Exception("Error fetching assessment: ${e.toString()}");
    }
  }
}