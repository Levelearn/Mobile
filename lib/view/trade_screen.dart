import 'package:app/model/trade.dart';
import 'package:app/service/trade_service.dart';
import 'package:app/utils/colors.dart';
import 'package:app/view/main_screen.dart';
import 'package:app/view/trade_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

class TradeScreen extends StatefulWidget {
  final Student user;
  const TradeScreen({super.key, required this.user});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {

  late SharedPreferences pref;
  List<TradeModel> trades = [];

  @override
  void initState() {
    super.initState();
    getAllTrades();

    trades = trades;
  }

  void getAllTrades() async {
    try {
      final result = await TradeService.getAllTrades();
      if (!mounted) return;

      setState(() {
        trades = result;
      });
    } catch (e) {
      debugPrint("Error fetching trades: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trade"),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Mainscreen()),
              );
            },
            icon: Icon(LineAwesomeIcons.angle_left_solid, color: Colors.white,)),
        titleTextStyle: TextStyle(
            fontFamily: 'DIN_Next_Rounded',
            fontSize: 24,
            color: Colors.white
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'lib/assets/pictures/background-pattern.png'
            ), // Ganti dengan path gambar Anda
            fit: BoxFit.cover, // Menyesuaikan gambar agar mengisi layar
          ),
        ),
        child: trades.isEmpty
            ? Center(
              child: Text('Penawaran belum tersedia',
                  style: TextStyle(
                      fontFamily: 'DIN_Next_Rounded',
                      color: AppColors.primaryColor
                  )
              ),
            )
            : ListView.builder(
              itemCount: trades.length,
              itemBuilder: (context, index) {
                final trade = trades[index];
                return ListTile(
                  leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(trade.image)),
                  title: Text(
                      trade.title,
                      style: TextStyle(
                          fontFamily: 'DIN_Next_Rounded',
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor
                      )),
                  subtitle: Text(
                    'Tukarkan badge ${trade.requiredBadgeType} anda untuk mendapatkan penawaran ini!',
                    style: TextStyle(
                      fontFamily: 'DIN_Next_Rounded',
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TradeDetailScreen(trade: trade),
                      ),
                    );
                  },
                );
              },
            ),
      )
    );
  }
}
