import 'package:flutter/material.dart';

class ButtonPainter extends CustomPainter {
  final _paint = Paint();

  late final radius = Radius.circular(100 * scaleX);

  late Size size;
  late Canvas canvas;

  late double scaleX;
  late double scaleY;

  late double vertialStart;
  late double horzontalStart;

  late double verticalEnd;
  late double horizontalEnd;

  late double circleRadius = 5 * scaleX;

  late double rowSpacing = 15 * scaleX;
  late double colSpacing = 15.5 * scaleY;

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
    final bodyColor = Colors.grey[400]!;
    final buttonColor = Colors.black87;

    final bodySize = 30 * scaleX;
    final buttonRadius = 7.5 * scaleX;
    final borderRadius = 4 * scaleX;

    final center = size.center(Offset.zero);

    _paint.color = bodyColor;
    final mainBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: bodySize, height: bodySize),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(mainBody, _paint);

    // Center button
    _paint.color = buttonColor;
    canvas.drawCircle(center, buttonRadius, _paint);
  }

  void drawLegs() {
    _paint.color = Colors.grey;

    final width = 4 * scaleX;
    final height = 10 * scaleY;

    final veritcalEndOffset = verticalEnd - (height * scaleY);

    final horzontalStartOffset = 5 * scaleX;
    final horzontalEndOffset = horizontalEnd - (5 + width * scaleX);

    final topLeftLeg = RRect.fromRectAndCorners(
      Rect.fromLTWH(horzontalStartOffset, 0, width, height),
      topLeft: radius,
      topRight: radius,
    );
    canvas.drawRRect(topLeftLeg, _paint);

    final topRightLeg = RRect.fromRectAndCorners(
      Rect.fromLTWH(horzontalEndOffset, 0, width, height),
      topLeft: radius,
      topRight: radius,
    );
    canvas.drawRRect(topRightLeg, _paint);

    final bottomLeftLeg = RRect.fromRectAndCorners(
      Rect.fromLTWH(horzontalStartOffset, veritcalEndOffset, width, height),
      bottomLeft: radius,
      bottomRight: radius,
    );
    canvas.drawRRect(bottomLeftLeg, _paint);

    final bottomRightLeg = RRect.fromRectAndCorners(
      Rect.fromLTWH(horzontalEndOffset, veritcalEndOffset, width, height),
      bottomLeft: radius,
      bottomRight: radius,
    );
    canvas.drawRRect(bottomRightLeg, _paint);
  }
}
