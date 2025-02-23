import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:login/login_screen.dart';
import 'package:login/update_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){}, icon: Icon(LineAwesomeIcons.angle_left_solid)),
        title: Text("Profile", style: Theme.of(context).textTheme.headlineMedium),
        actions: [IconButton(onPressed: (){}, icon: Icon(isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon))],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                        // borderRadius: BorderRadius.circular(100), child: const Image(image: AssetImage())
                        ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.deepPurpleAccent),
                      child: const Icon(
                        LineAwesomeIcons.pencil_alt_solid,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text("Heading", style: Theme.of(context).textTheme.headlineMedium),
              Text("SubHeading", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: (){}, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, side: BorderSide.none, shape: const StadiumBorder(),
                  ),
                  child: const Text("Edit Profile", style: TextStyle(color: Colors.black),),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              ProfileMenuWidget(
                title: "Update Profile",
                icon: LineAwesomeIcons.person_booth_solid,
                onPress: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UpdateProfile()),
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen()
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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

    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    var iconColor = isDark ? Colors.deepPurple : Colors.deepPurpleAccent;

    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: iconColor.withOpacity(0.1),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium?.apply(color: textColor)),
      trailing: endIcon? Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Icon(LineAwesomeIcons.angle_right_solid, size: 18.0, color: Colors.grey)) : null
    );
  }
}