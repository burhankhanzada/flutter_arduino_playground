import 'package:flutter/material.dart';

class ComponentModel {
  final String name;
  final Size size;
  final CustomPainter painter;

  ComponentModel({
    required this.name,
    required this.size,
    required this.painter,
  });
}
