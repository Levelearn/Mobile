import 'dart:convert';
import 'package:app/model/chapter_status.dart';
import 'package:http/http.dart' as http;

import '../global_var.dart';

class UserChapterService {

  static Future<ChapterStatus> getChapterStatus(int idUser, int idChapter) async {
    try {
      late ChapterStatus status;
      final response = await http.get(Uri.parse('${GlobalVar.baseUrl}/userchapter/$idUser/$idChapter'));
      final body = response.body;
      final result = jsonDecode(body);
      if (result is List && result.isNotEmpty) {
        final resultListAnswer = (jsonDecode(result[0]['assessmentAnswer']) as List)
            .map((item) => item.toString()) // Convert each item to String
            .toList();
        status = ChapterStatus(
          id: result[0]['id'],
          userId: result[0]['userId'],
          chapterId: result[0]['chapterId'],
          isCompleted: result[0]['isCompleted'],
          isStarted: result[0]['isStarted'],
          materialDone: result[0]['materialDone'],
          assessmentDone: result[0]['assessmentDone'],
          assignmentDone: result[0]['assignmentDone'],
          assessmentAnswer: resultListAnswer,
          assessmentGrade: result[0]['assessmentGrade'],
          submission: result[0]['submission'],
          timeStarted: DateTime.parse(result[0]['timeStarted']),
          timeFinished: DateTime.parse(result[0]['timeFinished']),
          createdAt: DateTime.parse(result[0]['createdAt']),
          updatedAt: DateTime.parse(result[0]['updatedAt']),
        );
      } else {
         Map<String, dynamic> request = {
           "userId": idUser,
           "chapterId": idChapter,
           "isCompleted": false,
           "isStarted": false,
           "materialDone": false,
           "assessmentDone": false,
           "assignmentDone": false,
           "assessmentAnswer": "[]",
           "submission": "",
           "assessmentGrade": 0,
           "timeStarted": DateTime.now().toUtc().toIso8601String(),
           "timeFinished": DateTime.now().toUtc().toIso8601String()
         };
         final responsePost = await http.post(Uri.parse('${GlobalVar.baseUrl}/userchapter'), headers: {
           'Content-type' : 'application/json; charset=utf-8',
           'Accept': 'application/json',
         }, body: jsonEncode(request));

         if (responsePost.statusCode == 201) {
           final body = responsePost.body;
           final resultPost = jsonDecode(body);
           final resultListAnswer = (jsonDecode(resultPost['userChapter']['assessmentAnswer']) as List)
               .map((item) => item.toString()) // Convert each item to String
               .toList();
           status = ChapterStatus(
               id: resultPost['userChapter']['id'],
               userId: resultPost['userChapter']['userId'],
               chapterId: resultPost['userChapter']['chapterId'],
               isCompleted: resultPost['userChapter']['isCompleted'],
               isStarted: resultPost['userChapter']['isStarted'],
               materialDone: resultPost['userChapter']['materialDone'],
               assessmentDone: resultPost['userChapter']['assessmentDone'],
               assignmentDone: resultPost['userChapter']['assignmentDone'],
               assessmentAnswer: resultListAnswer,
               assessmentGrade: resultPost['userChapter']['assessmentGrade'],
               submission: resultPost['userChapter']['submission'],
               timeStarted: DateTime.parse(resultPost['userChapter']['timeStarted']),
               timeFinished: DateTime.parse(resultPost['userChapter']['timeFinished']),
               createdAt: DateTime.parse(resultPost['userChapter']['createdAt']),
               updatedAt: DateTime.parse(resultPost['userChapter']['updatedAt'])
           );
         }
      }
      return status;
    } catch(e){
      throw Exception(e.toString());
    }
  }

  static Future<ChapterStatus> updateChapterStatus(int id, ChapterStatus user) async {
    try {
      print(user.timeStarted);
      print(user.timeFinished);
      late ChapterStatus status;
      Map<String, dynamic> request = {
        "isStarted": user.isStarted,
        "isCompleted": user.isCompleted,
        "materialDone": user.materialDone,
        "assessmentDone": user.assessmentDone,
        "assignmentDone": user.assignmentDone,
        "assessmentAnswer": jsonEncode(user.assessmentAnswer),
        "submission": user.submission,
        "assessmentGrade": user.assessmentGrade,
        "timeStarted": user.timeStarted.toUtc().toIso8601String(),
        "timeFinished": user.timeFinished.toUtc().toIso8601String(),
      };
      final responsePut = await http.put(Uri.parse('${GlobalVar.baseUrl}/userchapter/$id'), headers: {
        'Content-type' : 'application/json; charset=utf-8',
        'Accept': 'application/json',
      }, body: jsonEncode(request));

      if (responsePut.statusCode == 200) {
        final body = responsePut.body;
        final result = jsonDecode(body);
        final resultListAnswer = (jsonDecode(result['data']['assessmentAnswer']) as List)
            .map((item) => item.toString()) // Convert each item to String
            .toList();
        status = ChapterStatus(
          id: result['data']['id'],
          userId: result['data']['userId'],
          chapterId: result['data']['chapterId'],
          isCompleted: result['data']['isCompleted'],
          isStarted: result['data']['isStarted'],
          materialDone: result['data']['materialDone'],
          assessmentDone: result['data']['assessmentDone'],
          assignmentDone: result['data']['assignmentDone'],
          assessmentAnswer: resultListAnswer,
          assessmentGrade: result['data']['assessmentGrade'],
          submission: result['data']['submission'],
          timeStarted: DateTime.parse(result['data']['timeStarted']),
          timeFinished: DateTime.parse(result['data']['timeFinished']),
          createdAt: DateTime.parse(result['data']['createdAt']),
          updatedAt: DateTime.parse(result['data']['updatedAt']),
        );
      }

      return status;
    } catch(e){
      throw Exception(e.toString());
    }
  }
}