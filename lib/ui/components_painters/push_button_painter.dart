import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';
import 'package:flutter_arduino_playground/ui/components_painters/port_provider.dart';

class PushButtonPainter extends CustomPainter implements PortProvider {
  final Paint _paint = Paint();

  static const _bodySize = 50.0;
  static const _legsHeight = 20.0;

  static const _height = _bodySize + _legsHeight;

  static const componentSize = Size(_bodySize, _height);

  @override
  List<ComponentPort> getPorts() {
    final centerY = _height / 2;
    const legHeight = _height - GridSystem.cellCenter * 2;
    const leftLegX = GridSystem.cellCenter;
    const rightLegX = _bodySize - GridSystem.cellCenter;

    final topY = centerY - legHeight / 2;
    final bottomY = centerY + legHeight / 2;

    return [
      ComponentPort(id: 'leg1', name: 'Leg 1', localOffset: Offset(leftLegX, topY)),
      ComponentPort(id: 'leg2', name: 'Leg 2', localOffset: Offset(rightLegX, topY)),
      ComponentPort(id: 'leg3', name: 'Leg 3', localOffset: Offset(leftLegX, bottomY)),
      ComponentPort(id: 'leg4', name: 'Leg 4', localOffset: Offset(rightLegX, bottomY)),
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
    final centerY = _height / 2;
    const legHeight = _height - GridSystem.cellCenter * 2;
    const leftLegX = GridSystem.cellCenter;
    const rightLegX = _bodySize - GridSystem.cellCenter;

    _paint.strokeWidth = 4;
    _paint.color = Colors.grey[400]!;
    _paint.strokeCap = StrokeCap.round;

    for (final x in [leftLegX, rightLegX]) {
      canvas.drawLine(
        Offset(x, centerY - legHeight / 2),
        Offset(x, centerY + legHeight / 2),
        _paint,
      );
    }
  }

  void _drawBody(Canvas canvas) {
    final bodyFillColor = Colors.grey[400]!;
    final bodyBorderColor = Colors.grey[500]!;
    final cornerDotColor = Colors.grey[800]!;
    final buttonFillColor = Colors.grey[900]!;
    final buttonBorderColor = Colors.grey[700]!;

    const bodyRadius = Radius.circular(6);
    const innerRadius = Radius.circular(5);
    final center = Offset(_bodySize / 2, _height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Main body border
    _paint.color = bodyBorderColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: _bodySize,
          height: _bodySize,
        ),
        bodyRadius,
      ),
      _paint,
    );

    // Main body fill
    _paint.color = bodyFillColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: _bodySize - 3,
          height: _bodySize - 3,
        ),
        innerRadius,
      ),
      _paint,
    );

    // Corner dots
    _paint.color = cornerDotColor;
    const double cornerInset = 17.0; // (50/2) - 8 = 17
    const double dotRadius = 4.0;

    for (final dx in [-cornerInset, cornerInset]) {
      for (final dy in [-cornerInset, cornerInset]) {
        canvas.drawCircle(Offset(dx, dy), dotRadius, _paint);
      }
    }

    // Button border
    _paint.color = buttonBorderColor;
    canvas.drawCircle(Offset.zero, 15, _paint);

    // Button fill
    _paint.color = buttonFillColor;
    canvas.drawCircle(Offset.zero, 14, _paint);

    canvas.restore();
  }
}
