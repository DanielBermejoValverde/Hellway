import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShipPainter extends CustomPainter {
  final double position;

  ShipPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.blue; // Color de la nave

    // Dibuja la nave en la posición especificada
    canvas.drawRect(Rect.fromLTWH(position, 0, 50, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}