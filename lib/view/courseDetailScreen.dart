import 'package:app/model/chapter.dart';
import 'package:app/main.dart';
import 'package:app/service/courseService.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/course.dart';
import 'chapterScreen.dart';

const url = 'https://www.globalcareercounsellor.com/blog/wp-content/uploads/2018/05/Online-Career-Counselling-course.jpg';

class CourseDetailScreen extends StatefulWidget {
  final int id; // Add course parameter

  const CourseDetailScreen({super.key, required this.id});

  @override
  State<CourseDetailScreen> createState()  => _CourseDetail();
}

class _CourseDetail extends State<CourseDetailScreen> {
  Course? courseDetail;
  List<Chapter> listChapter = [];
  double progressValue = 5.0;
  double progressAll = 0.0;
  int listQuestion = 0;
  bool allQuestionsAnswered = false;
  PlatformFile? selectedFile;
  late SharedPreferences pref;
  int idCourse = 0;

  @override
  void initState() {
    getCourseDetail();
    super.initState();
  }

  void getCourseDetail() async {
    pref = await SharedPreferences.getInstance();
    setState(() {
      idCourse = pref.getInt('lastestSelectedCourse') ?? 0;
      print(idCourse);
    });
    final  result = await CourseService.getCourse(idCourse);
    setState(() {
      courseDetail = result;
    });
    getChapter(idCourse);
  }

  void getChapter(int id) async {
    final result = await CourseService.getChapterByCourse(id);
    setState(() {
      listChapter = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return idCourse != 0 && courseDetail != null ? Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(300.0),
        child: Container(
          decoration: BoxDecoration(
            color: purple,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              SizedBox(
                width: double.infinity,
                child: Container(
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        purple,
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      stops: const [0, 0.8],
                    ),
                  ),
                  child: Image.network(url, height: 150, fit: BoxFit.cover,),
                ),
              ),
              SizedBox(height: 10,),
              Text('${courseDetail?.courseName}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
              SizedBox(height: 10,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text('${courseDetail?.description}', textAlign: TextAlign.justify, style: TextStyle(color: Colors.white, fontSize: 13), maxLines: 8,),
              )
            ],
          ),
        )
      ),
      body:Padding(padding: EdgeInsets.symmetric(vertical: 20),
        child: ListView.builder(
          itemCount: listChapter.length,
          itemBuilder: (context, count) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.0),
              child: _buildCourseItem(count),
            );
          },
        ),
      ),
    ) : Scaffold(
      body: Center(
        child: Column(
          children: [
            Image.asset('lib/assets/empty.png'),
            SizedBox(height: 20,),
            Text('Kamu belum ada akses Course'),
          ],
        )
      ),
    );
  }

  Widget _buildCourseItem(int index) {
    return Card(
      color: purple,
      child: ListTile(
        leading: Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1AAD21),
          ),
          child: Center(
            child:
            Text('${listChapter[index].level}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),),
          ),
        ),
        title: Text(listChapter[index].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(listChapter[index].description, style: TextStyle( fontSize: 13, color: Colors.white),),
            SizedBox(height: 5,),
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color:Color(0xFFCDCDCD), // Background color for the progress bar
              ),
              child: Stack(
                children: [
                  Container(
                    width: 300,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.shade400, // Background color
                    ),
                  ),
                  Container(
                    width: 300 * (progressAll / 3), // Adjust width dynamically
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(0xFF1AAD21),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: purple, width: 3)
                    ),
                  ),
                  Positioned(
                    left: (300 * (progressAll / 3)) / 2 - 15,
                    child: Text(
                      "${((progressAll / 3) * 100).toInt()}%",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Contrast with progress bar
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chapterscreen(),
            ),
          );

          if (result != null) {
            setState(() {
              progressValue = result['progress'];
              allQuestionsAnswered = result['allAnswered'];
              selectedFile = result['file'];

              progressAll = progressValue + (allQuestionsAnswered ? 1 : 0) + (selectedFile != null ? 1 : 0);
            });
          }
        },
      ),
    );
  }
}