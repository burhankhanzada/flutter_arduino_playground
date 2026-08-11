import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arduino_playground/providers/simulation_provider.dart';

class SimulationControls extends ConsumerWidget {
  const SimulationControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulationState = ref.watch(simulationProvider);
    final isSimulating = simulationState != SimulationState.stopped;
    final isPaused = simulationState == SimulationState.paused;

    return Positioned(
      top: 16,
      left: 16,
      child: Row(
        spacing: 12,
        children: [
          if (simulationState == SimulationState.compiling)
            FloatingActionButton(
              mini: true,
              onPressed: () {
                ref.read(simulationProvider.notifier).toggle();
              },
              tooltip: 'Cancel compilation',
              shape: const CircleBorder(),
              backgroundColor: Colors.grey,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            )
          else
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
          if (isSimulating && simulationState != SimulationState.compiling)
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
    );
  }
}
