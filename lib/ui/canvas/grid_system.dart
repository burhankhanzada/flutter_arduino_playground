import 'dart:ui';

class GridSystem {
  static const cellSize = 10.0;
  static const cellCenter = cellSize / 2;

  static double snap(double value) {
    return (value / cellSize).round() * cellSize;
  }

  static double snapToCenter(double value) {
    return (value / cellSize).floor() * cellSize + cellCenter;
  }

  static Offset snapOffset(Offset offset) {
    return Offset(snap(offset.dx), snap(offset.dy));
  }

  static Offset snapToCenterOffset(Offset offset) {
    return Offset(snapToCenter(offset.dx), snapToCenter(offset.dy));
  }
}
