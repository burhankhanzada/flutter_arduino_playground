import 'package:flutter/material.dart';

class ComponentModel {
  final String name;
  final Size size;
  final CustomPainter Function() painterBuilder;

  CustomPainter? _cachedPainter;
  CustomPainter get painter => _cachedPainter ??= painterBuilder();

  ComponentModel({
    required this.name,
    required this.size,
    required this.painterBuilder,
  });

  ComponentModel clone() {
    return ComponentModel(
      name: name,
      size: size,
      painterBuilder: painterBuilder,
    );
  }
}
