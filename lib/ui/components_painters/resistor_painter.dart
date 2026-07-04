import 'package:flutter/material.dart';

class ResistorPainter extends CustomPainter {
  final _paint = Paint();

  late Size size;
  late Canvas canvas;

  late double scaleX;
  late double scaleY;

  late double vertialStart;
  late double horzontalStart;

  late double verticalEnd;
  late double horizontalEnd;

  late final radius = Radius.circular(100 * scaleX);

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;
    this.canvas = canvas;

    // Scale factors to adapt to any size
    scaleX = size.width / 50;
    scaleY = size.height / 15;

    vertialStart = 0 * scaleY;
    horzontalStart = 0 * scaleX;

    verticalEnd = size.height * scaleY;
    horizontalEnd = size.width * scaleX;

    drawLegs();

    drawBody();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  void drawLegs() {
    _paint.color = Colors.grey;

    final width = 10 * scaleX;
    final height = 5 * scaleY;

    final leftLeg = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 5 * scaleX, width, height),
      topLeft: Radius.circular(100 * scaleX),
      bottomLeft: Radius.circular(100 * scaleX),
    );
    canvas.drawRRect(leftLeg, _paint);

    final rightLeg = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width - (10 * scaleX), 5 * scaleY, width, height),
      topRight: Radius.circular(100 * scaleX),
      bottomRight: Radius.circular(100 * scaleX),
    );
    canvas.drawRRect(rightLeg, _paint);
  }

  void drawBody() {
    final width = 30 * scaleX;
    final height = 15 * scaleY;

    final horzontalStartOffset = 10 * scaleX;

    _paint.color = Colors.yellow[900]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(horzontalStartOffset, 0, width, height),
        Radius.circular(4),
      ),
      _paint,
    );

    TextPainter textPainter = TextPainter(
      text: TextSpan(text: '220'),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.size.width / 2,
        size.height / 2 - textPainter.size.height / 2,
      ),
    );
  }
}
