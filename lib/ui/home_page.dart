import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/ui/widgets/canvas_area.dart';
import 'package:flutter_arduino_playground/ui/palette/components_palette.dart';
import 'package:flutter_arduino_playground/ui/widgets/toolbar.dart';

import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CanvasController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CanvasController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Toolbar(controller: _controller),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: CanvasArea(controller: _controller)),
                const ComponentPalette(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
