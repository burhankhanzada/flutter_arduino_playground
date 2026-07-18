import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/breadboard_interaction.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/breadboard_config.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/power_rail_config.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/terminal_strip_config.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/logic/breadboard_hit_tester.dart';
import 'package:flutter_arduino_playground/ui/components_painters/port_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class BreadboardPainter extends CustomPainter implements PortProvider {
  final BreadboardConfig config;

  final BreadboardHoverState? hoverState;

  BreadboardPainter({required this.config, this.hoverState});

  @override
  List<ComponentPort> getPorts() => []; // Dynamic discovery used instead

  @override
  ComponentPort? getPortAt(Offset localOffset) {
    final hover = BreadboardHitTester.hitTest(localOffset, config);
    if (hover == null) return null;

    final String side = hover.isRightSide ? 'right' : 'left';
    String id;
    String name;
    Offset portOffset;

    final rail = PowerRailConfig(config);

    if (hover.channel == BreadboardChannel.plus || hover.channel == BreadboardChannel.minus) {
      final isPlus = hover.channel == BreadboardChannel.plus;
      // For rails, we need to know WHICH row specifically.
      // Although BreadboardHoverState doesn't store the row for rails yet, 
      // we can calculate it from localOffset.
      final row = ((localOffset.dy - config.firstRowY) / config.gridCellStep).round();
      if (row < 0 || row >= config.rowsCount) return null;

      final channelName = isPlus ? 'plus' : 'minus';
      id = 'rail_${side}_${channelName}_$row';
      name = 'Power Rail $side ${channelName.toUpperCase()} Row ${row + 1}';
      
      final x = isPlus ? rail.dot1Offset : rail.dot2Offset;
      final y = config.firstRowY + row * config.gridCellStep;
      portOffset = Offset(x, y);
    } else {
      final row = hover.rowIndex!;
      // Find exact column based on localX
      // Left section starts at config.leftSectionStartOffset
      // Right section starts at config.rightSectionStartOffset
      final double sectionStartX = hover.isRightSide ? config.rightSectionStartOffset : config.leftSectionStartOffset;
      final localX = localOffset.dx - sectionStartX;
      final col = (localX / config.gridCellStep).round();
      if (col < 0 || col >= 5) return null;

      final section = hover.isRightSide ? TerminalStripConfig.right(config) : TerminalStripConfig.left(config);
      final colName = section.columnLabels[col];
      
      id = 'sig_${side}_${colName}_$row';
      name = 'Signal $side ${colName.toUpperCase()} Row ${row + 1}';
      portOffset = Offset(sectionStartX + col * config.gridCellStep, config.firstRowY + row * config.gridCellStep);
    }

    return ComponentPort(id: id, name: name, localOffset: portOffset);
  }

  @override
  Offset? getPortOffsetById(String id) {
    if (id.startsWith('rail_')) {
      final parts = id.split('_');
      if (parts.length < 4) return null;
      final isRightSide = parts[1] == 'right';
      final channel = parts[2] == 'plus' ? BreadboardChannel.plus : BreadboardChannel.minus;
      final row = int.tryParse(parts[3]) ?? 0;

      final rail = PowerRailConfig(config);
      final isPlus = channel == BreadboardChannel.plus;
      final x = isPlus ? rail.dot1Offset : rail.dot2Offset;
      final y = config.firstRowY + row * config.gridCellStep;

      final railStartX = isRightSide ? config.rightPowerRailOffset : config.boardPadding;
      return Offset(railStartX + x, y);
    } else if (id.startsWith('sig_')) {
      final parts = id.split('_');
      if (parts.length < 4) return null;
      final isRightSide = parts[1] == 'right';
      final colName = parts[2];
      final row = int.tryParse(parts[3]) ?? 0;

      final section =
          isRightSide ? TerminalStripConfig.right(config) : TerminalStripConfig.left(config);
      final colIndex = section.columnLabels.indexOf(colName);
      if (colIndex == -1) return null;

      final double sectionStartX =
          isRightSide ? config.rightSectionStartOffset : config.leftSectionStartOffset;
      return Offset(sectionStartX + colIndex * config.gridCellStep,
          config.firstRowY + row * config.gridCellStep);
    }
    return null;
  }

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
      config != oldDelegate.config ||
      hoverState != oldDelegate.hoverState;

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
    _drawPowerRail(canvas, railConfig, isRight: false);
    canvas.restore();

    canvas.save();
    canvas.translate(config.rightPowerRailOffset, 0);
    _drawPowerRail(canvas, railConfig, isRight: true);
    canvas.restore();
  }

  void _drawSignalSections(Canvas canvas) {
    canvas.save();
    canvas.translate(config.leftSectionStartOffset, 0);
    _drawSignalSection(canvas, TerminalStripConfig.left(config), sectionOffsetX: config.leftSectionStartOffset);
    canvas.restore();

    canvas.save();
    canvas.translate(config.rightSectionStartOffset, 0);
    _drawSignalSection(canvas, TerminalStripConfig.right(config), sectionOffsetX: config.rightSectionStartOffset);
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

  void _drawPowerRail(Canvas canvas, PowerRailConfig rail, {bool isRight = false}) {
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

    bool isColumn1Highlighted = false;
    bool isColumn2Highlighted = false;

    if (hoverState != null && hoverState!.isRightSide == isRight) {
      if (hoverState!.channel == BreadboardChannel.plus) {
        isColumn1Highlighted = true;
      } else if (hoverState!.channel == BreadboardChannel.minus) {
        isColumn2Highlighted = true;
      }
    }

    canvas.save();
    canvas.translate(0, config.firstRowY);

    if (isColumn1Highlighted || isColumn2Highlighted) {
      if (isColumn1Highlighted) {
        _applyStrokePaint(color: rail.plusColor, width: 2.0, cap: StrokeCap.round);
        canvas.drawLine(
          Offset(rail.dot1Offset, 0),
          Offset(rail.dot1Offset, (config.rowsCount - 1) * config.gridCellStep),
          _paint,
        );
      }
      if (isColumn2Highlighted) {
        _applyStrokePaint(color: rail.minusColor, width: 2.0, cap: StrokeCap.round);
        canvas.drawLine(
          Offset(rail.dot2Offset, 0),
          Offset(rail.dot2Offset, (config.rowsCount - 1) * config.gridCellStep),
          _paint,
        );
      }
    }

    for (int row = 0; row < config.rowsCount; row++) {
      final double y = row * config.gridCellStep;
      _drawHole(
        canvas,
        Offset(rail.dot1Offset, y),
        isHighlighted: isColumn1Highlighted,
        highlightColor: rail.plusColor,
      );
      _drawHole(
        canvas,
        Offset(rail.dot2Offset, y),
        isHighlighted: isColumn2Highlighted,
        highlightColor: rail.minusColor,
      );
    }
    canvas.restore();
  }

  /// Draws signal dot holes and all labels for one section (a–e or f–j).
  void _drawSignalSection(Canvas canvas, TerminalStripConfig section, {required double sectionOffsetX}) {
    _drawSignalDots(canvas, section, sectionOffsetX: sectionOffsetX);
    _drawSectionLabels(canvas, section);
  }

  void _drawSignalDots(Canvas canvas, TerminalStripConfig section, {required double sectionOffsetX}) {
    int? highlightedRow;
    final bool isRight = sectionOffsetX == config.rightSectionStartOffset;

    if (hoverState != null &&
        hoverState!.channel == BreadboardChannel.signal &&
        hoverState!.isRightSide == isRight) {
      highlightedRow = hoverState!.rowIndex;
    }

    canvas.save();
    canvas.translate(0, config.firstRowY);

    if (highlightedRow != null) {
      _applyStrokePaint(color: Colors.green, width: 2.0, cap: StrokeCap.round);
      canvas.drawLine(
        Offset(0, highlightedRow * config.gridCellStep),
        Offset((section.columnLabels.length - 1) * config.gridCellStep, highlightedRow * config.gridCellStep),
        _paint,
      );
    }

    for (int col = 0; col < section.columnLabels.length; col++) {
      final double x = col * config.gridCellStep;
      for (int row = 0; row < config.rowsCount; row++) {
        final double y = row * config.gridCellStep;
        _drawHole(canvas, Offset(x, y), isHighlighted: row == highlightedRow);
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

  void _drawHole(
    Canvas canvas,
    Offset offset, {
    bool isHighlighted = false,
    Color highlightColor = Colors.green,
  }) {
    const dotRadiusInner = 3.0;
    const dotRadiusOuter = 5.0;

    const halfCircleSweep = pi;
    const topHalfStart = pi;
    const bottomHalfStart = 0.0;

    if (isHighlighted) {
      _paint.color = highlightColor;
      canvas.drawCircle(offset, dotRadiusOuter + 2, _paint);
    }

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
