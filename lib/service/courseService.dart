import 'dart:convert';
import 'package:app/model/chapter.dart';
import 'package:http/http.dart' as http;

import '../model/course.dart';

class CourseService {
  static const String baseUrl = 'http://192.168.247.187:3000/api';
  static Future<List<Course>> getEnrolledCourse(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/$id/courses'));
      final body = response.body;
      final result = jsonDecode(body);
      List<Course> courses = List<Course>.from(
        result.map(
              (result) => Course(
                  id: result['id'],
                  courseName: result['name'],
                  codeCourse: result['code'],
                  description: result['description'],
                  createdAt: DateTime.parse(result['createdAt']),
                  updatedAt: DateTime.parse(result['updatedAt']),
                  progress: 50
              ),
        ),
      );
      return courses;
    } catch(e){
      throw Exception(e.toString());
    }
  }

  static Future<Course> getCourse(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/course/$id'));
      final body = response.body;
      final result = jsonDecode(body);
      Course courses = Course(
        id: result['id'],
        courseName: result['name'],
        codeCourse: result['code'],
        description: result['description'],
        createdAt: DateTime.parse(result['createdAt']),
        updatedAt: DateTime.parse(result['updatedAt']),
        progress: 50
      );
      return courses;
    } catch(e){
      throw Exception(e.toString());
    }
  }

  static Future<List<Chapter>> getChapterByCourse(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/course/$id/chapters'));
      final body = response.body;
      final result = jsonDecode(body);
      print(result);
      List<Chapter> chapter = List.from(
        result.map(
            (result) => Chapter(
                id: result['id'],
                name: result['name'],
                description: result['description'],
                level: result['level'],
                courseId: result['courseId'],
                createdAt: DateTime.parse(result['createdAt']),
                updatedAt: DateTime.parse(result['updatedAt']),
            )
        )
      );
      return chapter;
    } catch(e){
      throw Exception(e.toString());
    }
  }
}