import 'dart:ui';

import 'package:flutter_arduino_playground/ui/canvas/controller/base_controller.dart';

mixin PanMixin on BaseCanvasController {
  void panUp() => pan(const Offset(0, 10));
  void panDown() => pan(const Offset(0, -10));
  void panLeft() => pan(const Offset(10, 0));
  void panRight() => pan(const Offset(-10, 0));

  void pan(Offset delta) {
    offset += delta;
  }
}
