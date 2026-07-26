import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/simulation/simulation_runner.dart';
import 'package:flutter_arduino_playground/providers/workspace_provider.dart';
import 'package:flutter_arduino_playground/providers/debug_console_provider.dart';

enum SimulationState { stopped, running, paused }

final simulationProvider =
    NotifierProvider<SimulationNotifier, SimulationState>(
      SimulationNotifier.new,
    );

class SimulationNotifier extends Notifier<SimulationState> {
  late final SimulationRunner _runner;

  @override
  SimulationState build() {
    final workspaceController = ref.watch(workspaceControllerProvider);
    _runner = SimulationRunner(
      canvasController: workspaceController.canvasController,
      onSerialPrint: (text) {
        ref.read(serialLogsProvider.notifier).addLog(text);
      },
    );

    ref.onDispose(() {
      _runner.stop();
    });

    return SimulationState.stopped;
  }

  void toggle() {
    if (state == SimulationState.running || state == SimulationState.paused) {
      _runner.stop();
      state = SimulationState.stopped;
    } else {
      final code = ref.read(workspaceControllerProvider).codeController.text;
      _runner.start(code, () {
        // This callback is triggered when the simulation stops itself (e.g. error or finish)
        state = SimulationState.stopped;
      });
      state = SimulationState.running;
    }
  }

  void togglePause() {
    if (state == SimulationState.running) {
      _runner.pause();
      state = SimulationState.paused;
    } else if (state == SimulationState.paused) {
      _runner.resume();
      state = SimulationState.running;
    }
  }
}
