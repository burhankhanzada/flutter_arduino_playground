import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/models/component_model.dart';

class CanvasNodeModel {
  CanvasNodeModel({
    required this.position,
    required this.componentModel,
    LocalKey? key,
  }) : key = key ?? UniqueKey();

  Offset position;
  final LocalKey key;
  final ComponentModel componentModel;

  Rect get rect => position & componentModel.size;

  CanvasNodeModel copyWith({
    Offset? position,
    ComponentModel? componentModel,
  }) {
    return CanvasNodeModel(
      position: position ?? this.position,
      componentModel: componentModel ?? this.componentModel,
      key: key,
    );
  }
}
