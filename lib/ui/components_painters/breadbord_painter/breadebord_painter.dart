import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/breadboard_config.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/power_rail_config.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/terminal_strip_config.dart';
import 'package:google_fonts/google_fonts.dart';

class BreadboardPainter extends CustomPainter {
  final BreadboardConfig config;

  BreadboardPainter({required this.config});

  final _paint = Paint();

  final backgroundColor = Colors.grey[300]!;
  final holeBevelLight = Colors.grey[200]!;
  final holeBevelDark = Colors.grey[400]!;
  final holeCenterDark = Colors.grey[800]!;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawPowerRails(canvas);
    _drawSignalSections(canvas);
  }

  @override
  bool shouldRepaint(covariant BreadboardPainter oldDelegate) =>
      config != oldDelegate.config;

  void _drawBackground(Canvas canvas, Size size) {
    _paint.color = backgroundColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(config.gridCellSize),
      ),
      _paint,
    );
  }

  void _drawPowerRails(Canvas canvas) {
    final railConfig = PowerRailConfig(config);

    canvas.save();
    canvas.translate(config.boardPadding, 0);
    _drawPowerRail(canvas, railConfig);
    canvas.restore();

    canvas.save();
    canvas.translate(config.rightPowerRailOffset, 0);
    _drawPowerRail(canvas, railConfig);
    canvas.restore();
  }

  void _drawSignalSections(Canvas canvas) {
    canvas.save();
    canvas.translate(config.leftSectionStartOffset, 0);
    _drawSignalSection(canvas, TerminalStripConfig.left(config));
    canvas.restore();

    canvas.save();
    canvas.translate(config.rightSectionStartOffset, 0);
    _drawSignalSection(canvas, TerminalStripConfig.right(config));
    canvas.restore();
  }

  void _applyStrokePaint({
    required Color color,
    required double width,
    StrokeCap cap = StrokeCap.butt,
  }) {
    _paint
      ..color = color
      ..strokeWidth = width
      ..strokeCap = cap;
  }

  void _drawPowerRail(Canvas canvas, PowerRailConfig rail) {
    final double railTopY = config.firstRowY - config.gridCellSize;
    final double railBottomY = config.lastRowY + config.gridCellSize;

    final double signTopY = railTopY - config.gridCellSize;
    final double signBottomY = railBottomY + config.gridCellSize;

    for (final signY in [signTopY, signBottomY]) {
      _drawPolaritySymbol(
        canvas,
        rail.plusOffset,
        signY,
        rail.plusColor,
        isPlus: true,
      );
      _drawPolaritySymbol(
        canvas,
        rail.minusOffset,
        signY,
        rail.minusColor,
        isPlus: false,
      );
    }

    _applyStrokePaint(color: rail.plusColor, width: 1.5, cap: StrokeCap.round);
    canvas.drawLine(
      Offset(rail.plusOffset, railTopY),
      Offset(rail.plusOffset, railBottomY),
      _paint,
    );

    _applyStrokePaint(color: rail.minusColor, width: 1.5, cap: StrokeCap.round);
    canvas.drawLine(
      Offset(rail.minusOffset, railTopY),
      Offset(rail.minusOffset, railBottomY),
      _paint,
    );

    canvas.save();
    canvas.translate(0, config.firstRowY);

    for (int row = 0; row < config.rowsCount; row++) {
      final double y = row * config.gridCellStep;
      _drawHole(canvas, Offset(rail.dot1Offset, y));
      _drawHole(canvas, Offset(rail.dot2Offset, y));
    }
    canvas.restore();
  }

  /// Draws signal dot holes and all labels for one section (a–e or f–j).
  void _drawSignalSection(Canvas canvas, TerminalStripConfig section) {
    _drawSignalDots(canvas, section);
    _drawSectionLabels(canvas, section);
  }

  void _drawSignalDots(Canvas canvas, TerminalStripConfig section) {
    canvas.save();
    canvas.translate(0, config.firstRowY);

    for (int col = 0; col < section.columnLabels.length; col++) {
      final double x = col * config.gridCellStep;
      for (int row = 0; row < config.rowsCount; row++) {
        final double y = row * config.gridCellStep;
        _drawHole(canvas, Offset(x, y));
      }
    }
    canvas.restore();
  }

  void _drawSectionLabels(Canvas canvas, TerminalStripConfig section) {
    canvas.save();
    canvas.translate(0, 0);

    for (int i = 0; i < section.columnLabels.length; i++) {
      final double x = i * config.gridCellStep;
      _drawLabel(canvas, section.columnLabels[i], x, config.boardPadding);
      _drawLabel(canvas, section.columnLabels[i], x, config.bottomLabelY);
    }
    canvas.restore();

    canvas.save();
    canvas.translate(section.rowLabelRelX, config.firstRowY);

    for (int row = 0; row < config.rowsCount; row++) {
      _drawLabel(canvas, '${row + 1}', 0, row * config.gridCellStep);
    }
    canvas.restore();
  }

  void _drawPolaritySymbol(
    Canvas canvas,
    double x,
    double y,
    Color color, {
    required bool isPlus,
  }) {
    _applyStrokePaint(color: color, width: 1.5, cap: StrokeCap.round);
    canvas.save();
    canvas.translate(x, y);

    final double symbolSize = config.gridCellSize * 0.4;
    canvas.drawLine(Offset(-symbolSize, 0), Offset(symbolSize, 0), _paint);
    if (isPlus) {
      canvas.drawLine(Offset(0, -symbolSize), Offset(0, symbolSize), _paint);
    }

    canvas.restore();
  }

  void _drawHole(Canvas canvas, Offset offset) {
    const dotRadiusInner = 3.0;
    const dotRadiusOuter = 5.0;

    const halfCircleSweep = pi;
    const topHalfStart = pi;
    const bottomHalfStart = 0.0;

    _paint.color = holeBevelLight;
    canvas.drawArc(
      Rect.fromCircle(center: offset, radius: dotRadiusOuter),
      topHalfStart,
      halfCircleSweep,
      true,
      _paint,
    );

    _paint.color = holeBevelDark;
    canvas.drawArc(
      Rect.fromCircle(center: offset, radius: dotRadiusOuter),
      bottomHalfStart,
      halfCircleSweep,
      true,
      _paint,
    );

    _paint.color = holeCenterDark;
    canvas.drawCircle(offset, dotRadiusInner, _paint);
  }

  void _drawLabel(Canvas canvas, String text, double x, double y) {
    canvas.save();
    canvas.translate(x, y);

    final style = GoogleFonts.jetBrainsMono(
      color: Colors.black,
      fontSize: config.gridCellSize,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    textPainter.dispose();

    canvas.restore();
  }
}
