import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/base_controller.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/pan_mixin.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/breadebord_painter.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/logic/breadboard_hit_tester.dart';
import 'package:flutter_arduino_playground/ui/components_painters/port_provider.dart';

mixin SelectMixin on BaseCanvasController {
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
    CanvasNodeModel? found;

    // Convert screen coordinates to canvas coordinates
    final canvasPosition = screenToCanvasCoordinates(mouseLocalPosition);

    // Find the topmost node at this position
    for (final node in nodes.reversed) {
      if (node.rect.contains(canvasPosition)) {
        found = node;
        break;
      }
    }

    bool changed = false;

    // Clear hover position for previous node if it changed
    if (hoveredNodeKey != found) {
      hoveredNodeKey?.hoveredLocalPosition = null;
      hoveredNodeKey?.breadboardHover = null;
      hoveredNodeKey = found;
      hoveredPort = null;
      changed = true;
    }

    // Update hover position and port for current node
    if (found != null) {
      final localPos = canvasPosition - found.position;

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
    }

    if (changed) {
      notifyListeners();
    }
  }

  void checkSelection() {
    CanvasNodeModel? found;

    // Convert screen coordinates to canvas coordinates
    final canvasPosition = screenToCanvasCoordinates(mouseLocalPosition);

    // Find the topmost node at this position
    for (final node in nodes.reversed) {
      if (node.rect.contains(canvasPosition)) {
        found = node;
        break;
      }
    }

    if (found == null) {
      clearSelection();
      return;
    }

    // Calculate the offset from the node's top-left corner to the click point
    dragStartOffset = canvasPosition - found.position;

    if (selectedNodeKey != found) {
      selectedNodeKey = found;
      notifyListeners();
    }
  }

  void moveSelection(Offset delta) {
    if (selectedNodeKey == null) {
      if (this is PanMixin) {
        (this as PanMixin).pan(delta);
      }
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

  Offset screenToCanvasCoordinates(Offset screenPosition) {
    return (screenPosition - offset) / scale;
  }

  Offset canvasToScreenCoordinates(Offset canvasPosition) {
    return (canvasPosition * scale) + offset;
  }
}
