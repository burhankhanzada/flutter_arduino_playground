import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogViewer extends StatelessWidget {
  final List<String> logs;
  final VoidCallback onClear;
  final String title;

  const LogViewer({
    super.key, 
    required this.logs, 
    required this.onClear,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy all logs',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: logs.join('')));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logs copied to clipboard'), duration: Duration(seconds: 2)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                tooltip: 'Clear logs',
                onPressed: onClear,
              ),
            ],
          ),
        ),
        Expanded(
          child: logs.isEmpty
              ? const Center(
                  child: Text('No output', style: TextStyle(color: Colors.grey)),
                )
              : MouseRegion(
                  cursor: SystemMouseCursors.text,
                  child: SelectionArea(
                    child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final actualIndex = logs.length - 1 - index;
                        return Text(
                          logs[actualIndex].trimRight(), // remove trailing newlines
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            height: 1.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
