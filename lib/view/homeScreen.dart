import 'package:app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/course.dart';
import '../service/courseService.dart';
import '../service/userService.dart';
import 'courseDetailScreen.dart';

Color purple = Color(0xFF441F7F);
Color backgroundNavHex = Color(0xFFF3EDF7);
const url = 'https://www.globalcareercounsellor.com/blog/wp-content/uploads/2018/05/Online-Career-Counselling-course.jpg';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomeState();
}

class _HomeState extends State<Homescreen> {

  List<Course> allCourses = [];
  double progress = 0.88;
  List<User> list = [];
  String name = '';
  late SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    getUserFromSharedPreference();
    getAllUser();
    getEnrolledCourse();
  }

  void getEnrolledCourse() async{
    pref = await SharedPreferences.getInstance();
    int? id = pref.getInt('userId');
    final result = await CourseService.getEnrolledCourse(id!);
    setState(() {
      allCourses = result;
    });
  }


  List<User> sortUserbyPoint(List<User> list) {
    list.sort((a, b) => b.points.compareTo(a.points));
    return list;
  }

  void getAllUser() async {
    final result = await UserService.getAllUser();
    setState(() {
      list = sortUserbyPoint(result);
    });
  }

  void getUserFromSharedPreference() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 180,
        backgroundColor: purple,
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)
            )
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Only left and right padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensures Column doesn't take extra space
            children: [
              _buildProfile(),
              _buildStatus()
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildMyProgress(),
                _buildExplore(),
                _buildTodayLeaderboard(),
              ],
            )
        ),
      ),
    );
  }

  Widget _buildTodayLeaderboard(){
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Leaderboard Hari Ini', style: TextStyle(color: purple, fontSize: 25, fontWeight: FontWeight.w800)),
            Column(
              children: list.isNotEmpty ?
              List.generate(3, (index) =>
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [(switch (index) {
                            0 => Colors.amber.shade300,
                            1 => Colors.blueGrey.shade400,
                            2 => Colors.orange.shade400,
                            _ => Colors.transparent
                          }), Colors.transparent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                            switch (index) {
                              0 => 'lib/assets/1st.png',
                              1 => 'lib/assets/2nd.png',
                              2 => 'lib/assets/3rd.png',
                              _ => ''
                            }
                        ),
                        title: Text(
                          list[index].username,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        subtitle: Text(
                          list[index].studentId,
                          style: TextStyle(fontSize: 13, color: Colors.black),
                        ),
                        trailing: Text(
                          '${list[index].points} Point',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  )
              ) : [
                Center(
                  child: Text('Belum ada Pengguna'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _buildExplore() {
    return Container(
      width: double.infinity, // Adjust size as needed
      height: 250,
      decoration: BoxDecoration(
        color: Colors.deepPurple[500],
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, -1.7),
            blurRadius: 8,
            spreadRadius: 5,
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 16.0),
      child: Stack(
        children: [
          Positioned(
              bottom: 30,
              right: -45,
              width: 250,
              height: 250,
              child: Transform.scale(
                  scaleX: -1,
                  child: Image.asset('lib/assets/rocket.png')
              )
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(15.0),
                child:
                Text('Jelajahi Lagi', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
              ),
              Container(
                width: double.infinity,// Adjust size as needed
                height: 170,
                margin: EdgeInsets.only(bottom: 10.0, right: 15.0, left: 15.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allCourses.length,
                  itemBuilder: (context, count) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailScreen(id: allCourses[count].id),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 100,// Adjust size as needed
                            height: 100,
                            decoration: BoxDecoration(
                              color: purple,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.fill,
                              ),
                            ),
                            margin: EdgeInsets.all(10.0),
                          ),
                          SizedBox(height: 10),
                          Text(allCourses[count].codeCourse, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 2,)
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ],
      )
    );
  }

  Widget _buildMyProgress() {
    return Stack(
      children: [
          Positioned(
              top: 30,
              right: 30,
              width: 80,
              height: 80,
              child: Image.asset('lib/assets/check.png')
          ),
          SizedBox(
          width: double.infinity,
          height: 220,
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progress Saya', style: TextStyle(color: purple, fontSize: 25, fontWeight: FontWeight.w800)),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Container(
                                width: 100,
                                height: 100,
                                child: new CircularProgressIndicator(
                                  strokeWidth: 10,
                                  value: progress,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                            ),
                            Center(child: Text('${(progress * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),)),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        width: 215,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Interaksi Manusia Komputer', style: TextStyle(color: purple, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Sudah ${(progress * 100).toInt()}%! Lanjutkan Pengerjaan Course', style: TextStyle(color: purple, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStatus() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
          width: double.infinity, // Adjust size as needed
          height: 70,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(15)
          ),
          margin: EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min, // Ensures the column size fits the content (no extra space)
                  children: [
                    Text('Poin', style: TextStyle(color: purple, fontSize: 10)),
                    Text('125K', style: TextStyle(color: purple, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                // SizedBox(width: 20), // Optional space between columns
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0), // Adjust top and bottom padding
                  child: VerticalDivider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                    width: 20, // Space between the column and the line
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min, // Ensures the column size fits the content
                  children: [
                    Text('Poin', style: TextStyle(color: purple, fontSize: 10)),
                    Text('125K', style: TextStyle(color: purple, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                // SizedBox(width: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0), // Adjust top and bottom padding
                  child: VerticalDivider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                    width: 20, // Space between the column and the line
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min, // Ensures the column size fits the content
                  children: [
                    Text('Poin', style: TextStyle(color: purple, fontSize: 10)),
                    Text('125K', style: TextStyle(color: purple, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                // SizedBox(width: 20), // Optional space between columns
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0), // Adjust top and bottom padding
                  child: VerticalDivider(
                    color: Colors.black, // Line color
                    thickness: 1, // Line thickness
                    width: 20, // Space between the column and the line
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min, // Ensures the column size fits the content
                  children: [
                    Text('Poin', style: TextStyle(color: purple, fontSize: 10)),
                    Text('125K', style: TextStyle(color: purple, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }

  Widget _buildProfile() {
    const title = 'Halo! Selamat Belajar';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontSize: 15)),
            Text(name, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          width: 50, // Adjust size as needed
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue, // Background color
            shape: BoxShape.circle, // Makes the container circular
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: 30,
              color: Colors.white, // Icon color
            ),
          ),
        ),
      ],
    );
  }
}