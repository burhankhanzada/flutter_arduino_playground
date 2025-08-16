import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BreadboardPainter extends CustomPainter {
  final _paint = Paint();

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

  final dotsColor = Colors.grey[800]!;
  final labelColor = Colors.black;

  int rowsCount = 30;
  List<String> leftColumnsLabels = ['a', 'b', 'c', 'd', 'e'];
  List<String> rightColumnsLabels = ['j', 'i', 'h', 'g', 'f'];

  TextStyle labelStyle = GoogleFonts.jetBrainsMono(color: Colors.black, fontSize: 10);

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;
    this.canvas = canvas;

    // Scale factors to adapt to any size
    scaleX = size.width / 300;
    scaleY = size.height / 500;

    vertialStart = 10 * scaleY;
    horzontalStart = 10 * scaleX;

    verticalEnd = size.height - (10 * scaleY);
    horizontalEnd = size.width - (10 * scaleX);

    // Main body
    _paint.color = Colors.grey[300]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(4),
      ),
      _paint,
    );

    drawLines();

    drawleftSideDots();
    drawRightSideDots();

    drawLeftSideLabels();
    drawRightSideLabels();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  void drawLines() {
    _paint.strokeWidth = 2;
    _paint.strokeCap = StrokeCap.round;

    // left side lines

    _paint.color = Colors.red;
    canvas.drawLine(
      Offset(horzontalStart, vertialStart),
      Offset(horzontalStart, verticalEnd),
      _paint,
    );

    final horzontalStartOffset = horzontalStart + (40 * scaleX);

    _paint.color = Colors.blue;
    canvas.drawLine(
      Offset(horzontalStartOffset, vertialStart),
      Offset(horzontalStartOffset, verticalEnd),
      _paint,
    );

    // right side lines

    _paint.color = Colors.blue;
    canvas.drawLine(
      Offset(horizontalEnd, vertialStart),
      Offset(horizontalEnd, verticalEnd),
      _paint,
    );

    final horzontalEndOffset = horizontalEnd - (40 * scaleX);

    _paint.color = Colors.red;
    canvas.drawLine(
      Offset(horzontalEndOffset, vertialStart),
      Offset(horzontalEndOffset, verticalEnd),
      _paint,
    );
  }

  void drawleftSideDots() {
    _paint.color = dotsColor;

    double horizontalOffset = horzontalStart + (12.5 * scaleX);

    for (int row = 1; row <= rowsCount; row++) {
      for (int col = 0; col < 2; col++) {
        double y = vertialStart + (row * colSpacing);
        double x = horizontalOffset + (col * rowSpacing);

        canvas.drawCircle(Offset(x, y), circleRadius, _paint);
      }
    }

    horizontalOffset = horzontalStart + (65 * scaleX);

    _paint.color = dotsColor;
    for (int col = 0; col < leftColumnsLabels.length; col++) {
      for (int row = 1; row <= rowsCount; row++) {
        double y = vertialStart + (row * colSpacing);
        double x = horizontalOffset + (col * rowSpacing);

        canvas.drawCircle(Offset(x, y), circleRadius, _paint);
      }
    }
  }

  void drawRightSideDots() {
    _paint.color = dotsColor;

    double horzontalOffset = horizontalEnd - (12.5 * scaleX);

    for (int row = rowsCount; row >= 1; row--) {
      for (int col = 0; col < 2; col++) {
        double y = vertialStart + (row * colSpacing);
        double x = horzontalOffset - (col * rowSpacing);

        canvas.drawCircle(Offset(x, y), circleRadius, _paint);
      }
    }

    horzontalOffset = horizontalEnd - (65 * scaleX);

    for (int col = 0; col < rightColumnsLabels.length; col++) {
      for (int row = 1; row <= rowsCount; row++) {
        double y = vertialStart + (row * colSpacing);
        double x = horzontalOffset - (col * rowSpacing);

        canvas.drawCircle(Offset(x, y), circleRadius, _paint);
      }
    }
  }

  void drawLeftSideLabels() {
    _paint.color = labelColor;

    double horziontalOffset = horzontalStart + (50 * scaleX);

    // draw row numbers
    for (int i = 1; i <= rowsCount; i++) {
      double y = vertialStart + (i * colSpacing);

      canvas.save();
      canvas.translate(horziontalOffset, y);

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: i.toString(), style: labelStyle),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }

    horziontalOffset = horzontalStart + (65 * scaleX);

    // draw top labels
    for (int i = 0; i < leftColumnsLabels.length; i++) {
      double x = horziontalOffset + (i * rowSpacing);

      canvas.save();
      canvas.translate(x, vertialStart);

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: leftColumnsLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }

    // draw bottom labels
    for (int i = 0; i < leftColumnsLabels.length; i++) {
      double x = horziontalOffset + (i * rowSpacing);

      canvas.save();
      canvas.translate(x, verticalEnd);

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: leftColumnsLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  void drawRightSideLabels() {
    _paint.color = labelColor;

    double horizontalOffset = horizontalEnd - (50 * scaleX);

    // draw row numbers
    for (int i = 1; i <= rowsCount; i++) {
      double y = vertialStart + (i * colSpacing);

      canvas.save();
      canvas.translate(horizontalOffset, y);

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: i.toString(), style: labelStyle),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }

    horizontalOffset = horizontalEnd - (65 * scaleX);

    // draw top labels
    for (int i = 0; i < rightColumnsLabels.length; i++) {
      double x = horizontalOffset - (i * rowSpacing);

      canvas.save();
      canvas.translate(x, vertialStart);

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: rightColumnsLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }

    // draw bottom labels
    for (int i = 0; i < rightColumnsLabels.length; i++) {
      double x = horizontalOffset - (i * rowSpacing);

      canvas.save();
      canvas.translate(x, verticalEnd);

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: rightColumnsLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }
}
