import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/constants.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/canvas.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class CanvasArea extends StatefulWidget {
  const CanvasArea({super.key});

  @override
  State<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<CanvasArea> {
  final controller = CanvasController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card.outlined(
        clipBehavior: Clip.antiAlias,
        child: DropRegion(
          onPerformDrop: onPerformDrop,
          formats: Formats.standardFormats,
          onDropOver: (event) => DropOperation.copy,
          child: Canvas(controller: controller),
        ),
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
      final renderBox = context.findRenderObject() as RenderBox;
      final localPosition = renderBox.globalToLocal(event.position.local);

      // Transform local position to canvas coordinates
      final canvasPositionRaw = (localPosition - controller.offset) / controller.scale;
      Offset canvasPosition = canvasPositionRaw;

      if (controller.snapToGrid) {
        canvasPosition = Offset(
          (canvasPosition.dx / controller.gridSize).round() * controller.gridSize,
          (canvasPosition.dy / controller.gridSize).round() * controller.gridSize,
        );
      }

      final componentModel = components.firstWhere(
        (type) => type.name == componentName,
      );

      final canvasComponentModel = CanvasNodeModel(
        position: canvasPosition,
        componentModel: componentModel,
      );

      controller.add(canvasComponentModel);
    }
  }
}
