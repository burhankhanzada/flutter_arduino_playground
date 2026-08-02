import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arduino_playground/providers/workspace_provider.dart';

class ZoomControls extends ConsumerWidget {
  const ZoomControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceController = ref.watch(workspaceControllerProvider);

    return Positioned(
      top: 16,
      right: 16,
      child: Card(
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => workspaceController.canvasController.zoomOut(),
                icon: const Icon(Icons.remove),
                tooltip: 'Zoom Out',
              ),
              IconButton(
                onPressed: () => workspaceController.canvasController.zoomIn(),
                icon: const Icon(Icons.add),
                tooltip: 'Zoom In',
              ),
              const VerticalDivider(),
              ListenableBuilder(
                listenable: workspaceController.canvasController,
                builder: (context, _) {
                  final isGridVisible =
                      workspaceController.canvasController.showGrid;
                  return IconButton(
                    onPressed: () =>
                        workspaceController.canvasController.toggleGrid(),
                    icon: Icon(isGridVisible ? Icons.grid_off : Icons.grid_on),
                    tooltip: 'Toggle Grid',
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  final size = MediaQuery.of(context).size;
                  workspaceController.canvasController.fitToContent(size);
                },
                icon: const Icon(Icons.aspect_ratio),
                tooltip: 'Reset View',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
