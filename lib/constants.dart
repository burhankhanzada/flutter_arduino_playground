import 'dart:ui';

import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/ui/components_painters/arduino_painter.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/breadebord_painter.dart';
import 'package:flutter_arduino_playground/ui/components_painters/breadbord_painter/configs/breadboard_config.dart';
import 'package:flutter_arduino_playground/ui/components_painters/push_button_painter.dart';
import 'package:flutter_arduino_playground/ui/components_painters/led_painter.dart';
import 'package:flutter_arduino_playground/ui/components_painters/resistor_painter.dart';

final breadboardPainterHalf = BreadboardPainter(
  config: BreadboardConfig.half(),
);
final breadboardPainterFull = BreadboardPainter(
  config: BreadboardConfig.full(),
);

final List<ComponentModel> components = [
  ComponentModel(
    name: 'LED',
    size: LEDPainter.componentSize,
    painter: LEDPainter(),
  ),
  ComponentModel(
    name: 'Button',
    size: PushButtonPainter.componentSize,
    painter: PushButtonPainter(),
  ),
  ComponentModel(
    name: 'Resistor',
    size: ResistorPainter.componentSize,
    painter: ResistorPainter(),
  ),
  ComponentModel(
    name: 'Breadboard Half',
    size: breadboardPainterHalf.config.boardSize,
    painter: breadboardPainterHalf,
  ),
  // ComponentModel(
  //   name: 'Breadboard Full',
  //   size: breadboardPainterFull.config.boardSize,
  //   painter: breadboardPainterFull,
  // ),
  ComponentModel(
    name: 'Arduino Uno',
    size: Size(370, 290),
    painter: ArduinoPainter(),
  ),
];
