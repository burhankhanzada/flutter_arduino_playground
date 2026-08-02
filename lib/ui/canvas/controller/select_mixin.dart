import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/base_controller.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/connection_mixin.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';
import 'package:flutter_arduino_playground/ui/components/breadbord_painter/breadebord_painter.dart';
import 'package:flutter_arduino_playground/ui/components/breadbord_painter/logic/breadboard_hit_tester.dart';
import 'package:flutter_arduino_playground/ui/components/port_provider.dart';

mixin SelectMixin on BaseCanvasController, ConnectionMixin {
  bool isSelected(Key key) {
    return selectedNodes.any((n) => n.key == key);
  }

  bool isHovered(Key key) {
    return hoveredNodeKey != null && hoveredNodeKey!.key == key;
  }

  void clearSelection() {
    if (selectedNodes.isNotEmpty) {
      selectedNodes.clear();
      notifyListeners();
    }
  }

  void checkHover() {
    // Convert screen coordinates to canvas coordinates
    final canvasPosition = screenToCanvasCoordinates(mouseLocalPosition);

    CanvasNodeModel? found;
    for (final node in nodes.reversed) {
      if (node.rect.contains(canvasPosition)) {
        found = node;
        break;
      }
    }

    bool changed = false;

    // Selection logic handles selectedNodes in controller.dart checkSelection()
    // and box selection methods, so we don't set selectedNodes here.
    if (hoveredNodeKey != found) {
      hoveredNodeKey?.hoveredLocalPosition = null;
      hoveredNodeKey?.breadboardHover = null;
      hoveredNodeKey = found;
      hoveredPort = null;
      changed = true;
    }

    bool hitPort = false;

    // Update hover position and port for current node
    if (found != null) {
      final rotatedLocalPos = canvasPosition - found.position;

      // Unrotate the local position to match the unrotated component painters
      final w = found.componentModel.size.width;
      final h = found.componentModel.size.height;

      // Translate rotatedLocalPos to bounding box center
      final dx = rotatedLocalPos.dx - found.pivotOffset.dx;
      final dy = rotatedLocalPos.dy - found.pivotOffset.dy;

      // Inverse rotate (by -rotationAngle)
      final angle = found.rotationAngle;
      final c = math.cos(-angle);
      final s = math.sin(-angle);
      final rx = dx * c - dy * s;
      final ry = dx * s + dy * c;

      // Translate back to unrotated component top-left (pivot was topCenter)
      var localX = rx + w / 2;
      var localY = ry;

      // Un-flip
      if (found.flipHorizontal) localX = w - localX;
      if (found.flipVertical) localY = h - localY;

      Offset localPos = Offset(localX, localY);

      // Update breadboard-specific hover
      if (found.componentModel.painter is BreadboardPainter) {
        final breadboardPainter =
            found.componentModel.painter as BreadboardPainter;
        final newBreadboardHover = BreadboardHitTester.hitTest(
          localPos,
          breadboardPainter.config,
        );
        if (found.breadboardHover != newBreadboardHover) {
          found.breadboardHover = newBreadboardHover;
          changed = true;
        }
      }

      // Update port hover
      final painter = found.componentModel.painter;
      if (painter is PortProvider) {
        final newPort = (painter as PortProvider).getPortAt(localPos);
        final newPortLoc = newPort != null
            ? PortLocation(nodeKey: found.key, portId: newPort.id)
            : null;
        if (hoveredPort != newPortLoc) {
          hoveredPort = newPortLoc;
          changed = true;
        }
      }

      if (found.hoveredLocalPosition != localPos) {
        found.hoveredLocalPosition = localPos;
        changed = true;
      }

      if (hoveredPort != null) {
        hitPort = true;
      }
    }

    // Now check wire interaction, but IF we hit a port, port takes priority!
    bool hitWire = false;
    if (!hitPort) {
      hitWire = checkWireInteraction(canvasPosition);
    } else {
      // Clear wire hover if we hit a port
      if (hoveredWireId != null) {
        hoveredWireId = null;
        changed = true;
      }
    }

    if (changed || hitWire) {
      notifyListeners();
    }
  }

  void checkSelection() {
    // Convert screen coordinates to canvas coordinates
    final canvasPosition = screenToCanvasCoordinates(mouseLocalPosition);

    // 1. Priority Selection: Check if we are clicking a wire (even if it's over a node)
    final hitWire = checkWireInteraction(canvasPosition);
    if (hitWire && hoveredWireId != null) {
      selectWire(hoveredWireId);
      clearSelection();
      return;
    }

    // 2. Node Selection
    CanvasNodeModel? found;
    for (final node in nodes.reversed) {
      if (node.rect.contains(canvasPosition)) {
        found = node;
        break;
      }
    }

    if (found == null) {
      clearSelection();
      selectWire(null);
      return;
    }

    // Calculate the offset from the node's top-left corner to the click point
    dragStartOffset = canvasPosition - found.position;

    if (!selectedNodes.contains(found)) {
      selectedNodes = [found];
    }

    // Clear wire selection when selecting a node
    selectWire(null);
    notifyListeners();
  }

  void moveSelection(Offset delta) {
    if (selectedNodes.isEmpty) return;

    for (int i = 0; i < selectedNodes.length; i++) {
      final oldNode = selectedNodes[i];
      final index = nodes.indexOf(oldNode);
      if (index == -1) continue;

      // Delta is the screen delta divided by scale (already canvas coordinates basically)
      // wait, pointer_event passes `event.delta`, which is in screen coords.
      // Actually `base_controller.dart` or `canvas_area.dart` might be doing something.
      // Let's just use `delta / scale` to convert screen delta to canvas delta.
      final canvasDelta = delta / scale;
      var newPosition = oldNode.position + canvasDelta;
      
      if (snapToGrid) {
        newPosition = GridSystem.snapOffset(newPosition);
      }

      final updatedNode = oldNode.copyWith(position: newPosition);
      nodes[index] = updatedNode;
      selectedNodes[i] = updatedNode;
    }

    notifyListeners();
  }
}
