import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';

import 'package:flutter_arduino_playground/ui/widgets/canvas_area.dart';
import 'package:flutter_arduino_playground/ui/palette/components_palette.dart';
import 'package:flutter_arduino_playground/ui/widgets/header_bar.dart';
import 'package:flutter_arduino_playground/ui/widgets/view_selector.dart';
import 'package:flutter_arduino_playground/ui/widgets/arduino_code_editor.dart';

import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';
import 'package:flutter_arduino_playground/utils/circuit_parser.dart';
import 'package:flutter_arduino_playground/utils/circuit_defaults.dart';
import 'package:flutter_arduino_playground/controllers/workspace_controller.dart';
import 'package:flutter_arduino_playground/simulation/simulation_runner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WorkspaceController _workspaceController;
  late final SimulationRunner _simulationRunner;

  @override
  void initState() {
    super.initState();
    final defaultSetup = CircuitDefaults.getBlinkExample();

    final canvasController = CanvasController(nodes: [], wires: []);

    final parsedData = CircuitParser.parse(defaultSetup.diagramCode);
    CircuitParser.applyToCanvas(
      parsedData,
      canvasController.nodes,
      canvasController.wires,
    );

    final codeController = CodeLineEditingController.fromText(
      defaultSetup.cppCode,
    );
    final diagramCodeController = CodeLineEditingController.fromText(
      defaultSetup.diagramCode,
    );

    _workspaceController = WorkspaceController(
      canvasController: canvasController,
      codeController: codeController,
      diagramCodeController: diagramCodeController,
    );

    _simulationRunner = SimulationRunner(canvasController: canvasController);
  }

  @override
  void dispose() {
    _simulationRunner.stop();
    _workspaceController.dispose();
    super.dispose();
  }

  void _toggleSimulation() {
    if (_simulationRunner.isSimulating) {
      setState(() {
        _simulationRunner.stop();
      });
    } else {
      setState(() {
        _simulationRunner.start(_workspaceController.codeController.text, () {
          if (mounted) setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderBar(
            view: MainAreaView.design,
            onViewChanged: (_) {},
            workspaceController: _workspaceController,
            isSimulating: _simulationRunner.isSimulating,
            onToggleSimulation: _toggleSimulation,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: LeftPanelEditor(
                    workspaceController: _workspaceController,
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  flex: 1,
                  child: RightPanelCanvas(
                    workspaceController: _workspaceController,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeftPanelEditor extends StatelessWidget {
  final WorkspaceController workspaceController;

  const LeftPanelEditor({super.key, required this.workspaceController});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Material(
            color: Color(0xFFF3F3F3),
            child: TabBar(
              tabs: [
                Tab(text: 'sketch.cpp'),
                Tab(text: 'diagram.dart'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ArduinoCodeEditor(
                  controller: workspaceController.codeController,
                ),
                ArduinoCodeEditor(
                  controller: workspaceController.diagramCodeController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RightPanelCanvas extends StatefulWidget {
  final WorkspaceController workspaceController;

  const RightPanelCanvas({super.key, required this.workspaceController});

  @override
  State<RightPanelCanvas> createState() => _RightPanelCanvasState();
}

class _RightPanelCanvasState extends State<RightPanelCanvas> {
  bool _showPalette = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CanvasArea(controller: widget.workspaceController.canvasController),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          bottom: 0,
          right: _showPalette ? 0 : -300,
          width: 300,
          child: const Material(elevation: 8, child: ComponentPalette()),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 16,
          right: _showPalette ? 316 : 16,
          child: FloatingActionButton.small(
            heroTag: 'palette_toggle',
            onPressed: () {
              setState(() {
                _showPalette = !_showPalette;
              });
            },
            tooltip: 'Toggle Components Palette',
            child: Icon(_showPalette ? Icons.chevron_right : Icons.add),
          ),
        ),
      ],
    );
  }
}
