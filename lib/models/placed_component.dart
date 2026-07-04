import 'dart:ui';

import 'package:flutter_arduino_playground/models/component_model.dart';

class PlacedComponentModel {
  final int id;
  final Offset position;
  final ComponentModel componentModel;

  PlacedComponentModel({
    required this.id,
    required this.position,
    required this.componentModel,
  });

  PlacedComponentModel copyWith({
    int? id,
    Offset? position,
    ComponentModel? componentType,
  }) {
    return PlacedComponentModel(
      id: id ?? this.id,
      position: position ?? this.position,
      componentModel: componentType ?? componentModel,
    );
  }
}
