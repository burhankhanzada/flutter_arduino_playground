import 'package:flutter/material.dart';

class LEDPainter extends CustomPainter {
  final _paint = Paint();

  late Size size;
  late Canvas canvas;

  late double scaleX;
  late double scaleY;

  late double vertialStart;
  late double horzontalStart;

  late double verticalEnd;
  late double horizontalEnd;

  late final radius = Radius.circular(50 * scaleX);

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;
    this.canvas = canvas;

    // Scale factors to adapt to any size
    scaleX = size.width / 30;
    scaleY = size.height / 50;

    vertialStart = 0 * scaleY;
    horzontalStart = 0 * scaleX;

    verticalEnd = size.height * scaleY;
    horizontalEnd = size.width * scaleX;

    drawLegs();

    drawBody();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  void drawBody() {
    final width = 25 * scaleX;
    final height = 35 * scaleY;

    final smallRadius = Radius.circular(10 * scaleX);

    _paint.color = Colors.red;
    final mainBody = RRect.fromRectAndCorners(
      Rect.fromLTWH((size.width / 2) - width / 2, 0, width, height),
      topLeft: radius,
      topRight: radius,
      bottomLeft: smallRadius,
      bottomRight: smallRadius,
    );
    canvas.drawRRect(mainBody, _paint);
  }

  void drawLegs() {
    _paint.color = Colors.grey;

    final width = 4 * scaleX;
    final height = 15 * scaleY;

    final veritcalEndOffset = verticalEnd - (height * scaleY);

    final horzontalStartOffset = 5 * scaleX;
    final horzontalEndOffset = horizontalEnd - (5 + width * scaleX);

    final leftLeg = RRect.fromRectAndCorners(
      Rect.fromLTWH(horzontalStartOffset, veritcalEndOffset, width, height),
      bottomLeft: radius,
      bottomRight: radius,
    );
    canvas.drawRRect(leftLeg, _paint);

    final rightLeg = RRect.fromRectAndCorners(
      Rect.fromLTWH(horzontalEndOffset, veritcalEndOffset, width, height),
      bottomLeft: radius,
      bottomRight: radius,
    );
    canvas.drawRRect(rightLeg, _paint);
  }
}
