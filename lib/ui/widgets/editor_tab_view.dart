import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arduino_playground/ui/panels/left_panel.dart';
import 'package:flutter_arduino_playground/providers/workspace_provider.dart';
import 'package:flutter_arduino_playground/ui/editor/arduino_code_editor.dart';

class EditorTabView extends ConsumerWidget {
  const EditorTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);
    final allTabs = ref.watch(allTabsProvider);
    final activeTabBgColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: activeTabBgColor,
      child: IndexedStack(
        index: allTabs.indexOf(activeTab),
        children: [
          CustomCodeEditor(
            controller: ref
                .watch(workspaceControllerProvider)
                .diagramCodeController,
          ),
          CustomCodeEditor(
            controller: ref.watch(workspaceControllerProvider).codeController,
          ),
        ],
      ),
    );
  }
}
