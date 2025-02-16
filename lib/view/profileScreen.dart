import 'package:flutter/material.dart';

const _purpleHex = '#441F7F';
const _backgroundNavHex = '#F3EDF7';
Color purple = Color(int.parse(_purpleHex.substring(1, 7), radix: 16) + 0xFF000000);
Color backgroundNavHex = Color(int.parse(_backgroundNavHex.substring(1, 7), radix: 16) + 0xFF000000);
const url = 'https://www.globalcareercounsellor.com/blog/wp-content/uploads/2018/05/Online-Career-Counselling-course.jpg';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfileState();
}

class _ProfileState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 280,
        backgroundColor: purple,
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)
            )
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Only left and right padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensures Column doesn't take extra space
            children: [
              _buildProfile(),
              _buildStatus(),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(0, -1.7),
                          blurRadius: 8,
                          spreadRadius: 5,
                        ),
                      ],
                  ),
                  child: Padding(padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lencana Saya', style: TextStyle(color: purple, fontSize: 20, fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildBadgeItem(url),
                            _buildBadgeItem(url),
                            _buildBadgeItem(url),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
        ),
      ),
    );
  }

  Container _buildBadgeItem(String imageUrl) {
    return Container(
      width: 90,
      height: 90,
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey, width: 1.0, style: BorderStyle.solid),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Padding _buildStatus() {
    return Padding(padding: EdgeInsets.only(top: 20.0),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(padding: EdgeInsets.all(10.0),
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Poin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                                Text('12.500 Pts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: purple),),
                              ],
                            ),
                          ),
                        ),
                      )
                  ),
                  Expanded(
                      child: Padding(padding: EdgeInsets.all(10.0),
                        child: Container(// Adjust size as needed
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Peringkat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                                Text('12 / 45', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: purple),),
                              ],
                            ),
                          ),
                        ),
                      )
                  ),
                ],
              ),
            );
  }

  Widget _buildProfile() {
    return Center(
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(bottom: 10),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(url),
                      child: Icon(Icons.person, size: 20,),
                    ),
                  ),
                  Text('Archico Sembiring', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),),
                  Text('11S21011', style: TextStyle(color: Colors.white, fontSize: 15),)
                ],
              ),
            );
  }
}