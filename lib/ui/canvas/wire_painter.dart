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
  final String? hoveredWireId;
  final String? selectedWireId;
  final Color pendingColor;
  final Color selectionColor;

  WirePainter({
    required this.wires,
    required this.nodes,
    this.pendingStart,
    this.pendingEndMouse,
    this.hoveredPort,
    this.hoveredWireId,
    this.selectedWireId,
    this.selectionColor = Colors.blue,
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
        final isHovered = wire.id == hoveredWireId;
        final isSelected = wire.id == selectedWireId;

        paint.color = wire.color;
        if (isSelected || isHovered) {
          paint.strokeWidth = 4.0;
        } else {
          paint.strokeWidth = 3.0;
        }

        _drawPolyline(
          canvas,
          startPos,
          endPos,
          wire.bendPoints,
          paint,
          isSelected || isHovered,
        );

        if (isSelected) {
          _drawHandles(canvas, startPos, endPos, wire.bendPoints, wire.color);
        }
      }
    }

    // Draw pending wire
    if (pendingStart != null && pendingEndMouse != null) {
      final startPos = _getPortPosition(pendingStart!);
      if (startPos != null) {
        paint.color = pendingColor.withValues(alpha: 0.7);
        paint.strokeWidth = 3.0;
        _drawPolyline(canvas, startPos, pendingEndMouse!, [], paint, false);
      }
    }

    // Draw hovered port indicator
    if (hoveredPort != null) {
      final portPos = _getPortPosition(hoveredPort!);
      if (portPos != null) {
        final glowPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
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

  void _drawPolyline(
    Canvas canvas,
    Offset start,
    Offset end,
    List<Offset> bendPoints,
    Paint paint,
    bool highlighted,
  ) {
    if (bendPoints.isEmpty) {
      canvas.drawLine(start, end, paint);
      if (highlighted) {
        final outlinePaint = Paint()
          ..color = selectionColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = paint.strokeWidth + 4
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(start, end, outlinePaint);
        // Draw the wire again on top of the outline
        canvas.drawLine(start, end, paint);
      }
      return;
    }

    final path = Path();
    final allPoints = [start, ...bendPoints, end];
    const double preferredRadius = 12.0;

    path.moveTo(allPoints[0].dx, allPoints[0].dy);

    for (int i = 1; i < allPoints.length - 1; i++) {
      final prev = allPoints[i - 1];
      final curr = allPoints[i];
      final next = allPoints[i + 1];

      // Calculate segments
      final vPrev = prev - curr;
      final vNext = next - curr;

      final dPrev = vPrev.distance;
      final dNext = vNext.distance;

      // Determine radius (clamp if segment is too short)
      double radius = preferredRadius;
      if (dPrev < radius * 2) radius = dPrev / 2;
      if (dNext < radius * 2) radius = dNext / 2;

      // Entry/Exit points for the corner
      final entry = curr + (vPrev / dPrev) * radius;
      final exit = curr + (vNext / dNext) * radius;

      // Draw line to start of corner, then curve
      path.lineTo(entry.dx, entry.dy);
      path.quadraticBezierTo(curr.dx, curr.dy, exit.dx, exit.dy);
    }

    path.lineTo(allPoints.last.dx, allPoints.last.dy);

    if (highlighted) {
      final outlinePaint = Paint()
        ..color = selectionColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = paint.strokeWidth + 4
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, outlinePaint);
    }

    canvas.drawPath(path, paint);
  }

  void _drawHandles(
    Canvas canvas,
    Offset start,
    Offset end,
    List<Offset> bendPoints,
    Color color,
  ) {
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw all handles (including endpoints) identically
    final allPoints = [start, ...bendPoints, end];
    for (final point in allPoints) {
      canvas.drawCircle(point, 3.5, handlePaint);
      canvas.drawCircle(point, 3.5, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WirePainter oldDelegate) {
    return true;
  }
}
