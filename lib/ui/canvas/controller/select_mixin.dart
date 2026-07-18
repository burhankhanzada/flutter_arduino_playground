import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'dart:math' as math;
import 'package:flutter_arduino_playground/ui/canvas/controller/base_controller.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/connection_mixin.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/breadebord_painter.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/logic/breadboard_hit_tester.dart';
import 'package:flutter_arduino_playground/ui/components_painters/port_provider.dart';

mixin SelectMixin on BaseCanvasController, ConnectionMixin {
  bool isSelected(Key key) {
    return selectedNodeKey != null && selectedNodeKey!.key == key;
  }

  bool isHovered(Key key) {
    return hoveredNodeKey != null && hoveredNodeKey!.key == key;
  }

  void clearSelection() {
    if (selectedNodeKey != null) {
      selectedNodeKey = null;
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

    // Clear hover status for previous node if it changed
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
        final breadboardPainter = found.componentModel.painter as BreadboardPainter;
        final newBreadboardHover = BreadboardHitTester.hitTest(localPos, breadboardPainter.config);
        if (found.breadboardHover != newBreadboardHover) {
          found.breadboardHover = newBreadboardHover;
          changed = true;
        }
      }

      // Update port hover
      final painter = found.componentModel.painter;
      if (painter is PortProvider) {
        final newPort = (painter as PortProvider).getPortAt(localPos);
        final newPortLoc = newPort != null ? PortLocation(nodeKey: found.key, portId: newPort.id) : null;
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

    if (selectedNodeKey != found) {
      selectedNodeKey = found;
      // Clear wire selection when selecting a node
      selectWire(null);
      notifyListeners();
    }
  }

  void moveSelection(Offset delta) {
    if (selectedNodeKey == null) {
      return;
    }

    final index = nodes.indexOf(selectedNodeKey!);
    if (index == -1) return;

    // Convert screen coordinates to canvas coordinates
    final canvasPosition = screenToCanvasCoordinates(mouseLocalPosition);

    // Calculate the new position considering the drag offset
    Offset newPosition = canvasPosition;

    if (dragStartOffset != null) {
      // Subtract the drag offset to maintain the original click position relative to the node
      newPosition = canvasPosition - dragStartOffset!;
    }

    if (snapToGrid) {
      newPosition = GridSystem.snapOffset(newPosition);
    }

    final updatedNode = selectedNodeKey!.copyWith(position: newPosition);

    selectedNodeKey = updatedNode;
    nodes[index] = updatedNode;

    notifyListeners();
  }
}
