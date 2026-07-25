import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/ui/widgets/canvas_area.dart';
import 'package:flutter_arduino_playground/ui/palette/components_palette.dart';
import 'package:flutter_arduino_playground/ui/widgets/header_bar.dart';
import 'package:flutter_arduino_playground/ui/widgets/toolbar.dart';
import 'package:flutter_arduino_playground/ui/widgets/view_selector.dart';
import 'package:flutter_arduino_playground/ui/widgets/arduino_code_editor.dart';

import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/models/wire_model.dart';
import 'package:flutter_arduino_playground/constants.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';

import 'package:re_editor/re_editor.dart';
import 'package:flutter_arduino_playground/ui/components_painters/led_painter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CanvasController _controller;
  late final CodeLineEditingController _codeController;
  MainAreaView _currentView = MainAreaView.design;
  bool _isSimulating = false;

  void _toggleSimulation() {
    if (_isSimulating) {
      setState(() {
        _isSimulating = false;
      });
    } else {
      setState(() {
        _isSimulating = true;
      });
      _runSimulationLoop();
    }
  }

  Future<void> _runSimulationLoop() async {
    final code = _codeController.text;
    final loopRegex = RegExp(r'void\s+loop\(\)\s*\{([^}]*)\}');
    final match = loopRegex.firstMatch(code);
    if (match == null) {
      setState(() => _isSimulating = false);
      return;
    }

    // Strip comments
    final cleanBody = match.group(1)!.replaceAll(RegExp(r'//.*'), '');
    final statements = cleanBody
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final ledNode = _controller.nodes.firstWhere(
      (n) => n.componentModel.name == 'LED',
    );
    final ledPainter = ledNode.componentModel.painter as LEDPainter;

    while (_isSimulating) {
      if (statements.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      for (final statement in statements) {
        if (!_isSimulating) break;

        if (statement.startsWith('digitalWrite')) {
          final isHigh = statement.contains('HIGH');
          ledPainter.isOn = isHigh;
          _controller.forceUpdate();
        } else if (statement.startsWith('delay')) {
          final delayMatch = RegExp(r'delay\((\d+)\)').firstMatch(statement);
          if (delayMatch != null) {
            final ms = int.tryParse(delayMatch.group(1)!) ?? 1000;
            await Future.delayed(Duration(milliseconds: ms));
          }
        }
      }
      // Small safety yield
      await Future.delayed(Duration.zero);
    }

    ledPainter.isOn = false;
    _controller.forceUpdate();
  }

  @override
  void initState() {
    super.initState();
    _codeController = CodeLineEditingController.fromText('''void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  digitalWrite(LED_BUILTIN, HIGH);  // turn the LED on (HIGH is the voltage level)
  delay(1000);                      // wait for a second
  digitalWrite(LED_BUILTIN, LOW);   // turn the LED off by making the voltage LOW
  delay(1000);                      // wait for a second
}
''');

    final arduinoModel = components
        .firstWhere((c) => c.name == 'Arduino Uno')
        .clone();
    final ledModel = components.firstWhere((c) => c.name == 'LED').clone();
    final resistorModel = components
        .firstWhere((c) => c.name == 'Resistor')
        .clone();

    final arduinoNode = CanvasNodeModel(
      position: const Offset(-150, -50),
      componentModel: arduinoModel,
    );

    final resistorNode = CanvasNodeModel(
      position: const Offset(-60, -120),
      componentModel: resistorModel,
    );

    final ledNode = CanvasNodeModel(
      position: const Offset(20, -152.5),
      componentModel: ledModel,
    );

    final wire1 = WireModel(
      id: 'wire1',
      start: PortLocation(nodeKey: arduinoNode.key, portId: '13'),
      end: PortLocation(nodeKey: resistorNode.key, portId: 'left'),
      bendPoints: [const Offset(33, -80), const Offset(-47.5, -80)],
      color: Colors.orange,
    );

    final wire2 = WireModel(
      id: 'wire2',
      start: PortLocation(nodeKey: resistorNode.key, portId: 'right'),
      end: PortLocation(nodeKey: ledNode.key, portId: 'anode'),
      bendPoints: [], // Straight line
      color: Colors.red,
    );

    final wire3 = WireModel(
      id: 'wire3',
      start: PortLocation(nodeKey: ledNode.key, portId: 'cathode'),
      end: PortLocation(nodeKey: arduinoNode.key, portId: 'GND_1'),
      bendPoints: [const Offset(37.5, -60), const Offset(21, -60)],
      color: Colors.black,
    );

    _controller = CanvasController(
      nodes: [arduinoNode, resistorNode, ledNode],
      wires: [wire1, wire2, wire3],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderBar(
            view: _currentView,
            onViewChanged: (view) {
              setState(() {
                _currentView = view;
              });
            },
            isSimulating: _isSimulating,
            onToggleSimulation: _toggleSimulation,
          ),
          if (_currentView == MainAreaView.design)
            Toolbar(controller: _controller),
          Expanded(
            child: _currentView == MainAreaView.design
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: CanvasArea(controller: _controller)),
                      const ComponentPalette(),
                    ],
                  )
                : ArduinoCodeEditor(controller: _codeController),
          ),
        ],
      ),
    );
  }
}
