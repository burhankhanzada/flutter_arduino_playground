import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';

class ComponentWidget extends StatelessWidget {
  final ComponentModel componentModel;

  const ComponentWidget({super.key, required this.componentModel});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: componentModel.size,
      painter: componentModel.painter,
    );
  }
}
