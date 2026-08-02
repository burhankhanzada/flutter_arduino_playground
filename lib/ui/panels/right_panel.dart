import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/ui/widgets/toolbar.dart';
import 'package:flutter_arduino_playground/providers/workspace_provider.dart';
import 'package:flutter_arduino_playground/ui/canvas/canvas_area.dart';
import 'package:flutter_arduino_playground/ui/widgets/simulation_controls.dart';
import 'package:flutter_arduino_playground/ui/widgets/zoom_controls.dart';

class RightPanel extends ConsumerWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceController = ref.watch(workspaceControllerProvider);

    return Column(
      children: [
        Toolbar(),
        Expanded(
          child: Stack(
            children: [
              CanvasArea(controller: workspaceController.canvasController),
              const SimulationControls(),
              const ZoomControls(),
            ],
          ),
        ),
      ],
    );
  }
}
