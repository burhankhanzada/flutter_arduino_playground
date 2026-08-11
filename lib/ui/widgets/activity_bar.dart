import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/providers/sidebar_provider.dart';

class ActivityBar extends ConsumerWidget {
  const ActivityBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(sidebarTabProvider);
    final theme = Theme.of(context);

    return Container(
      width: 48,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          const SizedBox(height: 8),
          _ActivityIcon(
            icon: Icons.code,
            tab: SidebarTab.editor,
            activeTab: activeTab,
            tooltip: 'Editor',
          ),
          _ActivityIcon(
            icon: Icons.category,
            tab: SidebarTab.palette,
            activeTab: activeTab,
            tooltip: 'Component Palette',
          ),
          _ActivityIcon(
            icon: Icons.tune,
            tab: SidebarTab.properties,
            activeTab: activeTab,
            tooltip: 'Property Panel',
          ),
          _ActivityIcon(
            icon: Icons.bug_report,
            tab: SidebarTab.debugConsole,
            activeTab: activeTab,
            tooltip: 'Debug Console',
          ),
          _ActivityIcon(
            icon: Icons.terminal,
            tab: SidebarTab.serialOutput,
            activeTab: activeTab,
            tooltip: 'Serial Output',
          ),
          _ActivityIcon(
            icon: Icons.waves,
            tab: SidebarTab.spiceLogs,
            activeTab: activeTab,
            tooltip: 'SPICE Logs',
          ),
        ],
      ),
    );
  }
}

class _ActivityIcon extends ConsumerWidget {
  final IconData icon;
  final SidebarTab tab;
  final SidebarTab activeTab;
  final String tooltip;

  const _ActivityIcon({
    required this.icon,
    required this.tab,
    required this.activeTab,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = tab == activeTab;
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: InkWell(
        onTap: () {
          ref.read(sidebarTabProvider.notifier).setTab(tab);
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isActive
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}
