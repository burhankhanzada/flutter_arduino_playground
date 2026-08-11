import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';

import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';
import 'package:flutter_arduino_playground/utils/circuit_parser.dart';
import 'package:flutter_arduino_playground/utils/circuit_defaults.dart';
import 'package:flutter_arduino_playground/simulation/circuit_netlist.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';

class WorkspaceController {
  final CanvasController canvasController;
  final CodeLineEditingController codeController;
  final CodeLineEditingController diagramCodeController;
  final List<ComponentModel> components;
  final void Function(String)? onCircuitError;

  bool _isSyncing = false;
  bool _pendingCodeToCanvas = false;
  bool _pendingCanvasToCode = false;

  WorkspaceController({
    required this.canvasController,
    required this.codeController,
    required this.diagramCodeController,
    required this.components,
    this.onCircuitError,
  }) {
    diagramCodeController.addListener(_syncCodeToCanvas);
    canvasController.addListener(_syncCanvasToCode);
  }

  factory WorkspaceController.fromTemplate(
    ProjectTemplate template,
    List<ComponentModel> components, {
    void Function(String)? onCircuitError,
  }) {
    final canvasController = CanvasController(nodes: [], wires: []);

    final parsedData = CircuitParser.parse(template.diagramCode);
    CircuitParser.applyToCanvas(
      parsedData,
      canvasController.nodes,
      canvasController.wires,
      components,
    );

    final codeController = CodeLineEditingController.fromText(template.cppCode);
    final diagramCodeController = CodeLineEditingController.fromText(
      template.diagramCode,
    );

    return WorkspaceController(
      canvasController: canvasController,
      codeController: codeController,
      diagramCodeController: diagramCodeController,
      components: components,
      onCircuitError: onCircuitError,
    );
  }

  void dispose() {
    diagramCodeController.removeListener(_syncCodeToCanvas);
    canvasController.removeListener(_syncCanvasToCode);
    canvasController.dispose();
    codeController.dispose();
    diagramCodeController.dispose();
  }

  void _syncCodeToCanvas() {
    if (_isSyncing || _pendingCodeToCanvas) return;
    _pendingCodeToCanvas = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingCodeToCanvas = false;
      if (_isSyncing) return;
      _isSyncing = true;
      try {
        final data = CircuitParser.parse(diagramCodeController.text);
        CircuitParser.applyToCanvas(
          data,
          canvasController.nodes,
          canvasController.wires,
          components,
        );
        canvasController.forceUpdate();
      } catch (e) {
        // Ignore parsing errors
      } finally {
        _isSyncing = false;
      }
    });
  }

  void _syncCanvasToCode() {
    if (_isSyncing || _pendingCanvasToCode) return;
    _pendingCanvasToCode = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingCanvasToCode = false;
      if (_isSyncing) return;
      _isSyncing = true;
      try {
        final outNodeIdMap = <Key, String>{};
        final newText = CircuitParser.generate(
          canvasController.nodes,
          canvasController.wires,
          outNodeIdMap: outNodeIdMap,
        );

        // --- Validation Logic ---
        final netlist = CircuitNetlist();
        netlist.build(canvasController.nodes, canvasController.wires);

        final arduinoNode = canvasController.nodes
            .where((n) => n.componentModel.name == 'Arduino Uno')
            .firstOrNull;

        String? errorMessage;
        if (arduinoNode != null) {
          // First, check for dangerous short circuits across the Arduino itself (e.g. Pin 13 to GND)
          final gndPorts = ['GND_1', 'GND_2', 'GND_3'];
          for (final gndPort in gndPorts) {
            final gndLoc = PortLocation(
              nodeKey: arduinoNode.key,
              portId: gndPort,
            );
            final connectedToGnd = netlist.findConnectedPorts(gndLoc);

            for (final loc in connectedToGnd) {
              if (loc.nodeKey == arduinoNode.key &&
                  (!loc.portId.startsWith('GND') &&
                      loc.portId != 'NC' &&
                      loc.portId != 'AREF' &&
                      loc.portId != 'IOREF' &&
                      loc.portId != 'RESET')) {
                errorMessage =
                    "[Circuit Error] Short Circuit! Arduino pin ${loc.portId} is directly connected to Ground!";
                break;
              }
            }
            if (errorMessage != null) break;
          }

          for (final node in canvasController.nodes) {
            if (node.componentModel.name == 'LED') {
              final anodeLoc = PortLocation(nodeKey: node.key, portId: 'anode');
              final cathodeLoc = PortLocation(
                nodeKey: node.key,
                portId: 'cathode',
              );

              final anodeConnected = netlist.findConnectedPorts(anodeLoc);
              final cathodeConnected = netlist.findConnectedPorts(cathodeLoc);

              bool anodeToGnd = anodeConnected.any(
                (loc) =>
                    loc.nodeKey == arduinoNode.key &&
                    loc.portId.startsWith('GND'),
              );
              bool cathodeToPositive = cathodeConnected.any(
                (loc) =>
                    loc.nodeKey == arduinoNode.key &&
                    (!loc.portId.startsWith('GND') &&
                        loc.portId != 'NC' &&
                        loc.portId != 'IOREF' &&
                        loc.portId != 'RESET' &&
                        loc.portId != 'AREF'),
              );
              bool isShorted = anodeConnected.contains(cathodeLoc);

              if (isShorted) {
                node.properties['hasError'] = true;
                node.properties['isOn'] = false;
                errorMessage =
                    "[Circuit Error] LED is short-circuited! Both legs are connected together.";
              } else if (anodeToGnd && cathodeToPositive) {
                node.properties['hasError'] = true;
                node.properties['isOn'] = false;
                errorMessage =
                    "[Circuit Error] LED connected backwards! Reverse polarity detected.";
              } else {
                if (node.properties['hasError'] == true) {
                  node.properties['hasError'] = false;
                }
                // If not shorted and no error, clear error, but let's NOT overwrite if another LED had an error.
              }
            }
          }
        }

        if (onCircuitError != null) {
          onCircuitError!(errorMessage ?? "");
        }

        if (diagramCodeController.text != newText) {
          diagramCodeController.text = newText;
        }

        CodeLineSelection newSelection = const CodeLineSelection.zero();

        if (canvasController.selectedNodes.isNotEmpty) {
          final id = outNodeIdMap[canvasController.selectedNodes.first.key];
          if (id != null) {
            final lines = newText.split('\n');
            for (int i = 0; i < lines.length; i++) {
              if (lines[i].startsWith("  $id ")) {
                newSelection = CodeLineSelection(
                  baseIndex: i,
                  baseOffset: 0,
                  extentIndex: i,
                  extentOffset: lines[i].length,
                );
                break;
              }
            }
          }
        } else if (canvasController.selectedWireIds.isNotEmpty) {
          final wire = canvasController.wires
              .where((w) => w.id == canvasController.selectedWireIds.first)
              .firstOrNull;
          if (wire != null) {
            final fromId = outNodeIdMap[wire.start.nodeKey];
            final toId = outNodeIdMap[wire.end.nodeKey];
            if (fromId != null && toId != null) {
              final lines = newText.split('\n');
              for (int i = 0; i < lines.length; i++) {
                if (lines[i].contains("$fromId:${wire.start.portId} TO $toId:${wire.end.portId}")) {
                  newSelection = CodeLineSelection(
                    baseIndex: i,
                    baseOffset: 0,
                    extentIndex: i,
                    extentOffset: lines[i].length,
                  );
                  break;
                }
              }
            }
          }
        }

        if (diagramCodeController.selection != newSelection) {
          diagramCodeController.selection = newSelection;
          diagramCodeController.makeCursorCenterIfInvisible();
        }
      } finally {
        _isSyncing = false;
      }
    });
  }
}
