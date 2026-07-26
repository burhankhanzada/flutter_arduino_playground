import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';
import 'package:flutter_arduino_playground/utils/circuit_parser.dart';
import 'package:re_editor/re_editor.dart';

class WorkspaceController {
  final CanvasController canvasController;
  final CodeLineEditingController codeController;
  final CodeLineEditingController diagramCodeController;

  bool _isSyncing = false;
  bool _pendingCodeToCanvas = false;
  bool _pendingCanvasToCode = false;

  WorkspaceController({
    required this.canvasController,
    required this.codeController,
    required this.diagramCodeController,
  }) {
    diagramCodeController.addListener(_syncCodeToCanvas);
    canvasController.addListener(_syncCanvasToCode);
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
        if (diagramCodeController.text != newText) {
          diagramCodeController.text = newText;
        }

        CodeLineSelection newSelection = const CodeLineSelection.zero();

        if (canvasController.selectedNodeKey != null) {
          final id = outNodeIdMap[canvasController.selectedNodeKey!.key];
          if (id != null) {
            final lines = newText.split('\n');
            for (int i = 0; i < lines.length; i++) {
              if (lines[i].contains("id: '$id'")) {
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
        } else if (canvasController.selectedWireId != null) {
          final wire = canvasController.wires
              .where((w) => w.id == canvasController.selectedWireId)
              .firstOrNull;
          if (wire != null) {
            final fromId = outNodeIdMap[wire.start.nodeKey];
            final toId = outNodeIdMap[wire.end.nodeKey];
            if (fromId != null && toId != null) {
              final lines = newText.split('\n');
              for (int i = 0; i < lines.length; i++) {
                if (lines[i].contains("from: '$fromId:${wire.start.portId}'") &&
                    lines[i].contains("to: '$toId:${wire.end.portId}'")) {
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
