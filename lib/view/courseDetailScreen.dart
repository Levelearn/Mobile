import 'package:app/model/chapter.dart';
import 'package:app/main.dart';
import 'package:app/model/chapterStatus.dart';
import 'package:app/service/courseService.dart';
import 'package:app/service/userChapterService.dart';
import 'package:app/service/userCourseService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/course.dart';
import '../model/userCourse.dart';
import 'chapterScreen.dart';

const url = 'https://www.globalcareercounsellor.com/blog/wp-content/uploads/2018/05/Online-Career-Counselling-course.jpg';

class CourseDetailScreen extends StatefulWidget {
  final int id;

  const CourseDetailScreen({super.key, required this.id});

  @override
  State<CourseDetailScreen> createState()  => _CourseDetail();
}

class _CourseDetail extends State<CourseDetailScreen> {
  Course? courseDetail;
  List<Chapter> listChapter = [];
  late SharedPreferences pref;
  int idCourse = 0;
  int idUser = 0;
  bool isLoading = true;
  UserCourse? uc;

  @override
  void initState() {
    getCourseDetail();
    getUserFromSharedPreference();
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

  void getUserCourse() async {
    uc = await UserCourseService.getUserCourse(idUser, idCourse);
  }

  void updateUserCourse() async {
    await UserCourseService.updateUserCourse(uc!.id, uc!);
  }

  void getChapter(int id) async {
    setState(() {
      isLoading = true; // Start loading
    });

    final result = await CourseService.getChapterByCourse(id);
    final updatedList = await getStatusChapter(result);

    setState(() {
      listChapter = updatedList;
      isLoading = false; // Stop loading
    });
  }

  Future<List<Chapter>> getStatusChapter(List<Chapter> list) async {
    await Future.forEach(list, (Chapter chapter) async {
      chapter.status = await UserChapterService.getChapterStatus(idUser, chapter.id);
    });
    return list;
  }

  void getUserFromSharedPreference() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idUser = prefs.getInt('userId') ?? 0;
    });
    if (idUser != 0 && idCourse != 0) {
      getUserCourse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return idCourse != 0 && courseDetail != null ? Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(320.0),
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
                child: Text('${courseDetail?.description}', textAlign: TextAlign.justify, style: TextStyle(color: Colors.white, fontSize: 10), maxLines: 8,),
              )
            ],
          ),
        )
      ),
      body: isLoading ? Column(
        mainAxisSize: MainAxisSize.min, // Align center vertically
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10), // Space between progress bar and text
          Text("Mohon Tunggu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ) : Padding(padding: EdgeInsets.symmetric(vertical: 20),
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
            Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: listChapter[index].status!.materialDone ? Image.asset('lib/assets/starfilled.png', width: 25, height: 25,) : Image.asset('lib/assets/starempty.png', width: 25, height: 25,),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: listChapter[index].status!.assessmentDone ? Image.asset('lib/assets/starfilled.png', width: 25, height: 25,) : Image.asset('lib/assets/starempty.png', width: 25, height: 25,),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: listChapter[index].status!.assignmentDone ? Image.asset('lib/assets/starfilled.png', width: 25, height: 25,) : Image.asset('lib/assets/starempty.png', width: 25, height: 25,),
                  )
                ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () async {
          uc?.currentChapter = uc!.currentChapter < listChapter[index].level ? listChapter[index].level : uc!.currentChapter;
          updateUserCourse();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chapterscreen(
                status: listChapter[index].status!,
                chapterIndexInList: index,
                uc: uc!,
                chLength: listChapter.length,
              ),
            ),
          );

          if (result != null) {
            setState(() {
              listChapter[result['index']].status = ChapterStatus.fromJson(result['status']);
            });
          }
        },
      ),
    );
  }
}