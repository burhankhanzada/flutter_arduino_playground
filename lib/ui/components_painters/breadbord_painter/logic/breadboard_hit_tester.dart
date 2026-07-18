import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/breadboard_interaction.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/breadboard_config.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/power_rail_config.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/terminal_strip_config.dart';

class BreadboardHitTester {
  static BreadboardHoverState? hitTest(Offset localPosition, BreadboardConfig config) {
    // 1. Check Power Rails
    final rail = PowerRailConfig(config);

    // Left Power Rail
    final leftRailResult = _testPowerRail(localPosition, config, rail, isRight: false);
    if (leftRailResult != null) return leftRailResult;

    // Right Power Rail
    final rightRailResult = _testPowerRail(localPosition, config, rail, isRight: true);
    if (rightRailResult != null) return rightRailResult;

    // 2. Check Signal Sections
    // Left Section
    final leftSectionResult = _testSignalSection(
      localPosition, 
      config, 
      TerminalStripConfig.left(config), 
      sectionOffsetX: config.leftSectionStartOffset,
      isRight: false,
    );
    if (leftSectionResult != null) return leftSectionResult;

    // Right Section
    final rightSectionResult = _testSignalSection(
      localPosition, 
      config, 
      TerminalStripConfig.right(config), 
      sectionOffsetX: config.rightSectionStartOffset,
      isRight: true,
    );
    if (rightSectionResult != null) return rightSectionResult;

    return null;
  }

  static BreadboardHoverState? _testPowerRail(
    Offset localPosition, 
    BreadboardConfig config, 
    PowerRailConfig rail, 
    {required bool isRight}
  ) {
    final double baseOffsetX = isRight ? config.rightPowerRailOffset : config.boardPadding;
    final double hitRadius = config.gridCellSize * 0.8;
    
    final localX = localPosition.dx - baseOffsetX;
    final localY = localPosition.dy;

    if (localY < config.firstRowY - hitRadius || localY > config.lastRowY + hitRadius) return null;

    if ((localX - rail.dot1Offset).abs() < hitRadius) {
      return BreadboardHoverState(channel: BreadboardChannel.plus, isRightSide: isRight);
    }
    if ((localX - rail.dot2Offset).abs() < hitRadius) {
      return BreadboardHoverState(channel: BreadboardChannel.minus, isRightSide: isRight);
    }
    return null;
  }

  static BreadboardHoverState? _testSignalSection(
    Offset localPosition, 
    BreadboardConfig config, 
    TerminalStripConfig section, 
    {required double sectionOffsetX, required bool isRight}
  ) {
    final double hitRadius = config.gridCellSize * 0.8;
    final localX = localPosition.dx - sectionOffsetX;
    final localY = localPosition.dy - config.firstRowY;

    if (localX >= -hitRadius && localX <= (section.columnLabels.length - 1) * config.gridCellStep + hitRadius) {
      final rowDouble = localY / config.gridCellStep;
      final row = rowDouble.round();
      if ((localY - row * config.gridCellStep).abs() < hitRadius &&
          row >= 0 &&
          row < config.rowsCount) {
        return BreadboardHoverState(
          channel: BreadboardChannel.signal, 
          rowIndex: row, 
          isRightSide: isRight
        );
      }
    }
    return null;
  }
}
