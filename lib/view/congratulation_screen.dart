import 'package:app/model/badge.dart';
import 'package:app/service/badge_service.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_launcher_icons/constants.dart';

class CongratulationsScreen extends StatefulWidget {
  final String message;
  final int idBadge;
  final VoidCallback? onContinue;

  const CongratulationsScreen(
      {super.key,
      required this.message,
      this.onContinue,
      required this.idBadge});

  @override
  _CongratulationsScreenState createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  late ConfettiController _confettiController;
  BadgeModel? badge;
  int idBadge = 0;

  @override
  void initState() {
    idBadge = widget.idBadge;
    if (idBadge != 0) {
      getBadgeById(idBadge);
      super.initState();
      _confettiController =
          ConfettiController(duration: const Duration(seconds: 3));
      _confettiController.play();
    } else {
      super.initState();
      _confettiController =
          ConfettiController(duration: const Duration(seconds: 3));
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> getBadgeById(int id) async {
    badge = await BadgeService.getBadgeById(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  idBadge != 0
                      ? badge?.image != null && badge?.image != ""
                          ? Image.network(
                              badge!.image,
                              height: 100,
                              width: 100,
                            )
                          : Image.asset('lib/assets/pictures/icon.png')
                      : Icon(Icons.celebration,
                          color: Colors.orange, size: 100),
                  const SizedBox(height: 20),
                  Text(
                    "Congratulations!",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'DIN_Next_Rounded'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    idBadge != 0
                        ? "Yeay, you've got badge ${badge?.name}!"
                        : widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontFamily: 'DIN_Next_Rounded'),
                  ),
                  const SizedBox(height: 30),
                  if (widget.onContinue != null)
                    TextButton(
                      onPressed: widget.onContinue,
                      child: Text("Ayo Lanjutkan ke Level Berikutnya",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueAccent,
                              fontFamily: 'DIN_Next_Rounded')),
                    ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [
              Colors.red,
              Colors.blue,
              Colors.yellow,
              Colors.green,
              Colors.purple
            ],
          ),
        ],
      ),
    );
  }
}
