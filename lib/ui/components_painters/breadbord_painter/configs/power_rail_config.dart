import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/breadboard_config.dart';

class PowerRailConfig {
  final double plusOffset;
  final double minusOffset;
  final double dot1Offset;
  final double dot2Offset;

  final Color plusColor = Colors.red;
  final Color minusColor = Colors.black;

  PowerRailConfig(BreadboardConfig boardConfig)
    : plusOffset = 0,
      minusOffset = 2 * boardConfig.gridCellStep,
      dot1Offset = boardConfig.gridCellSize,
      dot2Offset = boardConfig.gridCellSize + boardConfig.gridCellStep;
}
