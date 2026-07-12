import 'dart:ui';

import 'package:flutter_arduino_playground/models/port_model.dart';

abstract interface class PortProvider {
  List<ComponentPort> getPorts();
  ComponentPort? getPortAt(Offset localOffset);
  Offset? getPortOffsetById(String id);
}
