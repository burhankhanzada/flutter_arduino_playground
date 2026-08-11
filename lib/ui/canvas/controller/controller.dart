import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/base_controller.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/connection_mixin.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/select_mixin.dart';
import 'package:flutter_arduino_playground/models/wire_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';

class CanvasStateSnapshot {
  final List<CanvasNodeModel> nodes;
  final List<WireModel> wires;
  CanvasStateSnapshot({required this.nodes, required this.wires});
}

class CanvasController extends BaseCanvasController
    with ConnectionMixin, SelectMixin {
  bool get canvasMoveEnabled => !mouseDown && boxSelectionRect == null;

    final List<CanvasStateSnapshot> _undoStack = [];
  final List<CanvasStateSnapshot> _redoStack = [];

  CanvasController({
    List<CanvasNodeModel> nodes = const [],
    List<WireModel> wires = const [],
    bool snapResizeToGrid = false,
  }) {
    if (nodes.isNotEmpty) {
      this.nodes.addAll(nodes);
    }
    if (wires.isNotEmpty) {
      this.wires.addAll(wires);
    }
  }

  void forceUpdate() {
    notifyListeners();
  }

  void saveHistory() {
    _undoStack.add(
      CanvasStateSnapshot(
        nodes: nodes.map((n) => n.copyWith()).toList(),
        wires: wires
            .map((w) => w.copyWith(bendPoints: List.from(w.bendPoints)))
            .toList(),
      ),
    );
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(
      CanvasStateSnapshot(
        nodes: nodes.map((n) => n.copyWith()).toList(),
        wires: wires
            .map((w) => w.copyWith(bendPoints: List.from(w.bendPoints)))
            .toList(),
      ),
    );
    _applySnapshot(_undoStack.removeLast());
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(
      CanvasStateSnapshot(
        nodes: nodes.map((n) => n.copyWith()).toList(),
        wires: wires
            .map((w) => w.copyWith(bendPoints: List.from(w.bendPoints)))
            .toList(),
      ),
    );
    _applySnapshot(_redoStack.removeLast());
  }

  void _applySnapshot(CanvasStateSnapshot snapshot) {
    nodes.clear();
    nodes.addAll(snapshot.nodes.map((n) => n.copyWith()));
    wires.clear();
    wires.addAll(
      snapshot.wires.map(
        (w) => w.copyWith(bendPoints: List.from(w.bendPoints)),
      ),
    );

    selectedNodes.removeWhere((n) => !nodes.any((node) => node.key == n.key));
    for (int i = 0; i < selectedNodes.length; i++) {
      selectedNodes[i] = nodes.firstWhere((n) => n.key == selectedNodes[i].key);
    }

    selectedWireIds.removeWhere((id) => !wires.any((w) => w.id == id));
    notifyListeners();
  }

  void copy() {
    if (selectedNodes.isNotEmpty) {
      clipboardNodes = selectedNodes.map((n) => n.copyWith()).toList();
    }
  }

  void paste() {
    if (clipboardNodes != null && clipboardNodes!.isNotEmpty) {
      saveHistory();
      selectedNodes.clear();
      
      for (final node in clipboardNodes!) {
        final newNode = node.copyWith(
          key: UniqueKey(),
          position: node.position + const Offset(20, 20),
        );
        nodes.add(newNode);
        selectedNodes.add(newNode);
      }
      
      clipboardNodes = clipboardNodes!.map((n) => n.copyWith(
        position: n.position + const Offset(20, 20),
      )).toList();
      
      notifyListeners();
    }
  }

  void add(CanvasNodeModel child) {
    saveHistory();
    nodes.add(child);
    selectedNodes = [child];
    notifyListeners();
  }

  void remove() {
    saveHistory();
    for (final id in selectedWireIds.toList()) {
      removeWire(id);
    }
    selectedWireIds.clear();
    
    if (selectedNodes.isNotEmpty) {
      for (final node in selectedNodes) {
        wires.removeWhere(
          (w) =>
              w.start.nodeKey == node.key ||
              w.end.nodeKey == node.key,
        );
        nodes.removeWhere((n) => n.key == node.key);
      }
      clearSelection();
    }
    notifyListeners();
  }

  void updateNodeProperties(LocalKey key, Map<String, dynamic> newProperties) {
    final index = nodes.indexWhere((n) => n.key == key);
    if (index != -1) {
      saveHistory();
      nodes[index] = nodes[index].copyWith(properties: newProperties);
      
      final selIndex = selectedNodes.indexWhere((n) => n.key == key);
      if (selIndex != -1) {
        selectedNodes[selIndex] = nodes[index];
      }
      notifyListeners();
    }
  }

  void updateNode(LocalKey key, {
    Offset? position,
    double? rotationAngle,
    bool? flipHorizontal,
    bool? flipVertical,
    double? customWidth,
    double? customHeight,
    bool clearCustomWidth = false,
    bool clearCustomHeight = false,
  }) {
    final index = nodes.indexWhere((n) => n.key == key);
    if (index != -1) {
      saveHistory();
      final node = nodes[index];
      final updatedNode = node.copyWith(
        position: position ?? node.position,
        rotationAngle: rotationAngle ?? node.rotationAngle,
        flipHorizontal: flipHorizontal ?? node.flipHorizontal,
        flipVertical: flipVertical ?? node.flipVertical,
        customWidth: customWidth,
        customHeight: customHeight,
        clearCustomWidth: clearCustomWidth,
        clearCustomHeight: clearCustomHeight,
      );
      nodes[index] = updatedNode;
      
      final selIndex = selectedNodes.indexWhere((n) => n.key == key);
      if (selIndex != -1) {
        selectedNodes[selIndex] = nodes[index];
      }
      notifyListeners();
    }
  }

  void fitToContent(Size viewportSize) {
    if (nodes.isEmpty) {
      centerOrigin(viewportSize);
      return;
    }

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    for (final node in nodes) {
      final rect = node.rect;
      if (rect.left < minX) minX = rect.left;
      if (rect.top < minY) minY = rect.top;
      if (rect.right > maxX) maxX = rect.right;
      if (rect.bottom > maxY) maxY = rect.bottom;
    }

    final contentWidth = maxX - minX;
    final contentHeight = maxY - minY;
    final contentCenterX = minX + contentWidth / 2;
    final contentCenterY = minY + contentHeight / 2;

    // Calculate scale to fit (with 100px padding)
    final padding = 100.0;
    double scaleX = viewportSize.width / (contentWidth + padding);
    double scaleY = viewportSize.height / (contentHeight + padding);

    // Fallback if width/height is 0
    if (!scaleX.isFinite) scaleX = 1.0;
    if (!scaleY.isFinite) scaleY = 1.0;

    double targetScale = min(scaleX, scaleY).clamp(minScale, maxScale);

    final matrix = Matrix4.identity()
      ..translateByDouble(
        viewportSize.width / 2,
        viewportSize.height / 2,
        0.0,
        1.0,
      )
      ..scaleByDouble(targetScale, targetScale, 1.0, 1.0)
      ..translateByDouble(-contentCenterX, -contentCenterY, 0.0, 1.0);

    viewerController.value = matrix;
  }

  @override
  void completeWiring(PortLocation endPort) {
    if (startPort != null && startPort != endPort) {
      saveHistory();
    }
    super.completeWiring(endPort);
  }

  @override
  void createBendPointAt(Offset canvasPosition) {
    saveHistory();
    super.createBendPointAt(canvasPosition);
  }

  @override
  void updateWireColor(Color? newColor) {
    if (newColor != null && selectedWireIds.isNotEmpty) {
      for (final id in selectedWireIds) {
        final wireIndex = wires.indexWhere((w) => w.id == id);
        if (wireIndex != -1) {
          final wire = wires[wireIndex];
          wires[wireIndex] = wire.copyWith(color: newColor);
        }
      }
      return;
    }
    super.updateWireColor(newColor);
  }

  void rotateRight() {
    if (selectedNodes.isEmpty) return;
    saveHistory();
    for (int i = 0; i < selectedNodes.length; i++) {
      final oldNode = selectedNodes[i];
      final index = nodes.indexOf(oldNode);
      if (index == -1) continue;

      final oldPivotCanvas = oldNode.position + oldNode.pivotOffset;
      final updatedNode = oldNode.copyWith(
        rotationAngle: oldNode.rotationAngle + (pi / 18),
      );
      final newPosition = oldPivotCanvas - updatedNode.pivotOffset;
      final finalNode = updatedNode.copyWith(position: newPosition);

      selectedNodes[i] = finalNode;
      nodes[index] = finalNode;
      _updateConnectedWires(finalNode.key);
    }
    notifyListeners();
  }

  void rotateLeft() {
    if (selectedNodes.isEmpty) return;
    saveHistory();
    for (int i = 0; i < selectedNodes.length; i++) {
      final oldNode = selectedNodes[i];
      final index = nodes.indexOf(oldNode);
      if (index == -1) continue;

      final oldPivotCanvas = oldNode.position + oldNode.pivotOffset;
      final updatedNode = oldNode.copyWith(
        rotationAngle: oldNode.rotationAngle - (pi / 18),
      );
      final newPosition = oldPivotCanvas - updatedNode.pivotOffset;
      final finalNode = updatedNode.copyWith(position: newPosition);

      selectedNodes[i] = finalNode;
      nodes[index] = finalNode;
      _updateConnectedWires(finalNode.key);
    }
    notifyListeners();
  }

  void flipHorizontal() {
    if (selectedNodes.isEmpty) return;
    saveHistory();
    for (int i = 0; i < selectedNodes.length; i++) {
      final oldNode = selectedNodes[i];
      final index = nodes.indexOf(oldNode);
      if (index == -1) continue;

      final updatedNode = oldNode.copyWith(
        flipHorizontal: !oldNode.flipHorizontal,
      );
      selectedNodes[i] = updatedNode;
      nodes[index] = updatedNode;
      _updateConnectedWires(updatedNode.key);
    }
    notifyListeners();
  }

  void flipVertical() {
    if (selectedNodes.isEmpty) return;
    saveHistory();
    for (int i = 0; i < selectedNodes.length; i++) {
      final oldNode = selectedNodes[i];
      final index = nodes.indexOf(oldNode);
      if (index == -1) continue;

      final updatedNode = oldNode.copyWith(
        flipVertical: !oldNode.flipVertical,
      );
      selectedNodes[i] = updatedNode;
      nodes[index] = updatedNode;
      _updateConnectedWires(updatedNode.key);
    }
    notifyListeners();
  }

  void layerUp() {
    if (selectedNodes.isEmpty) return;
    saveHistory();
    // Sort selected nodes by index descending so we don't mess up order
    var sorted = List<CanvasNodeModel>.from(selectedNodes)..sort((a, b) => nodes.indexOf(b).compareTo(nodes.indexOf(a)));
    for (final oldNode in sorted) {
      final index = nodes.indexOf(oldNode);
      if (index == -1 || index == nodes.length - 1) continue;
      final node = nodes.removeAt(index);
      nodes.insert(index + 1, node);
    }
    notifyListeners();
  }

  void layerDown() {
    if (selectedNodes.isEmpty) return;
    saveHistory();
    // Sort selected nodes by index ascending
    var sorted = List<CanvasNodeModel>.from(selectedNodes)..sort((a, b) => nodes.indexOf(a).compareTo(nodes.indexOf(b)));
    for (final oldNode in sorted) {
      final index = nodes.indexOf(oldNode);
      if (index == -1 || index == 0) continue;
      final node = nodes.removeAt(index);
      nodes.insert(index - 1, node);
    }
    notifyListeners();
  }

  Offset? _boxSelectionStart;

  void startBoxSelection(Offset canvasPos) {
    _boxSelectionStart = canvasPos;
    boxSelectionRect = Rect.fromPoints(canvasPos, canvasPos);
    clearSelection();
  }

  void updateBoxSelection(Offset canvasPos) {
    if (_boxSelectionStart != null) {
      boxSelectionRect = Rect.fromPoints(_boxSelectionStart!, canvasPos);
      
      selectedNodes.clear();
      for (final node in nodes) {
        if (boxSelectionRect!.overlaps(node.rect)) {
          selectedNodes.add(node);
        }
      }

      selectedWireIds.clear();
      for (final wire in wires) {
        if (_wireOverlapsRect(wire, boxSelectionRect!)) {
          selectedWireIds.add(wire.id);
        }
      }

      notifyListeners();
    }
  }

  bool _wireOverlapsRect(WireModel wire, Rect rect) {
    final startPos = getPortPosition(wire.start);
    final endPos = getPortPosition(wire.end);
    if (startPos == null || endPos == null) return false;

    final List<Offset> points = [startPos, ...wire.bendPoints, endPos];
    for (int i = 0; i < points.length - 1; i++) {
      if (rect.overlaps(Rect.fromPoints(points[i], points[i + 1]))) {
        return true;
      }
    }
    return false;
  }

  void endBoxSelection() {
    boxSelectionRect = null;
    _boxSelectionStart = null;
    notifyListeners();
  }


  void _updateConnectedWires(Key nodeKey) {
    // When a node rotates, its ports move. Wires will naturally follow the new port positions
    // on next paint because wire start/end are PortLocations, which look up the current getPortOffset.
    // However, if we cache bend points, we might need to adjust them?
    // For now, simple rotation just updates the node. The WirePainter will fetch the new
    // rotated port offset automatically during paint.
  }
}
