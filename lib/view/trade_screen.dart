import 'package:app/model/trade.dart';
import 'package:app/utils/colors.dart';
import 'package:app/view/trade_detail_screen.dart';
import 'package:flutter/material.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {

  final List<TradeModel> trades = [
    TradeModel(
      image: 'lib/assets/pictures/icon.png',
      title: 'Voucher Belanja Cafetaria Del',
      description: 'Voucher Belanja senilai Rp.10.000,- untuk transaksi di Cafetaria Del. Berlaku sampai 1 semester kedepan.',
      requiredBadgeType: 'ADVANCE',
    ),
    TradeModel(
      image: 'lib/assets/pictures/icon.png',
      title: 'Sticky Notes UTS',
      description: 'Sticky Notes berupa cemilan makanan dan minuman dengan ucapan semangat menjalani UTS',
      requiredBadgeType: 'BEGINNER',
    ),
    TradeModel(
      image: 'lib/assets/pictures/icon.png',
      title: 'Nilai Tambah UTS +5',
      description: 'Penambahan Nilai UTS sebanyak 5. Maksimal nilai yang bisa diperoleh dengan penambahan adalah 80',
      requiredBadgeType: 'INTERMEDIATE',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trade"),
        backgroundColor: AppColors.primaryColor,
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
          child: Text('Penawaran belum tersedia.',
              style: TextStyle(
                  fontFamily: 'DIN_Next_Rounded',
                  color: AppColors.primaryColor
              )),
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
