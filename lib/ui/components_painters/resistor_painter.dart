import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';
import 'package:flutter_arduino_playground/ui/components_painters/port_provider.dart';

class ResistorPainter extends CustomPainter implements PortProvider {
  final _paint = Paint();

  static const double gridCellSize = GridSystem.cellSize;
  static const double gridCellCenter = GridSystem.cellCenter;

  static const _bodyWidth = 30.0;
  static const _bodyHeight = 10.0;
  static const _legsWidth = 20.0;

  static const _width = _bodyWidth + (_legsWidth * 2);
  static const _height = 30.0;

  static const _bandWidth = 3.0;

  static const componentSize = Size(_width, _height);

  @override
  List<ComponentPort> getPorts() {
    const centerY = _height / 2;
    const leftLegX = gridCellCenter;
    const rightLegX = _width - gridCellCenter;

    return [
      const ComponentPort(
        id: 'left',
        name: 'Left Leg',
        localOffset: Offset(leftLegX, centerY),
      ),
      const ComponentPort(
        id: 'right',
        name: 'Right Leg',
        localOffset: Offset(rightLegX, centerY),
      ),
    ];
  }

  @override
  ComponentPort? getPortAt(Offset localOffset) {
    for (final port in getPorts()) {
      if ((port.localOffset - localOffset).distance < 15.0) {
        return port;
      }
    }
    return null;
  }

  @override
  Offset? getPortOffsetById(String id) {
    for (final port in getPorts()) {
      if (port.id == id) return port.localOffset;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawLegs(canvas);
    _drawBody(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  void _drawLegs(Canvas canvas) {
    _paint.strokeWidth = 4;
    _paint.color = Colors.grey[400]!;
    _paint.strokeCap = StrokeCap.round;

    const centerY = _height / 2;
    const leftLegX = gridCellCenter;
    const rightLegX = _width - gridCellCenter;

    canvas.drawLine(
      Offset(leftLegX, centerY),
      Offset(rightLegX, centerY),
      _paint,
    );
  }

  void _drawBody(Canvas canvas) {
    const center = Offset(_width / 2, _height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: _bodyWidth,
      height: _bodyHeight,
    );
    final bodyRRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    // Main body (Tan/Beige)
    _paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFE6D5B8), // Highlight
        Color(0xFFB89B77), // Shadow
      ],
    ).createShader(rect);

    canvas.drawRRect(bodyRRect, _paint);
    _paint.shader = null;

    _drawBands(canvas, bodyRRect);

    canvas.restore();
  }

  void _drawBands(Canvas canvas, RRect bodyRRect) {
    canvas.save();
    canvas.clipRRect(bodyRRect);

    const bandSpacing = 5.0;
    final startX = -_bodyWidth / 2 + 5.0;

    // Bands (220 Ohm: Red, Black, Brown, Gold)
    _drawBand(canvas, startX, Colors.red);
    _drawBand(canvas, startX + bandSpacing, Colors.black);
    _drawBand(canvas, startX + bandSpacing * 2, Colors.brown);

    // Tolerance band (Gold) slightly separated
    _drawBand(canvas, _bodyWidth / 2 - 5.0 - _bandWidth, Colors.yellow);

    canvas.restore();
  }

  void _drawBand(Canvas canvas, double x, Color color) {
    _paint.color = color;
    _paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        x.roundToDouble(),
        -_bodyHeight / 2,
        _bandWidth,
        _bodyHeight,
      ),
      _paint,
    );
  }
}
