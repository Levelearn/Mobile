import 'package:flutter/material.dart';

class CustomNavigationPainter extends CustomPainter {
  final int selectedIndex;
  final Color primaryColor;

  CustomNavigationPainter(this.selectedIndex, this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = size.width / 5;
    final selectedItemCenter = itemWidth * (selectedIndex + 0.5);

    final backgroundPaint = Paint()
      ..color = primaryColor.withOpacity(0.2); // Sesuaikan opasitas
    canvas.drawCircle(Offset(selectedItemCenter, size.height / 2), 30,
        backgroundPaint); // Sesuaikan radius

    // Gambar garis di atas ikon
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(selectedItemCenter - 20, 0), // Sesuaikan panjang garis
      Offset(selectedItemCenter + 20, 0),
      linePaint,
    );

    // Gambar garis di tepi navbar
    canvas.drawLine(
      Offset(itemWidth * selectedIndex, 0),
      Offset(itemWidth * selectedIndex, size.height),
      linePaint,
    );
    canvas.drawLine(
      Offset(itemWidth * (selectedIndex + 1), 0),
      Offset(itemWidth * (selectedIndex + 1), size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
