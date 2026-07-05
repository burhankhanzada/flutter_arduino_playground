import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/breadboard_config.dart';

class TerminalStripConfig {
  final double rowLabelRelX;
  final List<String> columnLabels;

  TerminalStripConfig._({
    required this.rowLabelRelX,
    required this.columnLabels,
  });

  factory TerminalStripConfig.left(BreadboardConfig config) {
    return TerminalStripConfig._(
      rowLabelRelX: -config.gridCellStep,
      columnLabels: const ['a', 'b', 'c', 'd', 'e'],
    );
  }

  factory TerminalStripConfig.right(BreadboardConfig config) {
    return TerminalStripConfig._(
      rowLabelRelX: config.colsCount * config.gridCellStep,
      columnLabels: const ['f', 'g', 'h', 'i', 'j'],
    );
  }
}
