import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/models/wire_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/base_controller.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/routing_utils.dart';

mixin ConnectionMixin on BaseCanvasController {
  final List<WireModel> wires = [];
  
  // Transient state for the wire being dragged
  PortLocation? startPort;
  Offset? currentDragPosition;
  Color? currentWireColor; // null means Auto
  Color? activeDragColor; // Holds the assigned random or current color during dragging

  // Interaction state
  String? hoveredWireId;
  String? selectedWireId;

  void updateWireColor(Color? newColor) {
    currentWireColor = newColor;
    if (newColor != null && selectedWireId != null) {
       final wireIndex = wires.indexWhere((w) => w.id == selectedWireId);
       if (wireIndex != -1) {
         final wire = wires[wireIndex];
         wires[wireIndex] = wire.copyWith(color: newColor);
       }
    }
    notifyListeners();
  }

  Color _getRandomColor() {
    final availableColors = [
      Colors.black, Colors.red, Colors.orange, Colors.amber, Colors.yellow,
      Colors.lime, Colors.green, Colors.teal, Colors.cyan, Colors.blue,
      Colors.indigo, Colors.purple, Colors.pink, Colors.brown, Colors.grey, Colors.white,
    ];
    return availableColors[Random().nextInt(availableColors.length)];
  }
  
  // State for dragging a bend point or segment
  String? draggingWireId;
  int? draggingBendPointIndex;
  int? draggingSegmentIndex; // Index in the full points list (including ports)
  bool isDraggingSegment = false;

  bool get isWiring => startPort != null;
  bool get isDraggingBendPoint => draggingWireId != null && (draggingBendPointIndex != null || isDraggingSegment);

  void startWiring(PortLocation port, Offset initialPosition) {
    selectedWireId = null;
    startPort = port;
    currentDragPosition = initialPosition;
    activeDragColor = currentWireColor ?? _getRandomColor();
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
      bendPoints: [], // New wires start as straight lines
      color: activeDragColor ?? Colors.yellow,
    );

    wires.add(newWire);
    cancelWiring();
  }

  void cancelWiring() {
    startPort = null;
    currentDragPosition = null;
    activeDragColor = null;
    notifyListeners();
  }

  void removeWire(String id) {
    wires.removeWhere((w) => w.id == id);
    if (selectedWireId == id) selectedWireId = null;
    if (hoveredWireId == id) hoveredWireId = null;
    notifyListeners();
  }

  void selectWire(String? id) {
    if (selectedWireId == id) return;
    selectedWireId = id;
    notifyListeners();
  }

  bool checkWireInteraction(Offset canvasPosition) {
    if (isWiring) return false;

    // 1. Check handles first (priority)
    for (final wire in wires) {
      if (wire.id == selectedWireId) {
        for (int i = 0; i < wire.bendPoints.length; i++) {
          if ((canvasPosition - wire.bendPoints[i]).distance < 15.0) {
            if (hoveredWireId != wire.id) {
              hoveredWireId = wire.id;
              notifyListeners();
            }
            return true;
          }
        }
      }
    }

    // 2. Check segments
    for (final wire in wires) {
      if (_isPointNearWire(canvasPosition, wire)) {
        if (hoveredWireId != wire.id) {
          hoveredWireId = wire.id;
          notifyListeners();
        }
        return true;
      }
    }

    if (hoveredWireId != null) {
      hoveredWireId = null;
      notifyListeners();
    }
    return false;
  }

  bool _isPointNearWire(Offset p, WireModel wire) {
    final startPos = getPortPosition(wire.start);
    final endPos = getPortPosition(wire.end);
    if (startPos == null || endPos == null) return false;

    final List<Offset> points = [startPos, ...wire.bendPoints, endPos];
    for (int i = 0; i < points.length - 1; i++) {
      if (_distanceToSegment(p, points[i], points[i + 1]) < 12.0) {
        return true;
      }
    }
    return false;
  }

  double _distanceToSegment(Offset p, Offset a, Offset b) {
    final double l2 = (a - b).distanceSquared;
    if (l2 == 0.0) return (p - a).distance;
    final double t = (((p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy)) / l2).clamp(0.0, 1.0);
    final Offset projection = a + (b - a) * t;
    return (p - projection).distance;
  }

  Offset? getPortPosition(PortLocation loc) {
    try {
      final node = nodes.firstWhere((n) => n.key == loc.nodeKey);
      final localOffset = node.getPortOffset(loc.portId);
      if (localOffset == null) return null;
      return node.position + localOffset;
    } catch (_) {
      return null;
    }
  }

  void startDraggingBendPoint(Offset canvasPosition) {
    if (selectedWireId == null) return;
    
    final wire = wires.firstWhere((w) => w.id == selectedWireId);
    
    // Grab existing handle (start and end points are handled by components, not by bend point dragging)
    for (int i = 0; i < wire.bendPoints.length; i++) {
      if ((canvasPosition - wire.bendPoints[i]).distance < 15.0) {
        draggingWireId = wire.id;
        draggingBendPointIndex = i;
        isDraggingSegment = false;
        notifyListeners();
        return;
      }
    }
  }

  void createBendPointAt(Offset canvasPosition) {
    if (selectedWireId == null) return;
    final wire = wires.firstWhere((w) => w.id == selectedWireId);
    
    final startPos = getPortPosition(wire.start);
    final endPos = getPortPosition(wire.end);
    if (startPos == null || endPos == null) return;

    final List<Offset> points = [startPos, ...wire.bendPoints, endPos];
    for (int i = 0; i < points.length - 1; i++) {
      if (_distanceToSegment(canvasPosition, points[i], points[i + 1]) < 12.0) {
        final newPoint = snapToGrid ? GridSystem.snapToCenterOffset(canvasPosition) : canvasPosition;
        final List<Offset> newBendPoints = List<Offset>.from(wire.bendPoints);
        newBendPoints.insert(i, newPoint);
        wires[wires.indexOf(wire)] = wire.copyWith(bendPoints: newBendPoints);
        
        draggingWireId = wire.id;
        draggingBendPointIndex = i;
        isDraggingSegment = false;
        notifyListeners();
        return;
      }
    }
  }

  void updateDraggingBendPoint(Offset canvasPosition) {
    if (draggingWireId == null || draggingBendPointIndex == null) return;
    
    final wireIndex = wires.indexWhere((w) => w.id == draggingWireId);
    if (wireIndex == -1) return;
    
    final wire = wires[wireIndex];
    final startPos = getPortPosition(wire.start);
    final endPos = getPortPosition(wire.end);
    if (startPos == null || endPos == null) return;

    Offset newPoint = snapToGrid ? GridSystem.snapToCenterOffset(canvasPosition) : canvasPosition;
    
    // Freeform handle drag: just move the point
    final List<Offset> points = List<Offset>.from(wire.bendPoints);
    points[draggingBendPointIndex!] = newPoint;
    wires[wireIndex] = wire.copyWith(bendPoints: points);
    
    notifyListeners();
  }

  void stopDraggingBendPoint() {
    if (draggingWireId != null) {
      final wireIndex = wires.indexWhere((w) => w.id == draggingWireId);
      if (wireIndex != -1) {
        final wire = wires[wireIndex];
        final startPos = getPortPosition(wire.start);
        final endPos = getPortPosition(wire.end);
        
        if (startPos != null && endPos != null) {
          // Manual cleanup: only simplify (remove redundant collinear/same points)
          final List<Offset> allPoints = [startPos, ...wire.bendPoints, endPos];
          final simplifiedPoints = RoutingUtils.simplify(allPoints);
          if (simplifiedPoints.length >= 2) {
            final updatedBendPoints = simplifiedPoints.sublist(1, simplifiedPoints.length - 1);
            wires[wireIndex] = wire.copyWith(bendPoints: updatedBendPoints);
          }
        }
      }
    }

    draggingWireId = null;
    draggingBendPointIndex = null;
    draggingSegmentIndex = null;
    isDraggingSegment = false;
    notifyListeners();
  }
}
