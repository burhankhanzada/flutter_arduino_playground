import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';
import 'package:flutter_arduino_playground/ui/components/port_provider.dart';

class LEDPainter extends CustomPainter with PortProvider {
  final _paint = Paint();
  final ValueNotifier<bool> _isOnNotifier;
  final ValueNotifier<Color> _colorNotifier;
  final ValueNotifier<bool> _hasErrorNotifier;

  LEDPainter._(this._isOnNotifier, this._colorNotifier, this._hasErrorNotifier)
    : super(repaint: Listenable.merge([_isOnNotifier, _colorNotifier, _hasErrorNotifier]));

  factory LEDPainter() => LEDPainter._(
    ValueNotifier<bool>(false),
    ValueNotifier<Color>(Colors.redAccent),
    ValueNotifier<bool>(false),
  );

  factory LEDPainter.withState({
    bool isOn = false,
    Color color = Colors.redAccent,
    bool hasError = false,
  }) => LEDPainter._(
    ValueNotifier<bool>(isOn),
    ValueNotifier<Color>(color),
    ValueNotifier<bool>(hasError),
  );

  bool get isOn => _isOnNotifier.value;
  set isOn(bool value) => _isOnNotifier.value = value;

  Color get color => _colorNotifier.value;
  set color(Color value) => _colorNotifier.value = value;

  bool get hasError => _hasErrorNotifier.value;
  set hasError(bool value) => _hasErrorNotifier.value = value;

  bool drawGlow = true;

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
        localOffset: Offset(rightLegX, endY),
      ),
      const ComponentPort(
        id: 'cathode',
        name: 'Cathode',
        localOffset: Offset(leftLegX, endY),
      ),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawLegs(canvas);
    _drawBody(canvas);
  }

  @override
  bool shouldRepaint(covariant LEDPainter oldDelegate) {
    return true;
  }

  @override
  bool? hitTest(Offset position) {
    return true; // Accept clicks anywhere within the component bounds
  }

  void _drawBody(Canvas canvas) {
    const topRadius = Radius.circular(15);
    const bottomRadius = Radius.circular(4);
    const innerRadius = Radius.circular(2);

    // We create a darker version for when it's off
    final hsl = HSLColor.fromColor(color);
    final darkColor = hsl
        .withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0))
        .toColor();
    final highlight = hsl
        .withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0))
        .toColor();

    final baseColor = isOn && !hasError ? color : darkColor;
    final highlightColor = isOn && !hasError ? Colors.white70 : highlight;

    if (isOn && !hasError && drawGlow) {
      // Draw a glowing effect
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(-10, -10, _width + 20, _bodyHeight + 20),
          topLeft: topRadius,
          topRight: topRadius,
          bottomLeft: bottomRadius,
          bottomRight: bottomRadius,
        ),
        glowPaint,
      );
    }

    // Main body
    _paint.color = baseColor;
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
    _paint.color = highlightColor;
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
    
    if (hasError) {
      _paint.color = Colors.red;
      _paint.style = PaintingStyle.stroke;
      _paint.strokeWidth = 3;
      canvas.drawLine(const Offset(5, 5), const Offset(_width - 5, _bodyHeight - 5), _paint);
      canvas.drawLine(const Offset(_width - 5, 5), const Offset(5, _bodyHeight - 5), _paint);
    }
  }

  void _drawLegs(Canvas canvas) {
    _paint.strokeWidth = 4;
    _paint.strokeCap = StrokeCap.round;
    _paint.color = Colors.grey[400]!;
    _paint.style = PaintingStyle.stroke;

    const leftLegX = GridSystem.cellCenter;
    const rightLegX = _width - GridSystem.cellCenter;

    // Legs start slightly inside the bottom of the body
    const startY = _bodyHeight - 2.0;

    // Legs end exactly at the hole center in the bottom-most grid cell
    const endY = _height - GridSystem.cellCenter;

    // Cathode (Left Leg) - Straight
    canvas.drawLine(Offset(leftLegX, startY), Offset(leftLegX, endY), _paint);

    // Anode (Right Leg) - Kinked
    final anodeStartX = rightLegX - 8.0; // Starts closer to the center
    final bendStartY = startY + 4.0;
    final bendEndY = startY + 10.0;

    final path = Path();
    path.moveTo(anodeStartX, startY);
    path.lineTo(anodeStartX, bendStartY);
    path.lineTo(rightLegX, bendEndY);
    path.lineTo(rightLegX, endY);
    
    canvas.drawPath(path, _paint);
  }
}

class LEDOutlinePainter extends CustomPainter {
  final LEDPainter original;

  LEDOutlinePainter(this.original) : super(repaint: original);

  @override
  void paint(Canvas canvas, Size size) {
    final prevGlow = original.drawGlow;
    original.drawGlow = false;
    original.paint(canvas, size);
    original.drawGlow = prevGlow;
  }

  @override
  bool shouldRepaint(covariant LEDOutlinePainter oldDelegate) {
    return true;
  }
}
