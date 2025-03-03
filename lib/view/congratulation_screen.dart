import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CongratulationsScreen extends StatefulWidget {
  final String message;
  final VoidCallback? onContinue;

  const CongratulationsScreen({super.key, required this.message, this.onContinue});

  @override
  _CongratulationsScreenState createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
                  Icon(Icons.celebration, color: Colors.orange, size: 100),
                  const SizedBox(height: 20),
                  Text(
                    "Congratulations!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  if (widget.onContinue != null)
                    TextButton(
                      onPressed: widget.onContinue,
                      child: Text("Ayo Lanjutkan ke Level Berikutnya", style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                    ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [Colors.red, Colors.blue, Colors.yellow, Colors.green, Colors.purple],
          ),
        ],
      ),
    );
  }
}
