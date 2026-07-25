import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/cpp.dart';
import 'package:re_highlight/styles/monokai-sublime.dart';
import 'package:re_highlight/styles/arduino-light.dart';

class ArduinoCodeEditor extends StatelessWidget {
  final CodeLineEditingController controller;

  const ArduinoCodeEditor({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = isDark ? monokaiSublimeTheme : arduinoLightTheme;
    final defaultBg = isDark ? const Color(0xFF23241f) : const Color(0xFFFFFFFF);

    return Container(
      color: theme['root']?.backgroundColor ?? defaultBg,
      child: CodeEditor(
        controller: controller,
        style: CodeEditorStyle(
          fontSize: 14,
          codeTheme: CodeHighlightTheme(
            languages: {
              'cpp': CodeHighlightThemeMode(
                mode: langCpp
              )
            },
            theme: theme,
          ),
        ),
      ),
    );
  }
}
