import 'package:flutter/material.dart';

enum PortType { input, output, biDirectional }

class ComponentPort {
  final String id;
  final String name;
  final Offset localOffset; // Relative to component origin
  final PortType type;

  const ComponentPort({
    required this.id,
    required this.name,
    required this.localOffset,
    this.type = PortType.biDirectional,
  });
}

class PortLocation {
  final Key nodeKey;
  final String portId;

  const PortLocation({required this.nodeKey, required this.portId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortLocation &&
          runtimeType == other.runtimeType &&
          nodeKey == other.nodeKey &&
          portId == other.portId;

  @override
  int get hashCode => nodeKey.hashCode ^ portId.hashCode;

  @override
  String toString() => 'PortLocation(node: $nodeKey, port: $portId)';
}
