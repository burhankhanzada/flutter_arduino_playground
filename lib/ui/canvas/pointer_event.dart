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
    } else if (controller.isDraggingBendPoint) {
      if (!_hasSavedHistoryForDrag) {
        controller.saveHistory();
        _hasSavedHistoryForDrag = true;
      }
      controller.updateDraggingBendPoint(canvasPos);
    } else if (_isBoxSelecting) {
      controller.updateBoxSelection(canvasPos);
    } else {
      if (controller.selectedNodes.isNotEmpty && !_hasSavedHistoryForDrag && _startDownPos != null && (event.localPosition - _startDownPos!).distance > 2) {
        controller.saveHistory();
        _hasSavedHistoryForDrag = true;
      }
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
      controller.startWiring(controller.hoveredPort!, canvasPos);
      return;
    }

    // 3. Check Wire interaction (Selection and Bending)
    if (controller.hoveredWireId != null) {
      controller.checkSelection();
      if (controller.selectedWireId == controller.hoveredWireId) {
        controller.startDraggingBendPoint(canvasPos);
        return;
      }
    }

    // 4. Fallback to Node interaction
    controller.checkSelection();

    // If a wire was just selected (or already selected) and we missed it in step 2 (edge case)
    if (controller.selectedWireId != null && !controller.isDraggingBendPoint) {
      controller.startDraggingBendPoint(canvasPos);
    } else if (controller.selectedNodes.isEmpty && controller.selectedWireId == null) {
      // Clicked on empty space
      _isBoxSelecting = true;
      controller.startBoxSelection(canvasPos);
    }
  }
}
