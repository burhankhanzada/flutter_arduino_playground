import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/controllers/workspace_controller.dart';
import 'package:flutter_arduino_playground/utils/circuit_defaults.dart';

final workspaceControllerProvider = Provider<WorkspaceController>((ref) {
  final defaultSetup = CircuitDefaults.getBlinkExample();
  final controller = WorkspaceController.fromTemplate(defaultSetup);
  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
