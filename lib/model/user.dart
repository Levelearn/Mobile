class User {
  final int id;
  final String username;
  final String password;
  final String name;
  final String role;
  final String studentId;
  final int points;
  final int totalCourses;
  final int badges;
  final String? instructorId;
  final int? instructorCourses;
  final DateTime createdAt;
  final DateTime updatedAt;


  User ({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    required this.studentId,
    required this.points,
    required this.totalCourses,
    required this.badges,
    this.instructorId,
    this.instructorCourses,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      name: json['name'],
      role: json['role'],
      studentId: json['studentId'],
      points: json['points'],
      totalCourses: json['totalCourses'],
      badges: json['badges'],
      instructorId: json['instructorId'],
      instructorCourses: json['instructorCourses'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}