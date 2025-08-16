import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ArduinoPainter extends CustomPainter {
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

  final pinColor = Colors.grey[800]!;
  final pinBackgroundColor = Colors.black87;

  late final pinSize = 10 * scaleX;

  ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;
    this.canvas = canvas;

    // Scale factors to adapt to any size
    scaleX = size.width / 370;
    scaleY = size.height / 290;

    vertialStart = 0 * scaleY;
    horzontalStart = 0 * scaleX;

    verticalEnd = size.height * scaleY;
    horizontalEnd = size.width * scaleX;

    if (image == null) {
      loadSvg();
    }

    // Main body
    _paint.color = Colors.teal;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(8 * scaleX),
      ),
      _paint,
    );

    drawPinsSet(10, 130 * scaleX, 10 * scaleY);

    drawPinsSet(8, 265 * scaleX, 10 * scaleY);

    drawPinsSet(8, 180 * scaleX, 270 * scaleY);

    drawPinsSet(6, 290 * scaleX, 270 * scaleY);

    drawLabels();

    drawLogo();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  Future<void> loadSvg() async {
    try {
      final pictureInfo = await vg.loadPicture(
        SvgAssetLoader("assets/arduino_logo.svg"),
        null,
      );

      image = await pictureInfo.picture.toImage(720, 490);
    } catch (e) {
      debugPrint('Error loading SVG: $e');
    }
  }

  void drawLogo() {
    if (image != null) {
      _paint.colorFilter = const ColorFilter.mode(
        Colors.white,
        BlendMode.srcIn,
      );

      canvas.save();
      canvas.translate(
        150 * scaleX,
        115 * scaleY,
      );
      canvas.scale(0.125 * scaleX);
      canvas.drawImage(image!, Offset.zero, _paint);

      canvas.restore();
      _paint.colorFilter = null;
    }
  }

  void drawPinsSet(int pinsCount, double x, double y) {
    canvas.save();
    canvas.translate(x, y);

    _paint.color = pinColor;

    final radius = Radius.circular(2 * scaleX);

    for (int i = 0; i < pinsCount; i++) {
      final x = i * (pinSize + 2 * scaleX);

      _paint.color = pinBackgroundColor;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-2 + x, -2, pinSize + 4, pinSize + 4),
          radius,
        ),
        _paint,
      );

      _paint.color = pinColor;

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, pinSize, pinSize), radius),
        _paint,
      );
    }

    canvas.restore();
  }

  void drawLabels() {
    double spacing = pinSize + 2 * scaleX;

    TextStyle labelStyle = GoogleFonts.jetBrainsMono(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    List leftColumnsLabels = [
      '',
      '',
      'AREF',
      'GND',
      '13',
      '12',
      '~11',
      '~10',
      '~9',
      '8',
    ];

    double horziontalOffset = horzontalStart + (135 * scaleX);

    for (int i = 0; i < leftColumnsLabels.length; i++) {
      double x = horziontalOffset + (i * spacing);

      canvas.save();
      canvas.translate(x, pinSize + 20);
      canvas.rotate(-math.pi / 2);

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: leftColumnsLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.end,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width, -textPainter.height / 2),
      );

      canvas.restore();
    }

    leftColumnsLabels = ['7', '~6', '~5', '4', '~3', '2', 'TK->1', 'RX<-0'];

    horziontalOffset = horzontalStart + (270 * scaleX);

    for (int i = 0; i < leftColumnsLabels.length; i++) {
      double x = horziontalOffset + (i * spacing);

      canvas.save();
      canvas.translate(x, pinSize + 20);
      canvas.rotate(-math.pi / 2);

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: leftColumnsLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.end,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width, -textPainter.height / 2),
      );

      canvas.restore();
    }

    leftColumnsLabels = [
      '',
      'IOREF',
      'RESET',
      '3.3V',
      '5V',
      'GND',
      'GND',
      'Vin',
    ];

    horziontalOffset = horzontalStart + (185 * scaleX);

    for (int i = 0; i < leftColumnsLabels.length; i++) {
      double x = horziontalOffset + (i * spacing);

      canvas.save();
      canvas.translate(x, pinSize + 250 * scaleY);
      canvas.rotate(-math.pi / 2);

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: leftColumnsLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.start,
      );

      textPainter.layout();

      textPainter.paint(canvas, Offset(0, -textPainter.height / 2));

      canvas.restore();
    }

    leftColumnsLabels = ['A0', 'A1', 'A2', 'A3', 'A4', 'A5'];

    horziontalOffset = horzontalStart + (295 * scaleX);

    for (int i = 0; i < leftColumnsLabels.length; i++) {
      double x = horziontalOffset + (i * spacing);

      canvas.save();
      canvas.translate(x, pinSize + 250 * scaleY);
      canvas.rotate(-math.pi / 2);

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: leftColumnsLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.start,
      );

      textPainter.layout();

      textPainter.paint(canvas, Offset(0, -textPainter.height / 2));

      canvas.restore();
    }

    _paint
      ..strokeWidth = 1.5
      ..color = Colors.white
      ..strokeCap = StrokeCap.round;

    double verticalStartOffset = vertialStart + (70 * scaleY);

    // top digital line
    canvas.drawLine(
      Offset(horzontalStart + (180 * scaleX), verticalStartOffset),
      Offset(horzontalStart + (360 * scaleX), verticalStartOffset),
      _paint,
    );

    verticalStartOffset = vertialStart + (220 * scaleY);

    // bottom power line
    canvas.drawLine(
      Offset(horzontalStart + (220 * scaleX), verticalStartOffset),
      Offset(horzontalStart + (275 * scaleX), verticalStartOffset),
      _paint,
    );

    // bottom analog line
    canvas.drawLine(
      Offset(horzontalStart + (290 * scaleX), verticalStartOffset),
      Offset(horzontalStart + (360 * scaleX), verticalStartOffset),
      _paint,
    );

    TextPainter textPainter = TextPainter(
      text: TextSpan(text: 'DIGITAL (PWM~)', style: labelStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(horzontalStart + (235 * scaleX), vertialStart + (55 * scaleY)),
    );

    textPainter = TextPainter(
      text: TextSpan(text: 'POWER', style: labelStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(horzontalStart + (230 * scaleX), vertialStart + (222.5 * scaleY)),
    );

    textPainter = TextPainter(
      text: TextSpan(text: 'ANALOG IN', style: labelStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        horzontalStart + (297.5 * scaleX),
        vertialStart + (222.5 * scaleY),
      ),
    );
  }
}
