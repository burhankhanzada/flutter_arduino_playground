import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/controllers/workspace_controller.dart';
import 'package:flutter_arduino_playground/ui/widgets/toolbar.dart';
import 'package:flutter_arduino_playground/ui/widgets/view_selector.dart';

class HeaderBar extends StatelessWidget {
  final MainAreaView view;
  final ValueChanged<MainAreaView> onViewChanged;
  final bool isSimulating;
  final VoidCallback onToggleSimulation;
  final WorkspaceController workspaceController;

  const HeaderBar({
    super.key,
    required this.workspaceController,
    required this.view,
    required this.onViewChanged,
    required this.isSimulating,
    required this.onToggleSimulation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          Toolbar(controller: workspaceController.canvasController),
          const Spacer(),
          FilledButton.icon(
            onPressed: onToggleSimulation,
            icon: Icon(isSimulating ? Icons.stop : Icons.play_arrow),
            label: Text(isSimulating ? 'Stop Simulation' : 'Start Simulation'),
            style: isSimulating
                ? FilledButton.styleFrom(backgroundColor: Colors.red)
                : null,
          ),
        ],
      ),
    );
  }
}
