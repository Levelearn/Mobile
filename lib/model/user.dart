class User {
  final int id;
  final String username;
  final String password;
  final String name;
  final String role;
  String? studentId;
  int? points;
  int? totalCourses;
  int? badges;
  String? instructorId;
  int? instructorCourses;
  String? image;
  final DateTime createdAt;
  final DateTime updatedAt;


  User ({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    this.studentId,
    this.points,
    this.totalCourses,
    this.badges,
    this.instructorId,
    this.instructorCourses,
    this.image,
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
      image: json['image'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}