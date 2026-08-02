import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arduino_playground/ui/palette/components_palette.dart';

class PalettePanel extends ConsumerWidget {
  const PalettePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ComponentPalette();
  }
}
