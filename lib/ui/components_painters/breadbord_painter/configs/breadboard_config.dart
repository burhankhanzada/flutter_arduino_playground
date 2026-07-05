import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';

class BreadboardConfig {
  final int rowsCount;
  final colsCount = 5; // (a–e) (f–j)

  final padding = 10.0;
  late final boardPadding = padding + GridSystem.cellCenter;

  final gridCellSize = GridSystem.cellSize;
  final gridCellStep = GridSystem.cellSize * 2;

  late final boardHeight = bottomLabelY + boardPadding;
  late final boardWidth = boardPadding * 2 + totalHorizontalCells * gridCellStep;

  late final powerRailCells = 3; // plus rail + inter-rail gap + minus rail
  late final leftSectionCells = powerRailCells + 1; // 1 = row label
  final centerGapCells = 1; // divider between the two signal sections
  late final totalHorizontalCells = (leftSectionCells + colsCount) * 2;

  late final leftSectionStartOffset = boardPadding + leftSectionCells * gridCellStep;
  // late final leftSectionStartOffset = GridSystem.center + leftSectionCells * step;

  late final rightSectionStartOffset =
      boardPadding + (leftSectionCells + centerGapCells + colsCount) * gridCellStep;

  late final rightLabelStartCells =
      leftSectionCells + centerGapCells + 2 * colsCount;

  late final rightRowLabelOffset = boardPadding + rightLabelStartCells * gridCellStep;

  late final rightPowerRailOffset =
      boardPadding + (rightLabelStartCells + 1) * gridCellStep;

  late final firstRowY = boardPadding + gridCellStep;
  late final lastRowY = firstRowY + (rowsCount - 1) * gridCellStep;
  late final bottomLabelY = lastRowY + gridCellStep;

  Size get boardSize => Size(boardWidth, boardHeight);

  BreadboardConfig._({required this.rowsCount});

  factory BreadboardConfig.half() => BreadboardConfig._(rowsCount: 30);
  factory BreadboardConfig.full() => BreadboardConfig._(rowsCount: 60);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreadboardConfig &&
          runtimeType == other.runtimeType &&
          rowsCount == other.rowsCount;

  @override
  int get hashCode => rowsCount.hashCode;
}
