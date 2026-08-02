import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arduino_playground/providers/workspace_provider.dart';

class ZoomControls extends ConsumerWidget {
  const ZoomControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceController = ref.watch(workspaceControllerProvider);

    return Positioned(
      bottom: 16,
      left: 16,
      child: Card(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => workspaceController.canvasController.zoomOut(),
              icon: const Icon(Icons.remove),
              tooltip: 'Zoom Out',
            ),
            Container(
              width: 1,
              height: 24,
              color: Theme.of(context).dividerColor,
            ),
            IconButton(
              onPressed: () {
                final size = MediaQuery.of(context).size;
                workspaceController.canvasController.fitToContent(size);
              },
              icon: const Icon(Icons.aspect_ratio),
              tooltip: 'Reset View',
            ),
            Container(
              width: 1,
              height: 24,
              color: Theme.of(context).dividerColor,
            ),
            IconButton(
              onPressed: () => workspaceController.canvasController.zoomIn(),
              icon: const Icon(Icons.add),
              tooltip: 'Zoom In',
            ),
          ],
        ),
      ),
    );
  }
}
