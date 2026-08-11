import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final FocusNode _focusNode = FocusNode();

  bool _isDraggingDuringWiring = false;
  Offset? _startDownPos;
  int _lastClickTime = 0;
  bool _hasSavedHistoryForDrag = false;
  bool _isBoxSelecting = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (controller.isWiring) {
            controller.cancelWiring();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerUp: onPointerUp,
        onPointerDown: onPointerDown,
        onPointerMove: onPointerMove,
        onPointerHover: onPointerHover,
        onPointerCancel: onPointerCancel,
        child: widget.child,
      ),
    );
  }

  void onPointerCancel(PointerCancelEvent event) {
    if (_isBoxSelecting) {
      controller.endBoxSelection();
      _isBoxSelecting = false;
    }
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

      if (_startDownPos != null &&
          (event.localPosition - _startDownPos!).distance > 5) {
        _isDraggingDuringWiring = true;
      }
    } else if (controller.isDraggingBendPoint) {
      if (!_hasSavedHistoryForDrag) {
        controller.saveHistory();
        _hasSavedHistoryForDrag = true;
      }
      controller.updateDraggingBendPoint(canvasPos);
    } else if (_isBoxSelecting) {
      controller.updateBoxSelection(canvasPos);
    } else {
      if (controller.selectedNodes.isNotEmpty &&
          !_hasSavedHistoryForDrag &&
          _startDownPos != null &&
          (event.localPosition - _startDownPos!).distance > 2) {
        controller.saveHistory();
        _hasSavedHistoryForDrag = true;
      }
      controller.moveSelection(event.delta);
    }
  }

  void onPointerUp(PointerUpEvent event) {
    if (controller.isWiring) {
      if (_isDraggingDuringWiring) {
        if (controller.hoveredPort != null) {
          controller.completeWiring(controller.hoveredPort!);
        } else {
          controller.cancelWiring();
        }
      } else {
        // Not dragging, just a click
        if (controller.isMovingWireEndpoint &&
            controller.originalDetachedPort != null) {
          // Restore the detached wire
          controller.completeWiring(controller.originalDetachedPort!);
        }
      }
    } else if (controller.isDraggingBendPoint) {
      controller.stopDraggingBendPoint();
    } else if (_isBoxSelecting) {
      controller.endBoxSelection();
      _isBoxSelecting = false;
    }

    controller.mouseDown = false;
    controller.dragStartOffset = null;
  }

  void onPointerDown(PointerDownEvent event) {
    _focusNode.requestFocus();
    controller.mouseDown = true;
    controller.mouseLocalPosition = event.localPosition;
    final canvasPos = controller.screenToCanvasCoordinates(event.localPosition);
    _startDownPos = event.localPosition;
    _isDraggingDuringWiring = false;
    _hasSavedHistoryForDrag = false;
    _isBoxSelecting = false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final isDoubleClick = (now - _lastClickTime < 300);
    _lastClickTime = now;

    // 0. If already wiring, this click represents the Finish point (or cancellation)
    if (controller.isWiring) {
      if (controller.hoveredPort != null) {
        controller.completeWiring(controller.hoveredPort!);
      } else {
        controller.cancelWiring();
      }
      return;
    }

    // 1. Double-click on a wire to create a bend point
    if (isDoubleClick && controller.hoveredWireId != null) {
      controller.createBendPointAt(canvasPos);
      return;
    }

    // 2. Check Port interaction (Wiring)
    if (controller.hoveredPort != null) {
      final port = controller.hoveredPort!;

      // Check if this port already has a wire
      // Use iterable tools instead of firstOrNull for safety without import if needed,
      // but firstOrNull is supported in Dart 3 which we use.
      final connectedWire = controller.wires
          .where((w) => w.start == port || w.end == port)
          .firstOrNull;

      if (connectedWire != null) {
        // We found an existing wire. Detach this end and start dragging it.
        final newStart = connectedWire.start == port
            ? connectedWire.end
            : connectedWire.start;
        final newBendPoints = connectedWire.start == port
            ? connectedWire.bendPoints.reversed.toList()
            : connectedWire.bendPoints.toList();
        final color = connectedWire.color;
        final originalPort = port;

        controller.removeWire(connectedWire.id);
        controller.currentWireColor = color;
        controller.startWiring(
          newStart,
          canvasPos,
          bendPoints: newBendPoints,
          isMovingExisting: true,
          originalDetachedPort: originalPort,
        );
      } else {
        // Start a new wire
        controller.startWiring(port, canvasPos);
      }
      return;
    }

    // 3. Check Wire interaction (Selection and Bending)
    if (controller.hoveredWireId != null) {
      controller.checkSelection();
      if (controller.hoveredWireId != null &&
          controller.selectedWireIds.contains(controller.hoveredWireId)) {
        controller.startDraggingBendPoint(canvasPos);
        return;
      }
    }

    // 4. Fallback to Node interaction
    controller.checkSelection();

    if (controller.selectedWireIds.isNotEmpty &&
        !controller.isDraggingBendPoint) {
      controller.startDraggingBendPoint(canvasPos);
    } else if (controller.selectedNodes.isEmpty &&
        controller.selectedWireIds.isEmpty) {
      // Clicked on empty space
      _isBoxSelecting = true;
      controller.startBoxSelection(canvasPos);
    }
  }
}
