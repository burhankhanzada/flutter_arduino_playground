import 'dart:ui';

import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/ui/components_painters/button_painter.dart';
import 'package:flutter_arduino_playground/ui/components_painters/led_painter.dart';
import 'package:flutter_arduino_playground/ui/components_painters/resistor_painter.dart';

final List<ComponentModel> components = [
  ComponentModel(name: 'LED', size: Size(30, 50), painter: LEDPainter()),
  ComponentModel(name: 'Button', size: Size(30, 50), painter: ButtonPainter()),
  ComponentModel(
    name: 'Resistor',
    size: Size(50, 15),
    painter: ResistorPainter(),
  ),
];
