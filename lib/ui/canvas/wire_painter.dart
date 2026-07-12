import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/models/wire_model.dart';

class WirePainter extends CustomPainter {
  final List<WireModel> wires;
  final List<CanvasNodeModel> nodes;
  final PortLocation? pendingStart;
  final Offset? pendingEndMouse;
  final PortLocation? hoveredPort;
  final Color pendingColor;

  WirePainter({
    required this.wires,
    required this.nodes,
    this.pendingStart,
    this.pendingEndMouse,
    this.hoveredPort,
    this.pendingColor = Colors.yellow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw established wires
    for (final wire in wires) {
      final startPos = _getPortPosition(wire.start);
      final endPos = _getPortPosition(wire.end);

      if (startPos != null && endPos != null) {
        paint.color = wire.color;
        _drawBezierCurve(canvas, startPos, endPos, paint);
      }
    }

    // Draw pending wire
    if (pendingStart != null && pendingEndMouse != null) {
      final startPos = _getPortPosition(pendingStart!);
      if (startPos != null) {
        paint.color = pendingColor.withOpacity(0.7);
        _drawBezierCurve(canvas, startPos, pendingEndMouse!, paint);
      }
    }

    // Draw hovered port indicator
    if (hoveredPort != null) {
      final portPos = _getPortPosition(hoveredPort!);
      if (portPos != null) {
        final glowPaint = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(portPos, 8, glowPaint);
        
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(portPos, 4, borderPaint);
      }
    }
  }

  Offset? _getPortPosition(PortLocation loc) {
    try {
      final node = nodes.firstWhere((n) => n.key == loc.nodeKey);
      final localOffset = node.getPortOffset(loc.portId);
      if (localOffset == null) return null;
      return node.position + localOffset;
    } catch (_) {
      return null;
    }
  }

  void _drawBezierCurve(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Control points biased horizontally
    final double dist = (end - start).distance;
    final double hControl = (dist * 0.4).clamp(10.0, 150.0);

    path.cubicTo(
      start.dx + hControl,
      start.dy,
      end.dx - hControl,
      end.dy,
      end.dx,
      end.dy,
    );

    // Draw glow effect if selected/hovered (simple version for now)
    final shadowPaint = Paint()
      ..color = paint.color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WirePainter oldDelegate) {
    return true; // Simple for now to ensure smooth drag
  }
}
