import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/user_course.dart';

class UserCourseService {
  static const String baseUrl = 'http://192.168.247.187:3000/api';

  static Future<UserCourse> getUserCourse(int idUser, int idCourse) async {
    try {
      late UserCourse status;
      final response = await http.get(Uri.parse('$baseUrl/usercourse/$idUser/$idCourse'));
      final body = response.body;
      final result = jsonDecode(body);
      print(result);
      if (result is List && result.isNotEmpty) {
        status = UserCourse.fromJson(result[0]);
      }
      return status;
    } catch(e){
      throw Exception(e.toString());
    }
  }

  static Future<void> updateUserCourse(int id, UserCourse uc) async {
    try {
      Map<String, dynamic> request = {
        "userId": uc.userId,
        "courseId": uc.courseId,
        "progress": uc.progress,
        "currentChapter": uc.currentChapter,
        "isCompleted": uc.isCompleted,
        "enrolledAt": uc.enrolledAt.toIso8601String()
      };
      final responsePut = await http.put(Uri.parse('$baseUrl/usercourse/$id'), headers: {
        'Content-type' : 'application/json; charset=utf-8',
        'Accept': 'application/json',
      }, body: jsonEncode(request));

      if (responsePut.statusCode == 200) {
        print("Update Successful");
      }
    } catch(e){
      throw Exception(e.toString());
    }
  }
}