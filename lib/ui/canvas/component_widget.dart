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
  final bool isOutline;
  final Size? customSize;

  const ComponentWidget({
    super.key,
    required this.componentModel,
    this.hoveredLocalPosition,
    this.breadboardHover,
    this.properties,
    this.isOutline = false,
    this.customSize,
  });

  @override
  Widget build(BuildContext context) {
    final actualSize = customSize ?? componentModel.size;

    var painter = componentModel.painter;

    if (painter is LEDPainter) {
      final isOn = properties?['isOn'] == true;
      final hasError = properties?['hasError'] == true;
      final colorProp = properties?['color'] ?? properties?['Color'];
      final color = colorProp != null ? _parseColor(colorProp) : Colors.redAccent;

      return CustomPaint(
        size: actualSize,
        painter: LEDPainter.withState(
          isOn: isOn,
          color: color,
          hasError: hasError,
        ),
      );
    }

    if (painter is BreadboardPainter) {
      return CustomPaint(
        size: actualSize,
        painter: BreadboardPainter(
          config: painter.config,
          hoverState: breadboardHover,
        ),
      );
    }

    return CustomPaint(size: actualSize, painter: painter);
  }

  Color _parseColor(dynamic val) {
    if (val is Color) return val;
    if (val is String) {
      var str = val.trim();
      if (str.startsWith('#')) {
        var hex = str.substring(1);
        if (hex.length == 6) {
          hex = 'FF$hex';
        }
        final intVal = int.tryParse(hex, radix: 16);
        if (intVal != null) {
          return Color(intVal);
        }
      }
      switch (str.toLowerCase()) {
        case 'green':
          return Colors.green;
        case 'blue':
          return Colors.blue;
        case 'yellow':
          return Colors.yellow;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'white':
          return Colors.white;
        case 'grey':
        case 'gray':
          return Colors.grey;
        case 'red':
        default:
          return Colors.redAccent;
      }
    }
    return Colors.redAccent;
  }
}
