import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/models/breadboard_interaction.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/ui/components_painters/port_provider.dart';

class CanvasNodeModel {
  CanvasNodeModel({
    required this.position,
    required this.componentModel,
    LocalKey? key,
  }) : key = key ?? UniqueKey();

  Offset position;
  Offset? hoveredLocalPosition;
  BreadboardHoverState? breadboardHover;

  ComponentPort? getPortById(String id) {
    final painter = componentModel.painter;
    if (painter is! PortProvider) return null;

    final provider = painter as PortProvider;
    // For breadboard, we might need to recreate the port from ID if it's dynamic
    // But for now, let's see if we can just use getPorts() or a specialized hit test
    final staticPorts = provider.getPorts();
    for (final p in staticPorts) {
      if (p.id == id) return p;
    }

    // Dynamic ports (Breadboard)
    // The ID format is 'rail_side_channel_row' or 'sig_side_col_row'
    // We can parse it and find the offset.
    // However, I'll just try to use getPortAt with the calculated offset? No, that's circular.
    return null;
  }

  Offset? getPortOffset(String portId) {
    final painter = componentModel.painter;
    if (painter is PortProvider) {
      return (painter as PortProvider).getPortOffsetById(portId);
    }
    return null;
  }

  final LocalKey key;
  final ComponentModel componentModel;

  Rect get rect => position & componentModel.size;

  CanvasNodeModel copyWith({
    Offset? position,
    Offset? hoveredLocalPosition,
    BreadboardHoverState? breadboardHover,
    ComponentModel? componentModel,
  }) {
    final newNode = CanvasNodeModel(
      position: position ?? this.position,
      componentModel: componentModel ?? this.componentModel,
      key: key,
    );
    newNode.hoveredLocalPosition =
        hoveredLocalPosition ?? this.hoveredLocalPosition;
    newNode.breadboardHover = breadboardHover ?? this.breadboardHover;
    return newNode;
  }
}
