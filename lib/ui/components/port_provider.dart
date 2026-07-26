import 'dart:ui';

import 'package:flutter_arduino_playground/models/port_model.dart';

mixin PortProvider {
  List<ComponentPort> getPorts();

  ComponentPort? getPortAt(Offset localOffset) {
    for (final port in getPorts()) {
      if ((port.localOffset - localOffset).distance < 15.0) {
        return port;
      }
    }
    return null;
  }

  Offset? getPortOffsetById(String id) {
    for (final port in getPorts()) {
      if (port.id == id) return port.localOffset;
    }
    return null;
  }
}
