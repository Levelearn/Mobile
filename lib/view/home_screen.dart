import 'package:app/global_var.dart';
import 'package:app/model/user.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/course.dart';
import '../service/course_service.dart';
import '../service/user_service.dart';
import 'course_detail_screen.dart';

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
  User? user;
  bool isLoading = true;
  Course? lastestCourse;
  int rank = 0;
  int idUser = 0;

  @override
  void initState() {
    super.initState();
    getUserFromSharedPreference();
    getAllUser();
    getEnrolledCourse();
  }

  Future<void> getEnrolledCourse() async{
    pref = await SharedPreferences.getInstance();
    int? id = pref.getInt('userId');
    if(id != null) {
      final result = await CourseService.getEnrolledCourse(id);
      final fetchedUser = await UserService.getUserById(id);
      setState(() {
        allCourses = result;
        user = fetchedUser;
        isLoading = false;
      });
      final idCourse = pref.getInt('lastestSelectedCourse') ?? 0;
      for (var c in allCourses) {
        if(c.id == idCourse){
          setState(() {
            lastestCourse = c;
          });
          break;
        }
      }
    }
  }


  List<User> sortUserbyPoint(List<User> list) {
    list.sort((a, b) => b.points!.compareTo(a.points!));
    return list;
  }

  List<User> studentRole(List<User> list) {
    return list.where((user) => user.role == 'STUDENT').toList();
  }

  void getAllUser() async {
    final result = await UserService.getAllUser();
    setState(() {
      list = sortUserbyPoint(studentRole(result));
    });
    for (int i = 0; i < list.length; i++) {
      if(list[i].id == idUser){
        setState(() {
          rank = i+1;
        });
        break;
      }
    }
  }

  Future<void> getUserFromSharedPreference() async{
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('userId');
    user = await UserService.getUserById(idUser!);
    setState(() {
      name = prefs.getString('name') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10), // Space between progress bar and text
              Text("Mohon Tunggu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
      )
    ) : Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                SizedBox(height: 30,),
                _buildProfile(),
                _buildStats(),
                _buildMyProgress(),
                _buildMore(),
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
            Text('Leaderboard Hari Ini', style: TextStyle(color: purple, fontSize: 20, fontWeight: FontWeight.w800)),
            Column(
              children: list.isNotEmpty ?
              List.generate(list.length > 3 ? 3 : list.length, (index) =>
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
                        , height: 50, width: 50,),
                        title: Text(
                          list[index].username,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        subtitle: Text(
                          list[index].studentId!,
                          style: TextStyle(fontSize: 8, color: Colors.black),
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
                  child: Text(
                      'Belum ada Pengguna',
                      style: TextStyle(
                          fontFamily: 'DIN_Next_Rounded'
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyProgress() {
    return lastestCourse == null ? SizedBox(
      width: double.infinity,
      height: 220,
      child: Center(
        child: Text('Kamu belum ada akses Course'),
      ),
    ) : Stack(
      children: [
        Positioned(
            top: 30,
            right: 30,
            width: 60,
            height: 60,
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
                        width: 80,
                        height: 80,
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Container(
                                width: 70,
                                height: 70,
                                child: new CircularProgressIndicator(
                                  strokeWidth: 10,
                                  value: lastestCourse!.progress! / 100,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                            ),
                            Center(child: Text('${lastestCourse!.progress!}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),)),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        width: 180,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(lastestCourse!.courseName, style: TextStyle(color: purple, fontSize: 15, fontWeight: FontWeight.bold)),
                            Text('Sudah ${lastestCourse!.progress!}%! Lanjutkan Pengerjaan Course', style: TextStyle(color: purple, fontSize: 12, fontWeight: FontWeight.w500)),
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

  Widget _buildProfile() {
    const title = 'Halo! Selamat Belajar';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
          children: [
            Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: GlobalVar.primaryColor,
                    fontFamily: 'DIN_Next_Rounded'
                )),
            Text(
                name,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: GlobalVar.primaryColor,
                    // fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DIN_Next_Rounded'
                )),
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
            child: user != null ?
                Image.network(user!.image!)
                : Icon(Icons.person, size: 30, color: Colors.white, // Icon color
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)
          ),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('lib/assets/pictures/dashboard.png'),
                  fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.start, // Rata kiri untuk row
                    children: [
                      _buildInfoColumn(
                          LineAwesomeIcons.medal_solid, 'Lencana', '${user?.badges}', GlobalVar.accentColor),
                      SizedBox(width: 24), // Jarak antar info
                      _buildInfoColumn(
                          LineAwesomeIcons.user_check_solid, 'Course', '${user?.totalCourses}', GlobalVar.accentColor),
                      SizedBox(width: 24), // Jarak antar info
                      _buildInfoColumn(
                          LineAwesomeIcons.trophy_solid, 'Peringkat', '${rank} / ${list.length}', GlobalVar.accentColor),
                    ],
                  ),
                  SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start, // Menyusun elemen ke kiri
                        crossAxisAlignment:
                        CrossAxisAlignment.center, // Vertikal rata tengah
                        children: [
                          Icon(
                            LineAwesomeIcons
                                .gem_solid, // Icon yang ingin ditampilkan
                            color: GlobalVar.accentColor, // Warna icon
                            size: 24, // Ukuran icon
                          ),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Poin', // Teks yang ingin ditampilkan
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily:
                                  'DIN_Next_Rounded', // Ganti dengan font yang diinginkan
                                ),
                              ),
                              Text('1200',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'DIN_Next_Rounded'))
                            ],
                          ) // Jarak antara icon dan text
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
      IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,  // Menyusun elemen ke kiri
      crossAxisAlignment: CrossAxisAlignment.center,  // Vertikal rata tengah
      children: [
        Icon(
          icon, // Icon yang ingin ditampilkan
          color: color, // Warna icon
          size: 24,  // Ukuran icon
        ),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label, // Teks yang ingin ditampilkan
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(
                // fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily:
                'DIN_Next_Rounded', // Ganti dengan font yang diinginkan
              ),
            ),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'DIN_Next_Rounded'))
          ],
        )// Jarak antara icon dan text
      ],
    );
  }

  Widget _buildMore() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Courses',
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(
              fontWeight: FontWeight.bold,
              color: GlobalVar.primaryColor,
              fontFamily: 'DIN_Next_Rounded',
            ),
          ),
          SizedBox(height: 16),
          CarouselSlider.builder(
            itemCount: allCourses.length,
            itemBuilder: (context, index, realIndex) {
              final course = allCourses[index];
              return _courseCard(course);
            },
            options: CarouselOptions(
              height: 200,
              enlargeCenterPage: false,
              autoPlay: false,
              aspectRatio: 4 / 5,
              viewportFraction: 0.6,
              enableInfiniteScroll: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseCard(
      Course course
      ) {
    return Container(
      width: MediaQuery.of(context).size.width *
          0.8, // Lebar card mengikuti lebar layar
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gambar course
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'lib/assets/pictures/imk-picture.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Box informasi di bawah gambar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GlobalVar.primaryColor, // Background dengan warna primary
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Deskripsi dari mata kuliah ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Label di kanan atas
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: GlobalVar.secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                course.codeCourse,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}