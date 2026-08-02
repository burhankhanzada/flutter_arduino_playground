import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/providers/workspace_provider.dart';
import 'package:flutter_arduino_playground/ui/widgets/wire_color_drop_down_menu.dart';

class Toolbar extends ConsumerWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceController = ref.watch(workspaceControllerProvider);
    final controller = workspaceController.canvasController;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final hasNodeSelection = controller.selectedNodes.isNotEmpty;
            final hasSelection =
                hasNodeSelection || controller.selectedWireId != null;
            return Row(
              children: [
                IconButton(
                  onPressed: hasNodeSelection ? () => controller.copy() : null,
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy',
                ),
                IconButton(
                  onPressed: () => controller.paste(),
                  icon: const Icon(Icons.paste),
                  tooltip: 'Paste',
                ),
                IconButton(
                  onPressed: hasSelection ? () => controller.remove() : null,
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
                  onPressed: hasNodeSelection
                      ? () => controller.rotateLeft()
                      : null,
                  icon: const Icon(Icons.rotate_left),
                  tooltip: 'Rotate Left',
                ),
                IconButton(
                  onPressed: hasNodeSelection
                      ? () => controller.rotateRight()
                      : null,
                  icon: const Icon(Icons.rotate_right),
                  tooltip: 'Rotate Right',
                ),
                const VerticalDivider(),
                IconButton(
                  onPressed: hasNodeSelection
                      ? () => controller.flipHorizontal()
                      : null,
                  icon: const Icon(Icons.flip),
                  tooltip: 'Flip Horizontal',
                ),
                IconButton(
                  onPressed: hasNodeSelection
                      ? () => controller.flipVertical()
                      : null,
                  icon: Transform.rotate(
                    angle: math.pi * 1 / 2,
                    child: const Icon(Icons.flip),
                  ),
                  tooltip: 'Flip Vertical',
                ),
                const VerticalDivider(),
                IconButton(
                  onPressed: hasNodeSelection
                      ? () => controller.layerUp()
                      : null,
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: 'Layer Up',
                ),
                IconButton(
                  onPressed: hasNodeSelection
                      ? () => controller.layerDown()
                      : null,
                  icon: const Icon(Icons.arrow_downward),
                  tooltip: 'Layer Down',
                ),
                const VerticalDivider(),
                WireColorDropDownMenu(controller: controller),
              ],
            );
          },
        ),
      ),
    );
  }
}
