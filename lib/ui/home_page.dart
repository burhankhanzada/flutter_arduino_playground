import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/ui/widgets/canvas_area.dart';
import 'package:flutter_arduino_playground/ui/widgets/components_palette.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(spacing: 4, children: [CanvasArea(), ComponentPalette()]),
      ),
    );
  }
}
