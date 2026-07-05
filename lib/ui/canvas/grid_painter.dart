import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';

class GridPainter extends CustomPainter {
  GridPainter(this.context, this.controller) : super(repaint: controller);

  final BuildContext context;
  final CanvasController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = controller.scale;
    final Offset o = controller.offset;

    // Get visible bounds in canvas space (Simplified arithmetic)
    final double left = (0 - o.dx) / s - 100;
    final double top = (0 - o.dy) / s - 100;
    final double right = (size.width - o.dx) / s + 100;
    final double bottom = (size.height - o.dy) / s + 100;

    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(s, s);

    final double baseStep = controller.gridCellSize;

    void drawLevel(double multiplier, double baseWidth, Color customColor) {
      final double spacing = baseStep * multiplier;
      final double screenStep = spacing * s;
      
      // 1. Adaptive Visibility (Lowered threshold to ensure visibility at minScale 0.5)
      const double minSpacing = 5.0;
      if (screenStep <= minSpacing) return;

      // 2. Opacity Calculation (Inspired by React: fade between 5px and 50px)
      const double maxSpacing = 50.0;
      double opacity;
      if (screenStep >= maxSpacing) {
        opacity = 1.0;
      } else {
        opacity = (screenStep - minSpacing) / (maxSpacing - minSpacing);
      }
      
      // Use the hierarchical color directly with the adaptive opacity
      final Color finalColor = customColor.withOpacity(opacity * 0.4);

      // 3. Scale-Inverse Thickness
      final double thickness = (baseWidth / s).clamp(0.6 / s, 5.0 / s);

      final paint = Paint()
        ..color = finalColor
        ..strokeWidth = thickness;

      // Vertical lines
      final double startX = (left / spacing).floor() * spacing;
      for (double x = startX; x <= right; x += spacing) {
        canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
      }

      // Horizontal lines
      final double startY = (top / spacing).floor() * spacing;
      for (double y = startY; y <= bottom; y += spacing) {
        canvas.drawLine(Offset(left, y), Offset(right, y), paint);
      }
    }

    // Define levels with increasing spacing, baseWidth, and distinct colors (Inspired by React)
    
    // Level 3: coarsest (Purple tint)
    drawLevel(50, 1.2, Colors.purple);
    // Level 2: medium (Orange/Brown tint)
    drawLevel(10, 1.0, Colors.orange);
    // Level 1: component step (Green tint)
    drawLevel(2, 0.8, Colors.green);
    // Level 0: finest (Blue/Teal tint)
    drawLevel(1, 0.6, Colors.blue);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) =>
      oldDelegate.controller != controller;
}
