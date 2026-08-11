import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/simulation/simulation_runner.dart';
import 'package:flutter_arduino_playground/providers/workspace_provider.dart';
import 'package:flutter_arduino_playground/providers/debug_console_provider.dart';

enum SimulationState {
  stopped,
  compiling,
  running,
  paused,
}

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
      onSpiceLog: (text) {
        ref.read(spiceLogsProvider.notifier).addLog(text);
      },
    );

    ref.onDispose(() {
      _runner.stop();
    });

    return SimulationState.stopped;
  }

  Future<void> toggle() async {
    if (state == SimulationState.running ||
        state == SimulationState.paused ||
        state == SimulationState.compiling) {
      _runner.stop();
      state = SimulationState.stopped;
    } else {
      final code = ref.read(workspaceControllerProvider).codeController.text;
      state = SimulationState.compiling;

      try {
        final success = await _runner.start(code, () {
          // This callback is triggered when the simulation stops itself (e.g. error or finish)
          state = SimulationState.stopped;
        });

        if (success && state == SimulationState.compiling) {
          state = SimulationState.running;
        } else {
          state = SimulationState.stopped;
        }
      } catch (e) {
        state = SimulationState.stopped;
      }
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
