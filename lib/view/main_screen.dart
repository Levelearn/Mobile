import 'package:app/view/chapter_screen.dart';
import 'package:app/view/course_detail_screen.dart';
import 'package:app/view/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'friends_screen.dart';
import 'home_screen.dart';
import 'mycourse_screen.dart';

Color purple = Color(0xFF441F7F);
Color backgroundNavHex = Color(0xFFF3EDF7);
const url = 'https://www.globalcareercounsellor.com/blog/wp-content/uploads/2018/05/Online-Career-Counselling-course.jpg';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainState();
}

class _MainState extends State<Mainscreen> {
  int navIndex = 2;
  late SharedPreferences pref;
  int idCourse = 0;

  void getCourseDetail() async {
    pref = await SharedPreferences.getInstance();
    setState(() {
      idCourse = pref.getInt('getCourseDetail') ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    getCourseDetail();
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const Homescreen();
      case 1:
        return const MycourseScreen();
      case 2:
        return CourseDetailScreen(id: idCourse);
      case 3:
        return const FriendsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const Homescreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(navIndex),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: backgroundNavHex,
          onTap: (index){
            setState(() {
              navIndex = index;
            });
          },
          currentIndex: navIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
                backgroundColor: Colors.black
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Course',
                backgroundColor: Colors.black
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_outlined),
                label: 'Friends',
                backgroundColor: Colors.black
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
                backgroundColor: Colors.black
            )
          ]
      ),
    );
  }

}