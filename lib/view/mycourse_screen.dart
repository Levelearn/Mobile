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

  void getEnrolledCourse() async {
    try {
      pref = await SharedPreferences.getInstance();
      int? id = pref.getInt('userId');
      if (id == null) return;

      final result = await CourseService.getEnrolledCourse(id);
      if (!mounted) return;

      setState(() {
        allCourses = result;
        filteredCourses = result;
      });
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    }
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

  String progressSentence(int progress) {
    if (progress <= 20) {
      return 'Progressmu baru $progress%, ayo kerjakan lagi!';
    } else if (progress <= 40) {
      return 'Progressmu baru $progress%, sudah ada progressmu, yuk kerjakan!';
    } else if (progress <= 60) {
      return 'Progressmu baru $progress%, jangan patah semangat, ayo!';
    } else if (progress <= 80) {
      return 'Progressmu sudah $progress%, lumayan, semangat mengerjakannya!';
    } else {
      return 'Progressmu sudah $progress%, tanggung, ayo kerjakan sedikit lagi, semangat!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Change this to your desired background color
              image: DecorationImage(
                image: AssetImage("lib/assets/learnbg.png"), // Background image
                fit: BoxFit.cover,
                opacity: 0.7
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
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
                      child: Center(child: Text('Enrolled Course', style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'DIN_Next_Rounded',),),),
                    ),
                    _buildSearch(),
                  ],
                ),
              ),
            ),
            body: _listCourse(),
          ),
        ],
      )
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: _isFocused ? "" : 'Mau belajar apa hari ini?',
        hintStyle: TextStyle(color: Colors.grey, fontFamily: 'DIN_Next_Rounded',),
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
                  Text(course.courseName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white, fontFamily: 'DIN_Next_Rounded',),),
                  Text(course.description!, style: TextStyle(fontSize: 13, color: Colors.white, fontFamily: 'DIN_Next_Rounded',), maxLines: 2, overflow: TextOverflow.ellipsis,),
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
                  Text(progressSentence(course.progress!), style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.white, fontFamily: 'DIN_Next_Rounded',),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}