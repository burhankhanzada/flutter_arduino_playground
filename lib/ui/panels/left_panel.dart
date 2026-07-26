import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/providers/workspace_provider.dart';
import 'package:flutter_arduino_playground/ui/editor/arduino_code_editor.dart';
import 'package:flutter_arduino_playground/ui/panels/bottom_panel.dart';
import 'package:flutter_arduino_playground/providers/debug_console_provider.dart';
import 'package:flutter_arduino_playground/ui/widgets/drag_handle.dart';

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
    final tabs = ref.watch(tabsListProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tabBarBgColor = colorScheme.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 36,
          color: tabBarBgColor,
          child: ReorderableListView(
            scrollDirection: Axis.horizontal,
            buildDefaultDragHandles: false,
            onReorderItem: (oldIndex, newIndex) {
              final newTabs = List<String>.from(tabs);
              final item = newTabs.removeAt(oldIndex);
              newTabs.insert(newIndex, item);
              ref.read(tabsListProvider.notifier).updateTabs(newTabs);
            },
            children: [
              for (int i = 0; i < tabs.length; i++)
                _EditorTabItem(key: ValueKey(tabs[i]), index: i, tab: tabs[i]),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalHeight = constraints.maxHeight;
              final verticalRatio = ref.watch(verticalPanelRatioProvider);
              final topHeight = (totalHeight * verticalRatio).clamp(
                100.0,
                totalHeight - 42.0,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: topHeight, child: const _EditorTabView()),
                  DragHandle(
                    direction: Axis.vertical,
                    onPanUpdate: (details) {
                      final currentRatio = ref.read(verticalPanelRatioProvider);
                      final newRatio =
                          (currentRatio + details.delta.dy / totalHeight).clamp(
                            0.1,
                            1.0,
                          );
                      ref
                          .read(verticalPanelRatioProvider.notifier)
                          .updateRatio(newRatio);
                    },
                  ),
                  const Expanded(child: BottomPanel()),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EditorTabView extends ConsumerWidget {
  const _EditorTabView();

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

class _EditorTabItem extends ConsumerWidget {
  final int index;
  final String tab;

  const _EditorTabItem({super.key, required this.index, required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeTabBgColor = theme.scaffoldBackgroundColor;
    final inactiveTabBgColor = colorScheme.surface;
    final borderColor = theme.dividerColor;

    return ReorderableDragStartListener(
      index: index,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            ref.read(activeTabProvider.notifier).setActive(tab);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: activeTab == tab ? activeTabBgColor : inactiveTabBgColor,
              border: Border(
                top: BorderSide(
                  color: activeTab == tab
                      ? colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
                right: BorderSide(color: borderColor, width: 1),
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tab.endsWith('.dart') ? Icons.flutter_dash : Icons.code,
                  size: 14,
                  color: activeTab == tab
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  tab,
                  style: TextStyle(
                    color: activeTab == tab
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
