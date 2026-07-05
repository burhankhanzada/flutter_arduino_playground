import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/base_controller.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/pan_mixin.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';

mixin SelectMixin on BaseCanvasController {
  CanvasNodeModel? selectedNodeKey;

  bool isSelected(Key key) {
    return selectedNodeKey != null && selectedNodeKey!.key == key;
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

    if (selectedNodeKey != found) {
      selectedNodeKey = found;
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
