import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/models/breadboard_interaction.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/ui/components/breadbord_painter/breadebord_painter.dart';
import 'package:flutter_arduino_playground/ui/components/led_painter.dart';

class ComponentWidget extends StatelessWidget {
  final ComponentModel componentModel;
  final Offset? hoveredLocalPosition;
  final BreadboardHoverState? breadboardHover;
  final Map<String, dynamic>? properties;

  const ComponentWidget({
    super.key,
    required this.componentModel,
    this.hoveredLocalPosition,
    this.breadboardHover,
    this.properties,
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

    if (painter is LEDPainter && properties != null) {
      if (properties!.containsKey('Color')) {
        painter.color = _getColorFromString(properties!['Color']);
      }
    }

    return CustomPaint(size: componentModel.size, painter: painter);
  }

  Color _getColorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'cyan':
        return Colors.cyan;
      case 'pink':
        return Colors.pink;
      case 'orange':
        return Colors.orange;
      case 'red':
      default:
        return Colors.red;
    }
  }
}
