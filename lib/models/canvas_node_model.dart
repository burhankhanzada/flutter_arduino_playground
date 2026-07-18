import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/models/breadboard_interaction.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'dart:math' as math;
import 'package:flutter_arduino_playground/ui/components_painters/port_provider.dart';

class CanvasNodeModel {
  CanvasNodeModel({
    required this.position,
    required this.componentModel,
    this.rotationAngle = 0.0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    LocalKey? key,
  }) : key = key ?? UniqueKey();

  Offset position;
  Offset? hoveredLocalPosition;
  BreadboardHoverState? breadboardHover;
  double rotationAngle;
  bool flipHorizontal;
  bool flipVertical;

  List<Offset> _getRotatedCorners() {
    final w = componentModel.size.width;
    final h = componentModel.size.height;
    final c = math.cos(rotationAngle);
    final s = math.sin(rotationAngle);
    
    // Corners relative to topCenter (w/2, 0)
    final points = [
      Offset(-w/2, 0),
      Offset(w/2, 0),
      Offset(-w/2, h),
      Offset(w/2, h),
    ];
    
    return points.map((p) => Offset(
      p.dx * c - p.dy * s,
      p.dx * s + p.dy * c
    )).toList();
  }

  Offset get pivotOffset {
    final corners = _getRotatedCorners();
    final minX = corners.map((p) => p.dx).reduce(math.min);
    final minY = corners.map((p) => p.dy).reduce(math.min);
    return Offset(-minX, -minY);
  }

  Size get currentSize {
    final corners = _getRotatedCorners();
    final minX = corners.map((p) => p.dx).reduce(math.min);
    final maxX = corners.map((p) => p.dx).reduce(math.max);
    final minY = corners.map((p) => p.dy).reduce(math.min);
    final maxY = corners.map((p) => p.dy).reduce(math.max);
    return Size(maxX - minX, maxY - minY);
  }

  ComponentPort? getPortById(String id) {
    final painter = componentModel.painter;
    if (painter is! PortProvider) return null;

    final provider = painter as PortProvider;
    final staticPorts = provider.getPorts();
    for (final p in staticPorts) {
      if (p.id == id) return p;
    }

    return null;
  }

  Offset? getPortOffset(String portId) {
    final painter = componentModel.painter;
    if (painter is PortProvider) {
      final baseOffset = (painter as PortProvider).getPortOffsetById(portId);
      if (baseOffset == null) return null;
      
      final w = componentModel.size.width;
      
      // Calculate rotation center of the unrotated component (topCenter)
      final cx = w / 2;
      final cy = 0.0;
      
      // Apply flip
      var fx = baseOffset.dx;
      var fy = baseOffset.dy;
      if (flipHorizontal) fx = w - fx;
      if (flipVertical) fy = componentModel.size.height - fy;
      
      // Translate to center
      final dx = fx - cx;
      final dy = fy - cy;
      
      // Rotate by angle
      final c = math.cos(rotationAngle);
      final s = math.sin(rotationAngle);
      final rx = dx * c - dy * s;
      final ry = dx * s + dy * c;
      
      // Translate back to the new bounding box's coordinate system
      return pivotOffset + Offset(rx, ry);
    }
    return null;
  }

  final LocalKey key;
  final ComponentModel componentModel;

  Rect get rect => position & currentSize;

  CanvasNodeModel copyWith({
    Offset? position,
    Offset? hoveredLocalPosition,
    BreadboardHoverState? breadboardHover,
    ComponentModel? componentModel,
    double? rotationAngle,
    bool? flipHorizontal,
    bool? flipVertical,
    LocalKey? key,
  }) {
    final newNode = CanvasNodeModel(
      position: position ?? this.position,
      componentModel: componentModel ?? this.componentModel,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      key: key ?? this.key,
    );
    newNode.hoveredLocalPosition =
        hoveredLocalPosition ?? this.hoveredLocalPosition;
    newNode.breadboardHover = breadboardHover ?? this.breadboardHover;
    return newNode;
  }
}
