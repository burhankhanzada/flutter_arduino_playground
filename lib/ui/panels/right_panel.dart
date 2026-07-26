import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/providers/workspace_provider.dart';
import 'package:flutter_arduino_playground/providers/simulation_provider.dart';
import 'package:flutter_arduino_playground/ui/canvas/canvas_area.dart';
import 'package:flutter_arduino_playground/ui/palette/components_palette.dart';

final showPaletteProvider = NotifierProvider<ShowPaletteNotifier, bool>(
  ShowPaletteNotifier.new,
);

class ShowPaletteNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}

class RightPanel extends ConsumerWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showPalette = ref.watch(showPaletteProvider);
    final simulationState = ref.watch(simulationProvider);
    final isSimulating = simulationState != SimulationState.stopped;
    final isPaused = simulationState == SimulationState.paused;
    final workspaceController = ref.watch(workspaceControllerProvider);

    return Stack(
      children: [
        CanvasArea(controller: workspaceController.canvasController),
        Positioned(
          top: 16,
          left: 16,
          child: Row(
            spacing: 12,
            children: [
              FloatingActionButton(
                mini: true,
                onPressed: () {
                  ref.read(simulationProvider.notifier).toggle();
                },
                tooltip: isSimulating
                    ? 'Stop the simulation'
                    : 'Start the simulation',
                shape: const CircleBorder(),
                backgroundColor: isSimulating ? Colors.red : Colors.green,
                child: Icon(isSimulating ? Icons.stop : Icons.play_arrow),
              ),
              if (isSimulating)
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    ref.read(simulationProvider.notifier).togglePause();
                  },
                  tooltip: isPaused
                      ? 'Resume the simulation'
                      : 'Pause the simulation',
                  shape: const CircleBorder(),
                  backgroundColor: Colors.orange,
                  child: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                ),
            ],
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          bottom: 0,
          right: showPalette ? 0 : -300,
          width: 300,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: const ComponentPalette(),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 16,
          right: showPalette ? 316 : 16,
          child: FloatingActionButton(
            mini: true,
            tooltip: 'Toggle Components Palette',
            child: Icon(showPalette ? Icons.chevron_right : Icons.add),
            onPressed: () {
              ref.read(showPaletteProvider.notifier).toggle();
            },
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () =>
                      workspaceController.canvasController.zoomOut(),
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
                  onPressed: () =>
                      workspaceController.canvasController.zoomIn(),
                  icon: const Icon(Icons.add),
                  tooltip: 'Zoom In',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
