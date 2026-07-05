import 'dart:ui';

class GridSystem {
  static const cellSize = 10.0;
  static const cellCenter = cellSize / 2;

  static double snap(double value) {
    return (value / cellSize).round() * cellSize;
  }

  static Offset snapOffset(Offset offset) {
    return Offset(snap(offset.dx), snap(offset.dy));
  }
}
