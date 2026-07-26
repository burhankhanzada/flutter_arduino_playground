import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/providers/workspace_provider.dart';
import 'package:flutter_arduino_playground/ui/widgets/toolbar.dart';

class HeaderBar extends ConsumerWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceController = ref.watch(workspaceControllerProvider);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        spacing: 8,
        children: [
          Toolbar(controller: workspaceController.canvasController),
          const Spacer(),
        ],
      ),
    );
  }
}
