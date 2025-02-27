import 'dart:convert';
import 'package:app/model/login.dart';
import 'package:http/http.dart' as http;

import '../global_var.dart';
import '../model/user.dart';

class UserService {
  static Future<List<Student>> getAllUser() async {
    try {
      final response = await http.get(Uri.parse('${GlobalVar.baseUrl}/user'));
      final body = response.body;
      final result = jsonDecode(body);
      List<Student> users = List<Student>.from(
        result.map(
            (user) => Student.fromJson(user),
        ),
      );
      return users;
    } catch(e){
      throw Exception(e.toString());
    }
  }

  static Future<Student> getUserById(int id) async {
    try {
      final response = await http.get(Uri.parse('${GlobalVar.baseUrl}/user/$id'));
      final body = response.body;
      final result = jsonDecode(body);
      Student users = Student.fromJson(result);
      return users;
    } catch(e){
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      Map<String, dynamic> request = {
        'username':'$username',
        'password':'$password'
      };
      final response = await http.post(Uri.parse('${GlobalVar.baseUrl}/login'), headers: {
        'Content-type' : 'application/json; charset=utf-8',
        'Accept': 'application/json',
      } , body: jsonEncode(request));


      if (response.statusCode == 200) {
        final body = response.body;
        final result = jsonDecode(body);
        Login login = Login(
            id: result['data']['id'],
            name: result['data']['name'],
            role: result['data']['role'],
            token: result['token']
        );
        return {
          'value': login,
          'code': response.statusCode
        };
      } else {
        return {
          'code': response.statusCode,
          'message': jsonDecode(response.body)['message']
        };
      }
    } catch(e) {
      throw Exception(e.toString());
    }
  }

  static Future<Student> updateUser(Student user) async {
    try {
      Map<String, dynamic> request = {
        "name": user.name,
        "username": user.username,
        "password": user.password,
        "role": user.role,
        "studentId": user.studentId,
        "points": user.points,
        "totalCourses": user.totalCourses,
        "badges": user.badges,
        "image": user.image,
        "instructorId": user.instructorId,
        "instructorCourses": user.instructorCourses
      };
      final response = await http.put(Uri.parse('${GlobalVar.baseUrl}/user/${user.id}'), headers: {
        'Content-type' : 'application/json; charset=utf-8',
        'Accept': 'application/json',
      } , body: jsonEncode(request));

      final body = response.body;
      print(body);
      final result = jsonDecode(body);
      print(result);
      Student users = Student.fromJson(result['user']);
      return users;
    } catch(e){
      throw Exception(e.toString());
    }
  }
}