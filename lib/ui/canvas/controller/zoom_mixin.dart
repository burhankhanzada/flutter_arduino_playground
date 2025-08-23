import 'dart:ui';
import 'package:flutter_arduino_playground/ui/canvas/controller/base_controller.dart';
mixin ZoomMixin on BaseCanvasController {
  void zoomIn() => zoom(1.1);
  void zoomOut() => zoom(0.9);

  void zoom(double factor, {Offset? focusPoint}) {
    final double oldScale = scale;
    final double newScale = (oldScale * factor).clamp(minScale, maxScale);
    
    if (oldScale == newScale) return;

    if (focusPoint != null) {
      final double worldX = (focusPoint.dx - offset.dx) / oldScale;
      final double worldY = (focusPoint.dy - offset.dy) / oldScale;

      // Update both but only notify once if we can. 
      // BaseController setters notify, so let's use a batch update if we add it. 
      // For now, just use them.
      offset = Offset(
        focusPoint.dx - worldX * newScale,
        focusPoint.dy - worldY * newScale,
      );
    }

    scale = newScale;
  }
}
