import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/providers/debug_console_provider.dart';

class BottomPanel extends ConsumerStatefulWidget {
  const BottomPanel({super.key});

  @override
  ConsumerState<BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends ConsumerState<BottomPanel> {
  int _activeTabIndex = 0; // 0 for Debug Console, 1 for Serial Monitor

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDebug = _activeTabIndex == 0;

    final logs = ref.watch(isDebug ? debugLogsProvider : serialLogsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
                      _buildTab(
                        context,
                        title: 'DEBUG CONSOLE',
                        icon: Icons.terminal,
                        isActive: _activeTabIndex == 0,
                        onTap: () {
                          if (_activeTabIndex == 0) {
                            ref
                                .read(verticalPanelRatioProvider.notifier)
                                .toggleCollapse();
                          } else {
                            setState(() => _activeTabIndex = 0);
                            if (ref.read(verticalPanelRatioProvider) >= 0.95) {
                              ref
                                  .read(verticalPanelRatioProvider.notifier)
                                  .toggleCollapse();
                            }
                          }
                        },
                      ),
                      _buildTab(
                        context,
                        title: 'SERIAL MONITOR',
                        icon: Icons.monitor,
                        isActive: _activeTabIndex == 1,
                        onTap: () {
                          if (_activeTabIndex == 1) {
                            ref
                                .read(verticalPanelRatioProvider.notifier)
                                .toggleCollapse();
                          } else {
                            setState(() => _activeTabIndex = 1);
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
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    logs[index],
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
