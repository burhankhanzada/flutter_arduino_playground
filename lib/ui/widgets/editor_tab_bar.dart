import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arduino_playground/ui/panels/left_panel.dart';
import 'package:flutter_arduino_playground/ui/widgets/editor_tab_item.dart';

class EditorTabBar extends ConsumerWidget {
  const EditorTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(tabsListProvider);
    final theme = Theme.of(context);
    final tabBarBgColor = theme.colorScheme.surface;

    return Container(
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
            EditorTabItem(key: ValueKey(tabs[i]), index: i, tab: tabs[i]),
        ],
      ),
    );
  }
}
