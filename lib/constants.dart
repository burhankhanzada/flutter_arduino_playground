import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/ui/components/arduino_painter.dart';
import 'package:flutter_arduino_playground/ui/components/breadbord_painter/breadebord_painter.dart';
import 'package:flutter_arduino_playground/ui/components/breadbord_painter/configs/breadboard_config.dart';
import 'package:flutter_arduino_playground/ui/components/push_button_painter.dart';
import 'package:flutter_arduino_playground/ui/components/led_painter.dart';
import 'package:flutter_arduino_playground/ui/components/resistor_painter.dart';

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
    painterBuilder: () => LEDPainter(),
  ),
  ComponentModel(
    name: 'Button',
    size: PushButtonPainter.componentSize,
    painterBuilder: () => PushButtonPainter(),
  ),
  ComponentModel(
    name: 'Resistor',
    size: ResistorPainter.componentSize,
    painterBuilder: () => ResistorPainter(),
  ),
  ComponentModel(
    name: 'Breadboard Half',
    size: breadboardPainterHalf.config.boardSize,
    painterBuilder: () => BreadboardPainter(config: BreadboardConfig.half()),
  ),
  // ComponentModel(
  //   name: 'Breadboard Full',
  //   size: breadboardPainterFull.config.boardSize,
  //   painterBuilder: () => BreadboardPainter(config: BreadboardConfig.full()),
  // ),
  ComponentModel(
    name: 'Arduino Uno',
    size: ArduinoPainter.componentSize,
    painterBuilder: () => ArduinoPainter(),
  ),
];
