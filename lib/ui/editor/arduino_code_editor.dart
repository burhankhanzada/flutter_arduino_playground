import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/cpp.dart';
import 'package:re_highlight/styles/vs2015.dart';
import 'package:re_highlight/styles/vs.dart';

class CustomCodeEditor extends StatelessWidget {
  final CodeLineEditingController controller;

  const CustomCodeEditor({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = isDark ? vs2015Theme : vsTheme;
    final defaultBg = isDark
        ? const Color(0xFF1E1E1E) // VSCode default dark background
        : const Color(0xFFFFFFFF);

    return Container(
      color: theme['root']?.backgroundColor ?? defaultBg,
      child: CodeEditor(
        controller: controller,
        style: CodeEditorStyle(
          fontSize: 14,
          codeTheme: CodeHighlightTheme(
            languages: {'cpp': CodeHighlightThemeMode(mode: langCpp)},
            theme: theme,
          ),
        ),
        indicatorBuilder:
            (context, editingController, chunkController, notifier) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultCodeLineNumber(
                    controller: editingController,
                    notifier: notifier,
                  ),
                  DefaultCodeChunkIndicator(
                    width: 20,
                    controller: chunkController,
                    notifier: notifier,
                  ),
                ],
              );
            },
        sperator: Container(
          width: 1,
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
    );
  }
}
