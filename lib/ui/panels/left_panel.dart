import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arduino_playground/ui/widgets/editor_tab_view.dart';
import 'package:flutter_arduino_playground/ui/widgets/editor_tab_bar.dart';
import 'package:flutter_arduino_playground/providers/sidebar_provider.dart';
import 'package:flutter_arduino_playground/providers/debug_console_provider.dart';
import 'package:flutter_arduino_playground/ui/widgets/log_viewer.dart';
import 'package:flutter_arduino_playground/ui/widgets/palette_panel.dart';
import 'package:flutter_arduino_playground/ui/widgets/properties_panel.dart';

final tabsListProvider = NotifierProvider<TabsListNotifier, List<String>>(
  TabsListNotifier.new,
);

class TabsListNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ['diagram.dart', 'sketch.cpp'];

  void updateTabs(List<String> tabs) {
    state = tabs;
  }
}

final activeTabProvider = NotifierProvider<ActiveTabNotifier, String>(
  ActiveTabNotifier.new,
);

class ActiveTabNotifier extends Notifier<String> {
  @override
  String build() => 'diagram.dart';

  void setActive(String tab) {
    state = tab;
  }
}

final allTabsProvider = Provider<List<String>>(
  (ref) => ['diagram.dart', 'sketch.cpp'],
);

class LeftPanel extends ConsumerWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSidebarTab = ref.watch(sidebarTabProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _buildContent(activeSidebarTab, ref),
    );
  }

  Widget _buildContent(SidebarTab tab, WidgetRef ref) {
    switch (tab) {
      case SidebarTab.editor:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            EditorTabBar(),
            Expanded(child: EditorTabView()),
          ],
        );
      case SidebarTab.debugConsole:
        return LogViewer(logs: ref.watch(debugLogsProvider));
      case SidebarTab.serialOutput:
        return LogViewer(logs: ref.watch(serialLogsProvider));
      case SidebarTab.palette:
        return const PalettePanel();
      case SidebarTab.properties:
        return const PropertiesPanel();
    }
  }
}
