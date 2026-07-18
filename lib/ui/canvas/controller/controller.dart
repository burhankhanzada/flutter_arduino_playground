import 'package:flutter/foundation.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/base_controller.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/connection_mixin.dart';
import 'dart:math' as math;
import 'package:flutter_arduino_playground/ui/canvas/controller/select_mixin.dart';
import 'package:flutter_arduino_playground/models/wire_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';

class CanvasStateSnapshot {
  final List<CanvasNodeModel> nodes;
  final List<WireModel> wires;
  CanvasStateSnapshot({required this.nodes, required this.wires});
}

class CanvasController extends BaseCanvasController
    with ConnectionMixin, SelectMixin {
  bool get canvasMoveEnabled => !mouseDown;

  CanvasNodeModel? _clipboardNode;
  final List<CanvasStateSnapshot> _undoStack = [];
  final List<CanvasStateSnapshot> _redoStack = [];

  CanvasController({
    List<CanvasNodeModel> nodes = const [],
    bool snapResizeToGrid = false,
  }) {
    if (nodes.isNotEmpty) {
      this.nodes.addAll(nodes);
    }
  }

  void saveHistory() {
    _undoStack.add(CanvasStateSnapshot(
      nodes: nodes.map((n) => n.copyWith()).toList(),
      wires: wires.map((w) => w.copyWith(bendPoints: List.from(w.bendPoints))).toList(),
    ));
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(CanvasStateSnapshot(
      nodes: nodes.map((n) => n.copyWith()).toList(),
      wires: wires.map((w) => w.copyWith(bendPoints: List.from(w.bendPoints))).toList(),
    ));
    _applySnapshot(_undoStack.removeLast());
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(CanvasStateSnapshot(
      nodes: nodes.map((n) => n.copyWith()).toList(),
      wires: wires.map((w) => w.copyWith(bendPoints: List.from(w.bendPoints))).toList(),
    ));
    _applySnapshot(_redoStack.removeLast());
  }

  void _applySnapshot(CanvasStateSnapshot snapshot) {
    nodes.clear();
    nodes.addAll(snapshot.nodes.map((n) => n.copyWith()));
    wires.clear();
    wires.addAll(snapshot.wires.map((w) => w.copyWith(bendPoints: List.from(w.bendPoints))));
    
    if (selectedNodeKey != null && !nodes.any((n) => n.key == selectedNodeKey!.key)) {
      selectedNodeKey = null;
    } else if (selectedNodeKey != null) {
      selectedNodeKey = nodes.firstWhere((n) => n.key == selectedNodeKey!.key);
    }
    
    if (selectedWireId != null && !wires.any((w) => w.id == selectedWireId)) {
      selectedWireId = null;
    }
    notifyListeners();
  }

  void copy() {
    if (selectedNodeKey != null) {
      _clipboardNode = selectedNodeKey!.copyWith();
    }
  }

  void paste() {
    if (_clipboardNode != null) {
      saveHistory();
      final newNode = _clipboardNode!.copyWith(
        key: UniqueKey(),
        position: _clipboardNode!.position + const Offset(20, 20),
      );
      nodes.add(newNode);
      selectedNodeKey = newNode;
      notifyListeners();
    }
  }

  void add(CanvasNodeModel child) {
    saveHistory();
    nodes.add(child);
    selectedNodeKey = child;
    notifyListeners();
  }

  void remove() {
    saveHistory();
    if (selectedWireId != null) {
      removeWire(selectedWireId!);
    } else if (selectedNodeKey != null) {
      // Remove any wires connected to this node
      wires.removeWhere((w) => 
          w.start.nodeKey == selectedNodeKey!.key || 
          w.end.nodeKey == selectedNodeKey!.key);
      
      nodes.removeWhere((node) => node.key == selectedNodeKey!.key);
      clearSelection();
    }
    notifyListeners();
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
    if (selectedWireId != null) {
      saveHistory();
    }
    super.createBendPointAt(canvasPosition);
  }

  @override
  void updateWireColor(Color? newColor) {
    if (newColor != null && selectedWireId != null) {
      saveHistory();
    }
    super.updateWireColor(newColor);
  }

  void rotateRight() {
    if (selectedNodeKey == null) return;
    final index = nodes.indexOf(selectedNodeKey!);
    if (index == -1) return;

    saveHistory();

    final oldNode = selectedNodeKey!;
    final oldPivotCanvas = oldNode.position + oldNode.pivotOffset;

    final updatedNode = oldNode.copyWith(
      rotationAngle: oldNode.rotationAngle + (math.pi / 18),
    );
    
    final newPosition = oldPivotCanvas - updatedNode.pivotOffset;
    final finalNode = updatedNode.copyWith(position: newPosition);

    selectedNodeKey = finalNode;
    nodes[index] = finalNode;
    _updateConnectedWires(finalNode.key);
    notifyListeners();
  }

  void rotateLeft() {
    if (selectedNodeKey == null) return;
    final index = nodes.indexOf(selectedNodeKey!);
    if (index == -1) return;

    saveHistory();

    final oldNode = selectedNodeKey!;
    final oldPivotCanvas = oldNode.position + oldNode.pivotOffset;

    final updatedNode = oldNode.copyWith(
      rotationAngle: oldNode.rotationAngle - (math.pi / 18),
    );
    
    final newPosition = oldPivotCanvas - updatedNode.pivotOffset;
    final finalNode = updatedNode.copyWith(position: newPosition);

    selectedNodeKey = finalNode;
    nodes[index] = finalNode;
    _updateConnectedWires(finalNode.key);
    notifyListeners();
  }

  void flipHorizontal() {
    if (selectedNodeKey == null) return;
    final index = nodes.indexOf(selectedNodeKey!);
    if (index == -1) return;

    saveHistory();

    final updatedNode = selectedNodeKey!.copyWith(
      flipHorizontal: !selectedNodeKey!.flipHorizontal,
    );
    selectedNodeKey = updatedNode;
    nodes[index] = updatedNode;
    _updateConnectedWires(updatedNode.key);
    notifyListeners();
  }

  void flipVertical() {
    if (selectedNodeKey == null) return;
    final index = nodes.indexOf(selectedNodeKey!);
    if (index == -1) return;

    saveHistory();

    final updatedNode = selectedNodeKey!.copyWith(
      flipVertical: !selectedNodeKey!.flipVertical,
    );
    selectedNodeKey = updatedNode;
    nodes[index] = updatedNode;
    _updateConnectedWires(updatedNode.key);
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
