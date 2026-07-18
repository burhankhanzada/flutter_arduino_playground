import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';
import 'package:flutter_arduino_playground/ui/components_painters/port_provider.dart';

class LEDPainter extends CustomPainter with PortProvider {
  final _paint = Paint();

  static const _bodyHeight = 40.0;
  static const _legsHeight = 20.0;

  static const _width = 30.0;
  static const _height = _bodyHeight + _legsHeight;

  static const componentSize = Size(_width, _height);

  @override
  List<ComponentPort> getPorts() {
    const endY = _height - GridSystem.cellCenter;
    const leftLegX = GridSystem.cellCenter;
    const rightLegX = _width - GridSystem.cellCenter;

    return [
      const ComponentPort(
        id: 'anode',
        name: 'Anode',
        localOffset: Offset(leftLegX, endY),
      ),
      const ComponentPort(
        id: 'cathode',
        name: 'Cathode',
        localOffset: Offset(rightLegX, endY),
      ),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawLegs(canvas);
    _drawBody(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  void _drawBody(Canvas canvas) {
    const topRadius = Radius.circular(15);
    const bottomRadius = Radius.circular(4);
    const innerRadius = Radius.circular(2);

    // Main body
    _paint.color = Colors.red;
    _paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(0, 0, _width, _bodyHeight),
        topLeft: topRadius,
        topRight: topRadius,
        bottomLeft: bottomRadius,
        bottomRight: bottomRadius,
      ),
      _paint,
    );

    // Inner highlight for a slight 3D look
    _paint.color = Colors.red[300]!;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(4, 4, _width - 12, _bodyHeight - 10),
        topLeft: topRadius,
        topRight: topRadius,
        bottomLeft: innerRadius,
        bottomRight: innerRadius,
      ),
      _paint,
    );
  }

  void _drawLegs(Canvas canvas) {
    _paint.strokeWidth = 4;
    _paint.strokeCap = StrokeCap.round;
    _paint.color = Colors.grey[400]!;

    const leftLegX = GridSystem.cellCenter;
    const rightLegX = _width - GridSystem.cellCenter;

    // Legs start slightly inside the bottom of the body
    const startY = _bodyHeight - 2.0;

    // Legs end exactly at the hole center in the bottom-most grid cell
    const endY = _height - GridSystem.cellCenter;

    for (final x in [leftLegX, rightLegX]) {
      canvas.drawLine(Offset(x, startY), Offset(x, endY), _paint);
    }
  }
}
