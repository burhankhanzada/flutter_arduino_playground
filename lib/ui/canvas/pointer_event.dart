import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';

class CanvasPointerEvent extends StatefulWidget {
  const CanvasPointerEvent({
    super.key,
    required this.child,
    required this.controller,
  });

  final Widget child;
  final CanvasController controller;

  @override
  State<CanvasPointerEvent> createState() => _CanvasPointerEventState();
}

class _CanvasPointerEventState extends State<CanvasPointerEvent> {
  CanvasController get controller => widget.controller;

  double _lastScale = 1.0;
  Offset _lastPan = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerUp: onPointerUp,
      onPointerDown: onPointerDown,
      onPointerMove: onPointerMove,
      onPointerHover: onPointerHover,
      onPointerCancel: onPointerCancel,
      onPointerSignal: _onPointerSignal,
      onPointerPanZoomStart: (event) {
        _lastScale = 1.0;
        _lastPan = Offset.zero;
      },
      onPointerPanZoomUpdate: (event) {
        // Handle two-finger pan
        final Offset panDelta = event.pan - _lastPan;
        _lastPan = event.pan;
        controller.pan(panDelta);

        // Handle pinch zoom
        final double relativeScale = event.scale / _lastScale;
        _lastScale = event.scale;
        if (relativeScale != 1.0) {
          controller.zoom(relativeScale, focusPoint: event.localPosition);
        }
      },
      onPointerPanZoomEnd: (event) {
        _lastScale = 1.0;
        _lastPan = Offset.zero;
      },
      child: widget.child,
    );
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final double zoomFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
      controller.zoom(zoomFactor, focusPoint: event.localPosition);
    }
  }

  void onPointerCancel(PointerCancelEvent event) {
    controller.mouseDown = false;
    controller.dragStartOffset = null;
  }

  void onPointerHover(PointerHoverEvent event) {
    controller.mouseLocalPosition = event.localPosition;
    if (!controller.mouseDown) {
      controller.checkHover();
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    controller.mouseLocalPosition = event.localPosition;
    final canvasPos = controller.screenToCanvasCoordinates(event.localPosition);

    if (controller.isWiring) {
      controller.checkHover();
      controller.updateWiring(canvasPos);
    } else {
      controller.moveSelection(event.delta);
    }
  }

  void onPointerUp(PointerUpEvent event) {
    if (controller.isWiring) {
      if (controller.hoveredPort != null) {
        controller.completeWiring(controller.hoveredPort!);
      } else {
        controller.cancelWiring();
      }
    }

    controller.mouseDown = false;
    controller.dragStartOffset = null;
  }

  void onPointerDown(PointerDownEvent event) {
    controller.mouseDown = true;
    controller.mouseLocalPosition = event.localPosition;

    if (controller.hoveredPort != null) {
      final canvasPos = controller.screenToCanvasCoordinates(event.localPosition);
      controller.startWiring(controller.hoveredPort!, canvasPos);
    } else {
      controller.checkSelection();
    }
  }
}
