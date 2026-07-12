import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/breadboard_interaction.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/breadebord_painter.dart';

class ComponentWidget extends StatelessWidget {
  final ComponentModel componentModel;
  final Offset? hoveredLocalPosition;
  final BreadboardHoverState? breadboardHover;

  const ComponentWidget({
    super.key,
    required this.componentModel,
    this.hoveredLocalPosition,
    this.breadboardHover,
  });

  @override
  Widget build(BuildContext context) {
    var painter = componentModel.painter;
    if (painter is BreadboardPainter) {
      return CustomPaint(
        size: componentModel.size,
        painter: BreadboardPainter(
          config: painter.config,
          hoverState: breadboardHover,
        ),
      );
    }

    return CustomPaint(size: componentModel.size, painter: painter);
  }
}
