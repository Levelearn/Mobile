import 'package:app/service/course_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/course.dart';
import 'course_detail_screen.dart';

Color purple = Color(0xFF441F7F);
Color backgroundNavHex = Color(0xFFF3EDF7);
const url = 'https://www.globalcareercounsellor.com/blog/wp-content/uploads/2018/05/Online-Career-Counselling-course.jpg';

class MycourseScreen extends StatefulWidget {
  const MycourseScreen({super.key});

  @override
  State<MycourseScreen> createState()  => _CourseDetail();
}

class _CourseDetail extends State<MycourseScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  bool _isFocused = false;
  late SharedPreferences pref;
  List<Course> allCourses = [];
  List<Course> filteredCourses = [];

  @override
  void initState() {
    super.initState();
    getEnrolledCourse();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    _searchController.addListener(_filterCourses);
    filteredCourses = List.from(allCourses); // Initially show all courses
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void getEnrolledCourse() async{
    pref = await SharedPreferences.getInstance();
    int? id = pref.getInt('userId');
    final result = await CourseService.getEnrolledCourse(id!);
    setState(() {
      allCourses = result;
      filteredCourses = result;
    });
  }

  void _filterCourses() {
    String query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        filteredCourses = List.from(allCourses); // Reset list if empty
      });
      return;
    }

    List<Course> newFilteredList = allCourses.where((c) {
      return c.courseName.toLowerCase().contains(query) ||
          c.codeCourse.toLowerCase().contains(query);
    }).toList();

    setState(() {
      filteredCourses = newFilteredList; // Ensures UI updates immediately
    });
  }

  String progressSentence(int progress){
    String sentence = '';
    switch (progress) {
      case >= 0 && <= 20:
        sentence = 'Progressmu baru ${(progress)}%, ayo kerjakan lagi!';
        break;
      case > 20 && <= 40:
        sentence = 'Progressmu baru ${(progress)}%, sudah ada progressmu, yuk kerjakan!';
        break;
      case > 40 && <= 60:
        sentence = 'Progressmu baru ${(progress)}%, jangan patah semangat, ayo!';
        break;
      case > 60 && <= 80:
        sentence = 'Progressmu sudah ${(progress)}%, lumayan, semangat mengerjakannya!';
        break;
      case > 80 && <= 80:
        sentence = 'Progressmu sudah ${(progress)}%, tanggung, ayo kerjakan sedikit lagi, semangat!';
        break;
    }
    return sentence;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 180,
          backgroundColor: purple,
          automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                  child: Center(child: Text('Enrolled Course', style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),),),
                ),
                _buildSearch(),
              ],
            ),
          ),
        ),
        body: _listCourse(),
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: _isFocused ? "" : 'Mau belajar apa hari ini?',
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _listCourse() {
    return ListView.builder(
      itemCount: filteredCourses.length,
      itemBuilder: (context, count) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.0),
          child: _buildCourseItem(filteredCourses[count]),
        );
      },
    );
  }

  Widget _buildCourseItem(Course course) {
    return GestureDetector(
      onTap: () async {
        await pref.setInt('lastestSelectedCourse', course.id);
            Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(id: course.id),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        semanticContainer: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Colors.deepPurple[500],
        elevation: 5,
        margin: EdgeInsets.all(10),
        child:  Column(
          children: [
            Image.network(url, height: 100, width: double.infinity, fit: BoxFit.cover),
            ListTile(
              title: Text(course.codeCourse.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.grey.shade300),),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.courseName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),),
                  Text(course.description!, style: TextStyle(fontSize: 13, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis,),
                  SizedBox(height: 10,),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15), // Ensure the child gets rounded corners
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen.shade400),
                      value: course.progress! / 100,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(progressSentence(course.progress!), style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.white),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}