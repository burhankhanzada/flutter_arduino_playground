import 'package:flutter/material.dart';

enum MainAreaView { design, code, diagramCode }

class ViewSelector extends StatelessWidget {
  final MainAreaView view;
  final ValueChanged<MainAreaView> onViewChanged;

  const ViewSelector({
    super.key,
    required this.view,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MainAreaView>(
      showSelectedIcon: false,
      segments: const <ButtonSegment<MainAreaView>>[
        ButtonSegment<MainAreaView>(
          value: MainAreaView.design,
          label: Text('Design'),
          icon: Icon(Icons.design_services),
        ),
        ButtonSegment<MainAreaView>(
          value: MainAreaView.diagramCode,
          label: Text('Diagram Code'),
          icon: Icon(Icons.data_object),
        ),
        ButtonSegment<MainAreaView>(
          value: MainAreaView.code,
          label: Text('C++ Code'),
          icon: Icon(Icons.code),
        ),
      ],
      selected: <MainAreaView>{view},
      onSelectionChanged: (Set<MainAreaView> newSelection) {
        onViewChanged(newSelection.first);
      },
    );
  }
}
