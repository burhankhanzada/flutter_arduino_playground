import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/ui/components/port_provider.dart';

class _PinGroup {
  final int count;
  final double startX;
  final double startY;
  final List<String> labels;
  final List<String> ids;
  final bool isTop;

  _PinGroup({
    required this.startX,
    required this.startY,
    required this.labels,
    required this.ids,
    required this.isTop,
  }) : count = labels.length;
}

final List<_PinGroup> _pinGroups = [
  _PinGroup(
    startX: 130,
    startY: 10,
    labels: ['', '', 'AREF', 'GND', '13', '12', '~11', '~10', '~9', '8'],
    ids: ['SCL', 'SDA', 'AREF', 'GND_1', '13', '12', '11', '10', '9', '8'],
    isTop: true,
  ),
  _PinGroup(
    startX: 265,
    startY: 10,
    labels: ['7', '~6', '~5', '4', '~3', '2', 'TK->1', 'RX<-0'],
    ids: ['7', '6', '5', '4', '3', '2', '1', '0'],
    isTop: true,
  ),
  _PinGroup(
    startX: 180,
    startY: 270,
    labels: ['', 'IOREF', 'RESET', '3.3V', '5V', 'GND', 'GND', 'Vin'],
    ids: ['NC', 'IOREF', 'RESET', '3.3V', '5V', 'GND_2', 'GND_3', 'VIN'],
    isTop: false,
  ),
  _PinGroup(
    startX: 290,
    startY: 270,
    labels: ['A0', 'A1', 'A2', 'A3', 'A4', 'A5'],
    ids: ['A0', 'A1', 'A2', 'A3', 'A4', 'A5'],
    isTop: false,
  ),
];

class _RepaintNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class ArduinoPainter extends CustomPainter with PortProvider {
  static const componentSize = Size(370, 290);

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

  static ui.Image? _cachedImage;
  static bool _isLoading = false;
  static final _RepaintNotifier _repaintNotifier = _RepaintNotifier();

  ArduinoPainter() : super(repaint: _repaintNotifier);

  @override
  List<ComponentPort> getPorts() {
    final ports = <ComponentPort>[];
    for (final group in _pinGroups) {
      for (int i = 0; i < group.count; i++) {
        ports.add(
          ComponentPort(
            id: group.ids[i],
            name: group.labels[i].isEmpty ? group.ids[i] : group.labels[i],
            localOffset: Offset(group.startX + i * 12 + 5, group.startY + 5),
          ),
        );
      }
    }
    return ports;
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;
    this.canvas = canvas;

    // Scale factors to adapt to any size
    scaleX = size.width / componentSize.width;
    scaleY = size.height / componentSize.height;

    vertialStart = 0 * scaleY;
    horzontalStart = 0 * scaleX;

    verticalEnd = size.height * scaleY;
    horizontalEnd = size.width * scaleX;

    if (_cachedImage == null) {
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

    for (final group in _pinGroups) {
      drawPinsSet(group.count, group.startX * scaleX, group.startY * scaleY);
    }

    drawLabels();

    drawLogo();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  static Future<void> loadSvg() async {
    if (_cachedImage != null || _isLoading) return;
    _isLoading = true;

    try {
      final pictureInfo = await vg.loadPicture(
        const SvgAssetLoader("assets/arduino_logo.svg"),
        null,
      );

      _cachedImage = await pictureInfo.picture.toImage(720, 490);
      _repaintNotifier.notify();
    } catch (e) {
      debugPrint('Error loading SVG: $e');
    } finally {
      _isLoading = false;
    }
  }

  void drawLogo() {
    if (_cachedImage != null) {
      _paint.colorFilter = const ColorFilter.mode(
        Colors.white,
        BlendMode.srcIn,
      );

      canvas.save();
      canvas.translate(150 * scaleX, 115 * scaleY);
      canvas.scale(0.125 * scaleX);
      canvas.drawImage(_cachedImage!, Offset.zero, _paint);

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

    for (final group in _pinGroups) {
      double horziontalOffset = horzontalStart + ((group.startX + 5) * scaleX);

      for (int i = 0; i < group.count; i++) {
        if (group.labels[i].isEmpty) continue;

        double x = horziontalOffset + (i * spacing);

        canvas.save();
        if (group.isTop) {
          canvas.translate(x, pinSize + 20);
        } else {
          canvas.translate(x, pinSize + 250 * scaleY);
        }
        canvas.rotate(-math.pi / 2);

        TextPainter textPainter = TextPainter(
          text: TextSpan(text: group.labels[i], style: labelStyle),
          textDirection: TextDirection.ltr,
          textAlign: group.isTop ? TextAlign.end : TextAlign.start,
        );

        textPainter.layout();

        if (group.isTop) {
          textPainter.paint(
            canvas,
            Offset(-textPainter.width, -textPainter.height / 2),
          );
        } else {
          textPainter.paint(canvas, Offset(0, -textPainter.height / 2));
        }

        canvas.restore();
      }
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
