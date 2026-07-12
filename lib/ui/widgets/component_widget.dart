import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/breadebord_painter.dart';

class ComponentWidget extends StatelessWidget {
  final ComponentModel componentModel;
  final Offset? hoveredLocalPosition;

  const ComponentWidget({
    super.key,
    required this.componentModel,
    this.hoveredLocalPosition,
  });

  @override
  Widget build(BuildContext context) {
    var painter = componentModel.painter;
    if (painter is BreadboardPainter) {
      painter.hoveredLocalPosition = hoveredLocalPosition;
    }

    return CustomPaint(size: componentModel.size, painter: painter);
  }
}
