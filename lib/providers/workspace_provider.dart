import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/controllers/workspace_controller.dart';
import 'package:flutter_arduino_playground/utils/circuit_defaults.dart';
import 'package:flutter_arduino_playground/providers/debug_console_provider.dart';
import 'package:flutter_arduino_playground/providers/component_provider.dart';

final workspaceControllerProvider = Provider<WorkspaceController>((ref) {
  final components = ref.watch(componentRegistryProvider).requireValue;
  final defaultSetup = CircuitDefaults.getBlinkExample();
  final controller = WorkspaceController.fromTemplate(
    defaultSetup,
    components,
    onCircuitError: (err) {
      if (err.isNotEmpty) {
        ref.read(debugLogsProvider.notifier).clear();
        ref.read(debugLogsProvider.notifier).addLog(err);
      } else {
        ref.read(debugLogsProvider.notifier).clear();
      }
    },
  );
  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
