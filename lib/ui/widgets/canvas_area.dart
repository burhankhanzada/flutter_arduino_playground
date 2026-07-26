import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/constants.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/canvas.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class CanvasArea extends StatefulWidget {
  final CanvasController controller;
  const CanvasArea({super.key, required this.controller});

  @override
  State<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<CanvasArea> {
  CanvasController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: DropRegion(
        onPerformDrop: onPerformDrop,
        formats: Formats.standardFormats,
        onDropOver: (event) => DropOperation.copy,
        child: Canvas(controller: controller),
      ),
    );
  }

  Future<void> onPerformDrop(PerformDropEvent event) async {
    final localData = event.session.items
        .where((item) => item.localData != null)
        .map((item) => item.localData)
        .firstOrNull;

    String? componentName;

    if (localData != null) {
      componentName = localData as String;
    }

    if (componentName != null) {
      // event.position.local is already in local coordinates of the DropRegion / CanvasArea
      final canvasPosition =
          controller.screenToCanvasCoordinates(event.position.local);

      final componentModel = components
          .firstWhere(
            (type) => type.name == componentName,
          )
          .clone();

      // Center the component under the mouse drop location
      Offset nodePosition = canvasPosition -
          Offset(
            componentModel.size.width / 2,
            componentModel.size.height / 2,
          );

      if (controller.snapToGrid) {
        nodePosition = GridSystem.snapOffset(nodePosition);
      }

      final canvasComponentModel = CanvasNodeModel(
        position: nodePosition,
        componentModel: componentModel,
      );

      controller.add(canvasComponentModel);
    }
  }
}
