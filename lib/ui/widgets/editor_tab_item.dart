import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arduino_playground/ui/panels/left_panel.dart';

class EditorTabItem extends ConsumerWidget {
  final int index;
  final String tab;

  const EditorTabItem({super.key, required this.index, required this.tab});

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
