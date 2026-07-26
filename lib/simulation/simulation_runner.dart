import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';
import 'package:flutter_arduino_playground/models/wire_model.dart';
import 'package:flutter_arduino_playground/ui/components/led_painter.dart';

class SimulationRunner {
  final CanvasController canvasController;
  final void Function(String)? onSerialPrint;
  bool isSimulating = false;
  bool isPaused = false;

  SimulationRunner({required this.canvasController, this.onSerialPrint});

  void stop() {
    isSimulating = false;
    isPaused = false;
    // Turn off all LEDs when stopping
    for (final node in canvasController.nodes) {
      if (node.componentModel.name == 'LED') {
        (node.componentModel.painter as LEDPainter).isOn = false;
      }
    }
    canvasController.forceUpdate();
  }

  void start(String code, void Function() onStop) {
    if (isSimulating) return;
    isSimulating = true;
    isPaused = false;
    _runLoop(code, onStop);
  }

  void pause() {
    if (isSimulating) {
      isPaused = true;
    }
  }

  void resume() {
    if (isSimulating) {
      isPaused = false;
    }
  }

  LEDPainter? _getLedPainterForPin(String pin) {
    final arduinoNode = canvasController.nodes.firstWhere(
      (n) => n.componentModel.name == 'Arduino Uno',
    );

    // Find wire connected to arduino pin
    WireModel? wire1;
    bool isStartAtArduino = true;
    for (var w in canvasController.wires) {
      if (w.start.nodeKey == arduinoNode.key && w.start.portId == pin) {
        wire1 = w;
        break;
      }
      if (w.end.nodeKey == arduinoNode.key && w.end.portId == pin) {
        wire1 = w;
        isStartAtArduino = false;
        break;
      }
    }
    if (wire1 == null) return null;

    final nextNodeKey = isStartAtArduino
        ? wire1.end.nodeKey
        : wire1.start.nodeKey;
    final nextNode = canvasController.nodes.firstWhere(
      (n) => n.key == nextNodeKey,
    );

    if (nextNode.componentModel.name == 'LED') {
      return nextNode.componentModel.painter as LEDPainter;
    }

    if (nextNode.componentModel.name == 'Resistor') {
      final resistorPortConnected = isStartAtArduino
          ? wire1.end.portId
          : wire1.start.portId;
      final otherPortId = resistorPortConnected == 'left' ? 'right' : 'left';

      WireModel? wire2;
      bool isStartAtResistor = true;
      for (var w in canvasController.wires) {
        if (w.start.nodeKey == nextNode.key && w.start.portId == otherPortId) {
          wire2 = w;
          break;
        }
        if (w.end.nodeKey == nextNode.key && w.end.portId == otherPortId) {
          wire2 = w;
          isStartAtResistor = false;
          break;
        }
      }
      if (wire2 == null) return null;

      final ledNodeKey = isStartAtResistor
          ? wire2.end.nodeKey
          : wire2.start.nodeKey;
      final ledNode = canvasController.nodes.firstWhere(
        (n) => n.key == ledNodeKey,
      );

      if (ledNode.componentModel.name == 'LED')
        return ledNode.componentModel.painter as LEDPainter;
    }
    return null;
  }

  Future<void> _runLoop(String code, void Function() onStop) async {
    final loopRegex = RegExp(r'void\s+loop\(\)\s*\{([^}]*)\}');
    final match = loopRegex.firstMatch(code);
    if (match == null) {
      isSimulating = false;
      onStop();
      return;
    }

    // Strip comments
    final cleanBody = match.group(1)!.replaceAll(RegExp(r'//.*'), '');
    final statements = cleanBody
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    while (isSimulating) {
      if (statements.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      bool didAwait = false;
      for (final statement in statements) {
        while (isSimulating && isPaused) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        if (!isSimulating) break;

        if (statement.startsWith('digitalWrite')) {
          final pinMatch = RegExp(
            r'digitalWrite\(\s*(\w+)\s*,\s*(HIGH|LOW)\s*\)',
          ).firstMatch(statement);
          if (pinMatch != null) {
            final pin = pinMatch.group(1)!;
            final isHigh = pinMatch.group(2) == 'HIGH';

            final ledPainter = _getLedPainterForPin(pin);
            if (ledPainter != null) {
              ledPainter.isOn = isHigh;
              canvasController.forceUpdate();
            }
          }
        } else if (statement.startsWith('Serial.print')) {
          final printMatch = RegExp(
            r'Serial\.print(?:ln)?\(\s*"(.*?)"\s*\)',
          ).firstMatch(statement);
          if (printMatch != null) {
            final text = printMatch.group(1)!;
            onSerialPrint?.call(text);
          }
        } else if (statement.startsWith('delay')) {
          final delayMatch = RegExp(
            r'delay\(\s*(\d+)\s*\)',
          ).firstMatch(statement);
          if (delayMatch != null) {
            final ms = int.tryParse(delayMatch.group(1)!) ?? 1000;
            await Future.delayed(Duration(milliseconds: ms));
            didAwait = true;
          }
        }
      }

      // Safety yield: if the user's code had no delay() statements,
      // we MUST sleep to prevent locking the main thread!
      if (!didAwait) {
        await Future.delayed(const Duration(milliseconds: 50));
      } else {
        await Future.delayed(Duration.zero);
      }
    }
    onStop();
  }
}
