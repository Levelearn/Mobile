import 'package:app/model/badge.dart';
import 'package:app/model/trade.dart';
import 'package:app/view/trade_screen.dart';
import 'package:app/view/whatadeal_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../utils/colors.dart';

class TradeDetailScreen extends StatefulWidget {
  final TradeModel trade;

  const TradeDetailScreen({super.key, required this.trade});

  @override
  State<TradeDetailScreen> createState() => _TradeDetailScreenState();
}

class _TradeDetailScreenState extends State<TradeDetailScreen> {

  List<BadgeModel> userBadges = [
    // BadgeModel(
    //   image: 'lib/assets/pictures/icon.png',
    //   name: 'Beginner HCI',
    //   type: 'BEGINNER',
    //   course: 'Interaksi Manusia Komputer',
    //   chapter: 'Chapter 1',
    // ),
    // BadgeModel(
    //   image: 'lib/assets/pictures/icon.png',
    //   name: 'Intermediate HCI',
    //   type: 'INTERMEDIATE',
    //   course: 'Interaksi Manusia Komputer',
    //   chapter: 'Chapter 2',
    // ),
    // BadgeModel(
    //   image: 'lib/assets/pictures/icon.png',
    //   name: 'Advanced HCI',
    //   type: 'ADVANCE',
    //   course: 'Interaksi Manusia Komputer',
    //   chapter: 'Chapter 2',
    // ),
  ];

  List<BadgeModel> selectedBadges = [];
  String errorMessage = '';

  void _purchase() {
    if (_isPurchaseValid()) {
      print('Pembelian berhasil!');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCompletionDialog(context, "Transaksi badge anda telah berhasil!", false);
      });
    } else {
      setState(() {
        errorMessage = 'Badge yang dipilih tidak sesuai.';
      });
    }
  }

  bool _isPurchaseValid() {
    if (selectedBadges.isEmpty) {
      return false;
    }
    for (var badge in selectedBadges) {
      if (badge.type != widget.trade.requiredBadgeType) {
        return false;
      }
    }
    return true;
  }

  void showCompletionDialog(BuildContext context, String message, bool isAssignment) {
    Future.delayed(Duration(milliseconds: 100), () {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WhatADealScreen(
              message: message,
              onContinue: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trade Detail"),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(LineAwesomeIcons.angle_left_solid, color: Colors.white)),
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
            ),
            fit: BoxFit.cover, // Menyesuaikan gambar agar mengisi layar
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset(widget.trade.image)),
              SizedBox(height: 16),
              Text(
                widget.trade.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DIN_Next_Rounded',
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.trade.description,
                style: TextStyle(
                  fontFamily: 'DIN_Next_Rounded',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Persyaratan',
                style: TextStyle(
                    fontFamily: 'DIN_Next_Rounded',
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                ),
              ),
              Text(
                'Tukarkan satu buah badge dengan tipe ${widget.trade.requiredBadgeType} untuk mendapatkan penawaran ini!',
                style: TextStyle(fontFamily: 'DIN_Next_Rounded'),
              ),
              SizedBox(height: 16),
              Text('Pilih Badge untuk ditukarkan:', style: TextStyle(fontFamily: 'DIN_Next_Rounded'),),
              userBadges.isEmpty
                  ? Text('Anda belum memiliki badge.', style: TextStyle(fontFamily: 'DIN_Next_Rounded'))
                  : Wrap(
                spacing: 8.0,
                children: userBadges.map((badge) {
                  return ChoiceChip(
                    selectedColor: AppColors.accentColor,
                    backgroundColor: Colors.white,
                    label: Text(badge.name, style: TextStyle(fontFamily: 'DIN_Next_Rounded'),),
                    selected: selectedBadges.contains(badge),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedBadges.add(badge);
                        } else {
                          selectedBadges.remove(badge);
                        }
                        errorMessage = '';
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPurchaseValid() ? _purchase : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: Text(
                    'Purchase',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'DIN_Next_Rounded'
                    ),
                  ),
                ),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      )
    );;
  }
}
