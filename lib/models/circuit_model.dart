import 'package:flutter/material.dart';

class PartData {
  final String type;
  final String id;
  final double x;
  final double y;
  final Map<String, dynamic>? properties;

  PartData({
    required this.type,
    required this.id,
    required this.x,
    required this.y,
    this.properties,
  });
}

class WireData {
  final String fromId;
  final String fromPort;
  final String toId;
  final String toPort;
  final String color;
  final List<Offset> bendPoints;

  WireData({
    required this.fromId,
    required this.fromPort,
    required this.toId,
    required this.toPort,
    this.color = 'green',
    this.bendPoints = const [],
  });
}

class CircuitData {
  final List<PartData> parts;
  final List<WireData> wires;

  CircuitData({
    required this.parts,
    required this.wires,
  });
}
