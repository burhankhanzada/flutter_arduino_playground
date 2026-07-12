import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/models/wire_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/base_controller.dart';

mixin ConnectionMixin on BaseCanvasController {
  final List<WireModel> wires = [];
  
  // Transient state for the wire being dragged
  PortLocation? startPort;
  Offset? currentDragPosition;
  Color currentWireColor = Colors.yellow;

  bool get isWiring => startPort != null;

  void startWiring(PortLocation port, Offset initialPosition) {
    startPort = port;
    currentDragPosition = initialPosition;
    notifyListeners();
  }

  void updateWiring(Offset position) {
    if (startPort == null) return;
    currentDragPosition = position;
    notifyListeners();
  }

  void completeWiring(PortLocation endPort) {
    if (startPort == null) return;
    
    // Check if connection already exists or is to the same port
    if (startPort == endPort) {
      cancelWiring();
      return;
    }

    final newWire = WireModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      start: startPort!,
      end: endPort,
      color: currentWireColor,
    );

    wires.add(newWire);
    cancelWiring();
  }

  void cancelWiring() {
    startPort = null;
    currentDragPosition = null;
    notifyListeners();
  }

  void removeWire(String id) {
    wires.removeWhere((w) => w.id == id);
    notifyListeners();
  }
}
