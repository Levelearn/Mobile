import 'package:app/view/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'login_screen.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileScreen()),
            );
          }, 
          icon: const Icon(LineAwesomeIcons.angle_left_solid)),
        title: Text("Update Profile", style: Theme.of(context).textTheme.headlineMedium),
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
                      borderRadius: BorderRadius.circular(100), child: const Image(image: AssetImage("Profile Image")),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.deepPurple),
                      child: const Icon(
                        LineAwesomeIcons.camera_solid,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Form(child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                      prefixIconColor: Colors.green,
                      floatingLabelStyle: const TextStyle(color: Colors.green),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2 ,color: Colors.green),
                      ),
                      label: Text("Name"),
                      prefixIcon: Icon(LineAwesomeIcons.person_booth_solid)
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100)),
                        prefixIconColor: Colors.green,
                        floatingLabelStyle:
                            const TextStyle(color: Colors.green),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Colors.green),
                        ),
                      label: Text("Username"),
                      prefixIcon: Icon(LineAwesomeIcons.user) 
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100)),
                        prefixIconColor: Colors.green,
                        floatingLabelStyle:
                            const TextStyle(color: Colors.green),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Colors.green),
                        ),
                      label: Text("Password"),
                      prefixIcon: Icon(LineAwesomeIcons.fingerprint_solid)
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
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
                        backgroundColor: Colors.deepPurple,
                        side: BorderSide.none,
                        shape: const StadiumBorder()
                      ),
                      child: Text("Save", style: TextStyle(color: Colors.black),)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text.rich(
                        TextSpan(
                          text: "Joined",
                          style: TextStyle(fontSize: 12),
                          children: [
                            TextSpan(text: "6 Agustus 2004", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
                          ],
                        )
                      ),
                      ElevatedButton(
                        onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          elevation: 0,
                          foregroundColor: Colors.red,
                            shape: const StadiumBorder(),
                            side: BorderSide.none
                          ),
                        child: const Text("Delete"),
                      )
                    ],
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}