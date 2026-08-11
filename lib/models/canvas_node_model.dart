import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/models/breadboard_interaction.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/ui/components/port_provider.dart';

class CanvasNodeModel {
  CanvasNodeModel({
    required this.position,
    required this.componentModel,
    this.rotationAngle = 0.0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.customWidth,
    this.customHeight,
    Map<String, dynamic>? properties,
    LocalKey? key,
  }) : key = key ?? UniqueKey(),
       properties = properties ?? _getDefaultProperties(componentModel.name);

  static Map<String, dynamic> _getDefaultProperties(String componentName) {
    if (componentName.toLowerCase().contains('led')) {
      return {'Color': 'Red'};
    } else if (componentName.toLowerCase().contains('resistor')) {
      return {'Resistance': '220 Ω'};
    }
    return {};
  }

  Offset position;
  Map<String, dynamic> properties;
  Offset? hoveredLocalPosition;
  BreadboardHoverState? breadboardHover;
  double rotationAngle;
  bool flipHorizontal;
  bool flipVertical;
  double? customWidth;
  double? customHeight;

  Size get baseSize => Size(
    customWidth ?? componentModel.size.width,
    customHeight ?? componentModel.size.height,
  );

  List<Offset> _getRotatedCorners() {
    final w = baseSize.width;
    final h = baseSize.height;
    final c = math.cos(rotationAngle);
    final s = math.sin(rotationAngle);

    // Corners relative to topCenter (w/2, 0)
    final points = [
      Offset(-w / 2, 0),
      Offset(w / 2, 0),
      Offset(-w / 2, h),
      Offset(w / 2, h),
    ];

    return points
        .map((p) => Offset(p.dx * c - p.dy * s, p.dx * s + p.dy * c))
        .toList();
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
    Offset? baseOffset;

    final painter = componentModel.painter;
    if (painter is PortProvider) {
      baseOffset = (painter as PortProvider).getPortOffsetById(portId);
    }

    if (baseOffset != null) {
      // Calculate scaling factors for the ports if size changed
      final scaleX = baseSize.width / componentModel.size.width;
      final scaleY = baseSize.height / componentModel.size.height;

      var scaledOffset = Offset(baseOffset.dx * scaleX, baseOffset.dy * scaleY);

      final w = baseSize.width;

      // Calculate rotation center of the unrotated component (topCenter)
      final cx = w / 2;
      final cy = 0.0;

      // Apply flip
      var fx = scaledOffset.dx;
      var fy = scaledOffset.dy;
      if (flipHorizontal) fx = w - fx;
      if (flipVertical) fy = baseSize.height - fy;

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
    double? customWidth,
    double? customHeight,
    bool clearCustomWidth = false,
    bool clearCustomHeight = false,
    Map<String, dynamic>? properties,
    LocalKey? key,
  }) {
    final newNode = CanvasNodeModel(
      position: position ?? this.position,
      componentModel: componentModel ?? this.componentModel,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      customWidth: clearCustomWidth ? null : (customWidth ?? this.customWidth),
      customHeight: clearCustomHeight
          ? null
          : (customHeight ?? this.customHeight),
      properties: properties ?? Map.from(this.properties),
      key: key ?? this.key,
    );
    newNode.hoveredLocalPosition =
        hoveredLocalPosition ?? this.hoveredLocalPosition;
    newNode.breadboardHover = breadboardHover ?? this.breadboardHover;
    return newNode;
  }
}
