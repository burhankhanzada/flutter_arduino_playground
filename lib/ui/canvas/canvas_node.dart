import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';
import 'package:flutter_arduino_playground/ui/widgets/component_widget.dart';

class CanvasNode extends StatelessWidget {
  final CanvasNodeModel node;
  final CanvasController controller;

  const CanvasNode({super.key, required this.node, required this.controller});

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      border: Border.all(
        width: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    return Stack(
      children: [
        ComponentWidget(componentModel: node.componentModel),
        Container(
          decoration: controller.isSelected(node.key) ? decoration : null,
        ),
      ],
    );
  }
}
