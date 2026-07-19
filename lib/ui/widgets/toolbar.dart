import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/ui/widgets/wire_color_drop_down_menu.dart';

import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';

class Toolbar extends StatelessWidget {
  final CanvasController controller;
  const Toolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => controller.copy(),
            icon: const Icon(Icons.copy),
            tooltip: 'Copy',
          ),
          IconButton(
            onPressed: () => controller.paste(),
            icon: const Icon(Icons.paste),
            tooltip: 'Paste',
          ),
          IconButton(
            onPressed: () => controller.remove(),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
          ),
          const VerticalDivider(),
          IconButton(
            onPressed: () => controller.undo(),
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
          ),
          IconButton(
            onPressed: () => controller.redo(),
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
          ),
          const VerticalDivider(),
          IconButton(
            onPressed: () => controller.rotateLeft(),
            icon: const Icon(Icons.rotate_left),
            tooltip: 'Rotate Left',
          ),
          IconButton(
            onPressed: () => controller.rotateRight(),
            icon: const Icon(Icons.rotate_right),
            tooltip: 'Rotate Right',
          ),
          const VerticalDivider(),
          IconButton(
            onPressed: () => controller.flipHorizontal(),
            icon: const Icon(Icons.flip),
            tooltip: 'Flip Horizontal',
          ),
          IconButton(
            onPressed: () => controller.flipVertical(),
            icon: Transform.rotate(
              angle: math.pi * 1 / 2,
              child: const Icon(Icons.flip),
            ),
            tooltip: 'Flip Vertical',
          ),
          const VerticalDivider(),
          IconButton(
            onPressed: () => controller.layerUp(),
            icon: const Icon(Icons.arrow_upward),
            tooltip: 'Layer Up',
          ),
          IconButton(
            onPressed: () => controller.layerDown(),
            icon: const Icon(Icons.arrow_downward),
            tooltip: 'Layer Down',
          ),
          const VerticalDivider(),
          IconButton(
            onPressed: () => controller.zoomIn(),
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
          ),
          IconButton(
            onPressed: () => controller.zoomOut(),
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
          ),
          const VerticalDivider(),
          // Reset zoom, rotate and pan to where most of the components are visible
          IconButton(
            onPressed: () {
              final size = MediaQuery.of(context).size;
              controller.fitToContent(size);
            },
            icon: const Icon(Icons.aspect_ratio),
            tooltip: 'Reset',
          ),
          const VerticalDivider(),
          WireColorDropDownMenu(controller: controller),
        ],
      ),
    );
  }
}
