import 'package:app/service/user_service.dart';
import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';

import '../model/user.dart';

Color purple = Color(0xFF441F7F);
Color backgroundNavHex = Color(0xFFF3EDF7);
const url = 'https://www.globalcareercounsellor.com/blog/wp-content/uploads/2018/05/Online-Career-Counselling-course.jpg';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FriendsScreen();
}

class _FriendsScreen extends State<FriendsScreen> {

  List<Student> user = [];

  List<Student> sortUserbyPoint(List<Student> list) {
    list.sort((a, b) => b.points!.compareTo(a.points!));
    return list;
  }

  List<Student> studentRole(List<Student> list) {
    return list.where((user) => user.role == 'STUDENT').toList();
  }

  void getAllUser() async {
    final result = await UserService.getAllUser();
    setState(() {
      user = sortUserbyPoint(studentRole(result));
    });
  }

  @override
  void initState() {
    super.initState();
    getAllUser();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
            toolbarHeight: 450,
            backgroundColor: AppColors.primaryColor,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Papan Peringkat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24, fontFamily: 'DIN_Next_Rounded'),),
                  _buildLeaderBoard(user),
                ],
              ),
            ),
          ),
          body: _listFriends(),
        )
      ],
    );
  }

  Widget _listFriends() {
    user = sortUserbyPoint(user);
    return ListView.builder(
      itemCount: user.length,
      itemBuilder: (context, count) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: _listFriendsItem(user[count], count),
        );
      },
    );
  }

  Widget _listFriendsItem(Student user, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ (switch (index) {
              0 => Colors.amber.shade300,
              1 => Colors.blueGrey.shade400,
              2 => Colors.orange.shade400,
              _ => Colors.grey.shade300
            }), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: index <= 2 ? Image.asset(
              switch (index) {
                0 => 'lib/assets/1st.png',
                1 => 'lib/assets/2nd.png',
                2 => 'lib/assets/3rd.png',
                _ => ''
              }
          ) : Text('#${index + 1}', style: TextStyle(fontSize: 25),),
          title: Text(
            user.name,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'DIN_Next_Rounded'),
          ),
          subtitle: Text(
            user.studentId!,
            style: TextStyle(fontSize: 12, color: Colors.black, fontFamily: 'DIN_Next_Rounded'),
          ),
          trailing: Text(
            '${user.points} Point',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'DIN_Next_Rounded'),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderBoard(List<Student> list) {
    return Container(
      margin: EdgeInsets.all(16),
      height: 300,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              list.isNotEmpty && list.length >= 2 && list[1].image != "" && list[1].image != null ?
              CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(list[1].image!)) :
              CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 20,)),
              Text(list.isNotEmpty && list.length >= 2? list[1].name : '', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'DIN_Next_Rounded'),),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                    padding: EdgeInsets.all(10),
                  child: Text('${list.isNotEmpty && list.length >= 2 ? list[1].points : 0} pts', style: TextStyle(fontSize: 12, fontFamily: 'DIN_Next_Rounded'),),
                ),
              ),
              SizedBox(
                height: 10,
                width: 10,
              ),
              Container(
                width: 75,
                height: 120,
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade400,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: Center(child: Text('#2', style: TextStyle(color: Colors.white, fontFamily: 'DIN_Next_Rounded', fontSize: 24, fontWeight: FontWeight.w900)),),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              list.isNotEmpty && list[0].image != "" && list[0].image != null ?
              CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(list[0].image!)) :
              CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 20,)),
              Text(list.isNotEmpty ? list[0].name : '', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'DIN_Next_Rounded'),),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('${list.isNotEmpty? list[0].points : 0} pts', style: TextStyle(fontSize: 12, fontFamily: 'DIN_Next_Rounded'),),
                ),
              ),
              SizedBox(
                height: 10,
                width: 10,
              ),
              Container(
                width: 75,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.amber.shade300,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: Center(child: Text('#1', style: TextStyle(color: Colors.white, fontFamily: 'DIN_Next_Rounded', fontSize: 24, fontWeight: FontWeight.w900)),),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              list.isNotEmpty && list.length >= 3 && list[2].image != "" && list[2].image != null ?
              CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(list[2].image!)) :
              CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 20,)),
              Text(list.isNotEmpty && list.length >= 3 ? list[2].name : '', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'DIN_Next_Rounded'),),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('${list.isNotEmpty && list.length >= 3 ? list[2].points : 0} pts', style: TextStyle(fontSize: 12, fontFamily: 'DIN_Next_Rounded'),),
                ),
              ),
              SizedBox(
                height: 10,
                width: 10,
              ),
              Container(
                width: 75,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                  ),
                ),
                child: Center(child: Text('#3', style: TextStyle(color: Colors.white, fontFamily: 'DIN_Next_Rounded', fontSize: 24, fontWeight: FontWeight.w900)),),
              )
            ],
          ),
        ],
      ),
    );
  }
}
