import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arduino_playground/providers/workspace_provider.dart';
import 'package:flutter_arduino_playground/ui/palette/component_properties_panel.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceController = ref.watch(workspaceControllerProvider);

    return ListenableBuilder(
      listenable: workspaceController.canvasController,
      builder: (context, child) {
        return ComponentPropertiesPanel(
          controller: workspaceController.canvasController,
          selectedNode: workspaceController
              .canvasController
              .selectedNodes
              .firstOrNull,
        );
      },
    );
  }
}
