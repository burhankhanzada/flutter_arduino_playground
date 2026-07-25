import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/ui/widgets/view_selector.dart';

class HeaderBar extends StatelessWidget {
  final MainAreaView view;
  final ValueChanged<MainAreaView> onViewChanged;
  final bool isSimulating;
  final VoidCallback onToggleSimulation;

  const HeaderBar({
    super.key,
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
          FlutterLogo(),
          const Text(
            'Arduino Playground',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const Spacer(),
          ViewSelector(view: view, onViewChanged: onViewChanged),
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
