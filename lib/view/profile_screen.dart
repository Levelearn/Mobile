import 'package:app/global_var.dart';
import 'package:app/service/user_service.dart';
import 'package:app/view/update_profile_screeen.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../model/badge.dart';
import '../model/user.dart';
import '../utils/colors.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  late SharedPreferences prefs;
  Student? user;
  bool isLoading = true;
  List<Student> list = [];
  int rank = 0;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  Future<void> getUserData() async {
    prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('userId');
    if (idUser != null) {
      Student fetchedUser = await UserService.getUserById(idUser);
      print(user?.image);
      setState(() {
        user = fetchedUser;
        isLoading = false;
      });
    }
  }

  void getAllUser() async {
    final result = await UserService.getAllUser();
    setState(() {
      list = studentRole(result);
    });
    for (int i = 0; i < list.length; i++) {
      if(list[i].id == user?.id){
        setState(() {
          rank = i+1;
        });
        print(rank);
        break;
      }
    }
  }

  List<Student> studentRole(List<Student> list) {
    return list.where((user) => user.role == 'STUDENT').toList();
  }

  void logout() {
    prefs.remove('userId');
    prefs.remove('name');
    prefs.remove('role');
    prefs.remove('token');
  }

  List<BadgeModel> userBadges = [
    BadgeModel(
      image: 'lib/assets/pictures/icon.png',
      name: 'UX Researcher',
      type: 'Beginner',
      course: 'Interaksi Manusia Komputer',
      chapter: '2',
    ),
    BadgeModel(
      image: 'lib/assets/pictures/icon.png',
      name: 'UX Researcher',
      type: 'Intermediate',
      course: 'Interaksi Manusia Komputer',
      chapter: '4',
    ),
    BadgeModel(
      image: 'lib/assets/pictures/icon.png',
      name: 'UX Researcher',
      type: 'Advance',
      course: 'Interaksi Manusia Komputer',
      chapter: '6',
    ),
    BadgeModel(
      image: 'lib/assets/pictures/icon.png',
      name: 'OS Engineer',
      type: 'Beginner',
      course: 'Sistem Operasi',
      chapter: '2',
    ),
    BadgeModel(
      image: 'lib/assets/pictures/icon.png',
      name: 'OS Engineer',
      type: 'Intermediate',
      course: 'Sistem Operasi',
      chapter: '4',
    ),
    BadgeModel(
      image: 'lib/assets/pictures/icon.png',
      name: 'OS Engineer',
      type: 'Advance',
      course: 'Sistem Operasi',
      chapter: '6',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
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
      appBar: AppBar(
        backgroundColor: GlobalVar.primaryColor,
        leading: IconButton(
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Mainscreen()),
              );
            },
            icon: Icon(LineAwesomeIcons.angle_left_solid, color: Colors.white,)),
        title: Text(
            "Profile",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontFamily: 'DIN_Next_Rounded',
                color: Colors.white
            )),
        actions: [IconButton(onPressed: (){}, icon: Icon(isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon))],
      ),
      body:  Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        'lib/assets/pictures/background-pattern.png'),
                    fit: BoxFit.cover
                )
            ),
          ),
          SingleChildScrollView(
            child: Container(
              // padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    color: GlobalVar.primaryColor,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: user?.image != "" && user?.image != null ? Image.network(user!.image!)
                                    : Icon(Icons.person, size: 100, color: Colors.white,),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => UpdateProfile(user: user!,)),
                                  );
                                },
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: GlobalVar.secondaryColor),
                                  child: const Icon(
                                    LineAwesomeIcons.pencil_alt_solid,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              )
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(user!.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontFamily: 'DIN_Next_Rounded',
                                color: Colors.white
                            )),
                        Text(user!.studentId!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontFamily: 'DIN_Next_Rounded',
                                color: GlobalVar.accentColor
                            )),
                        const SizedBox(height: 16),
                        // const Divider(),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 32),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 24,
                            children: [
                              _buildInfoColumn(LineAwesomeIcons.medal_solid,
                                  'Lencana', '${user?.badges}', GlobalVar.secondaryColor),
                              _buildInfoColumn(LineAwesomeIcons.user_check_solid,
                                  'Course', '${user?.totalCourses}', GlobalVar.secondaryColor),
                              _buildInfoColumn(LineAwesomeIcons.trophy_solid,
                                  'Peringkat', '$rank', GlobalVar.secondaryColor),
                              _buildInfoColumn(LineAwesomeIcons.gem_solid,
                                  'Poin', '${user?.points}', GlobalVar.secondaryColor)
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Badge Saya',
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                            fontFamily: 'DIN_Next_Rounded',
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          height: 64,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: userBadges.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _showBadgeDetails(context, userBadges[index]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      userBadges[index].image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),

                  ProfileMenuWidget(
                    title: "Update Profile",
                    icon: LineAwesomeIcons.person_booth_solid,
                    onPress: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => UpdateProfile(user: user!,)),
                      );
                    },
                  ),

                  ProfileMenuWidget(
                    title: "Quick Access",
                    icon: LineAwesomeIcons.accessible,
                    onPress: () {},
                  ),
                  ProfileMenuWidget(
                    title: "App Rating",
                    icon: LineAwesomeIcons.star,
                    onPress: () {},
                  ),
                  ProfileMenuWidget(
                    title: "About App",
                    icon: LineAwesomeIcons.info_circle_solid,
                    onPress: () {},
                  ),
                  ProfileMenuWidget(
                    title: "Logout",
                    icon: LineAwesomeIcons.arrow_circle_left_solid,
                    textColor: Colors.red,
                    endIcon: false,
                    onPress: () {
                      logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen()
                        ),
                      );
                    },
                  ),
                  SizedBox(
                      height: 16
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                          ),
                          child: Text("Log Out", style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontFamily: 'DIN_Next_Rounded',
                              color: Colors.white
                          ),)
                      ),
                    ),
                  ),
                  SizedBox(
                      height: 16
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, BadgeModel badge) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(badge.image)
              ),
              SizedBox(height: 16),
              Text(
                  badge.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'DIN_Next_Rounded',
                      color: AppColors.primaryColor,
                      fontSize: 16
                  )),
              Text('(${badge.type})',style: TextStyle(fontFamily: 'DIN_Next_Rounded')),
              SizedBox(height: 8),
              Text('Badge ini diperoleh karena telah berhasil menyelesaikan ${badge.course} sampai pada chapter ${badge.chapter}', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'DIN_Next_Rounded')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Tutup', style: TextStyle(fontFamily: 'DIN_Next_Rounded')),
            ),
          ],
        );
      },
    );
  }


  Widget _buildInfoColumn(
      IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28,),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                // fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily:
                'DIN_Next_Rounded',
              ),
            ),
            Text(value,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: GlobalVar.primaryColor,
                    fontFamily: 'DIN_Next_Rounded'))
          ],
        )
      ],
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery
        .of(context)
        .platformBrightness == Brightness.dark;
    var iconColor = isDark ? GlobalVar.accentColor : GlobalVar.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
          onTap: onPress,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: AppColors.primaryColor,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title, style: Theme
              .of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
            color: textColor,
            fontFamily: 'DIN_Next_Rounded',
          )),
          trailing: endIcon ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(LineAwesomeIcons.angle_right_solid, size: 18.0,
                  color: Colors.grey)) : null
      ),
    );
  }
}