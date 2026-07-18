import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';

class WireModel {
  final String id;
  final PortLocation start;
  final PortLocation end;
  final List<Offset> bendPoints;
  final Color color;

  WireModel({
    required this.id,
    required this.start,
    required this.end,
    this.bendPoints = const [],
    this.color = Colors.green,
  });

  WireModel copyWith({
    String? id,
    PortLocation? start,
    PortLocation? end,
    List<Offset>? bendPoints,
    Color? color,
  }) {
    return WireModel(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      bendPoints: bendPoints ?? this.bendPoints,
      color: color ?? this.color,
    );
  }
}
