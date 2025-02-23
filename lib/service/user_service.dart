import 'dart:convert';
import 'package:app/model/login.dart';
import 'package:http/http.dart' as http;

import '../model/user.dart';

class UserService {
  static const String baseUrl = 'http://192.168.247.187:3000/api';
  static Future<List<User>> getAllUser() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user'));
      final body = response.body;
      final result = jsonDecode(body);
      List<User> users = List<User>.from(
        result.map(
            (user) => User.fromJson(user),
        ),
      );
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
      final response = await http.post(Uri.parse('$baseUrl/login'), headers: {
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
}