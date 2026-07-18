import 'package:flutter/material.dart';

class ViewSelector extends StatefulWidget {
  const ViewSelector({super.key});

  @override
  State<ViewSelector> createState() => _ViewSelectorState();
}

enum MainAreaView { design, code }

class _ViewSelectorState extends State<ViewSelector> {
  MainAreaView view = .design;

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
          value: MainAreaView.code,
          label: Text('Code'),
          icon: Icon(Icons.code),
        ),
      ],
      selected: <MainAreaView>{view},
      onSelectionChanged: (Set<MainAreaView> newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          view = newSelection.first;
        });
      },
    );
  }
}
