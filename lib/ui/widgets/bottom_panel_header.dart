import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arduino_playground/providers/debug_console_provider.dart';
import 'package:flutter_arduino_playground/ui/widgets/bottom_panel_tab.dart';

class BottomPanelHeader extends ConsumerWidget {
  final int activeTabIndex;
  final ValueChanged<int> onTabChanged;

  const BottomPanelHeader({
    super.key,
    required this.activeTabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDebug = activeTabIndex == 0;

    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                BottomPanelTab(
                  title: 'DEBUG CONSOLE',
                  icon: Icons.terminal,
                  isActive: activeTabIndex == 0,
                  onTap: () {
                    if (activeTabIndex == 0) {
                      ref
                          .read(verticalPanelRatioProvider.notifier)
                          .toggleCollapse();
                    } else {
                      onTabChanged(0);
                      if (ref.read(verticalPanelRatioProvider) >= 0.95) {
                        ref
                            .read(verticalPanelRatioProvider.notifier)
                            .toggleCollapse();
                      }
                    }
                  },
                ),
                BottomPanelTab(
                  title: 'SERIAL MONITOR',
                  icon: Icons.monitor,
                  isActive: activeTabIndex == 1,
                  onTap: () {
                    if (activeTabIndex == 1) {
                      ref
                          .read(verticalPanelRatioProvider.notifier)
                          .toggleCollapse();
                    } else {
                      onTabChanged(1);
                      if (ref.read(verticalPanelRatioProvider) >= 0.95) {
                        ref
                            .read(verticalPanelRatioProvider.notifier)
                            .toggleCollapse();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              if (isDebug) {
                ref.read(debugLogsProvider.notifier).clear();
              } else {
                ref.read(serialLogsProvider.notifier).clear();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.delete_sweep_outlined,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
