import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/ui/home_page.dart';
import 'package:flutter_arduino_playground/ui/panels/left_panel.dart';
import 'package:flutter_arduino_playground/ui/panels/right_panel.dart';
import 'package:flutter_arduino_playground/ui/widgets/drag_handle.dart';

final leftPanelRatioProvider = NotifierProvider<LeftPanelRatioNotifier, double>(
  LeftPanelRatioNotifier.new,
);

class MainWorkspace extends ConsumerWidget {
  const MainWorkspace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leftPanelRatio = ref.watch(leftPanelRatioProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        // 8 pixels for the drag handle
        final leftWidth = (totalWidth * leftPanelRatio).clamp(
          100.0,
          totalWidth - 100.0,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: leftWidth, child: const LeftPanel()),
            DragHandle(
              direction: Axis.horizontal,
              onPanUpdate: (details) {
                final currentRatio = ref.read(leftPanelRatioProvider);
                final newRatio = (currentRatio + details.delta.dx / totalWidth)
                    .clamp(0.1, 0.9);
                ref.read(leftPanelRatioProvider.notifier).updateRatio(newRatio);
              },
            ),
            const Expanded(child: RightPanel()),
          ],
        );
      },
    );
  }
}
