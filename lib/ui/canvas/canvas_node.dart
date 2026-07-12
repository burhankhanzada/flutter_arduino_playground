import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';
import 'package:flutter_arduino_playground/ui/widgets/component_widget.dart';

class CanvasNode extends StatelessWidget {
  final CanvasNodeModel node;
  final CanvasController controller;

  const CanvasNode({super.key, required this.node, required this.controller});

  // Generates positions in a circle for a perfectly rounded smooth generic outline
  List<Widget> _generateSmoothOutline(Widget child, Color color, double thickness) {
    const int numSamples = 36;
    final List<Widget> shadows = [];

    for (int i = 0; i < numSamples; i++) {
        final double angle = (i / numSamples) * 2 * pi;
        final double dx = cos(angle) * thickness;
        final double dy = sin(angle) * thickness;

        shadows.add(
            Positioned(
              left: dx,
              top: dy,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                child: child,
              ),
            ),
        );
    }
    return shadows;
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.isSelected(node.key);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final baseComponent = ComponentWidget(
      componentModel: node.componentModel,
      hoveredLocalPosition: node.hoveredLocalPosition,
      breadboardHover: node.breadboardHover,
    );

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected) 
             ..._generateSmoothOutline(baseComponent, primaryColor, 2.0),
          
          baseComponent,
        ],
      ),
    );
  }
}
