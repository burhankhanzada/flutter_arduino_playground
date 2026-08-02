import 'package:flutter/material.dart';

class BoxSelectionPainter extends CustomPainter {
  final Rect? rect;

  BoxSelectionPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    if (rect == null) return;

    final fillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(rect!, fillPaint);
    canvas.drawRect(rect!, borderPaint);
  }

  @override
  bool shouldRepaint(covariant BoxSelectionPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}
