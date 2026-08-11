import 'package:flutter/foundation.dart';

import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';
import 'package:flutter_arduino_playground/simulation/circuit_netlist.dart';
import 'package:flutter_arduino_playground/simulation/avr_interop.dart';
import 'package:flutter_arduino_playground/simulation/spice/spice_engine.dart';
import 'package:flutter_arduino_playground/services/compiler_service.dart';

class SimulationRunner {
  final CanvasController canvasController;
  final void Function(String)? onSerialPrint;
  final void Function(String)? onSpiceLog;
  bool isSimulating = false;
  bool isPaused = false;
  late CircuitNetlist _netlist;
  late SpiceEngine _spiceEngine;
  final Map<Key, double> _lastLoggedCurrent = {};

  SimulationRunner({
    required this.canvasController,
    this.onSerialPrint,
    this.onSpiceLog,
  });

  void stop() {
    isSimulating = false;
    isPaused = false;
    AVRBridge.onSerialByte = null;
    for (final node in canvasController.nodes) {
      if (node.componentModel.name == 'LED') {
        node.properties['isOn'] = false;
        node.properties['hasError'] = false;
      }
    }
    canvasController.forceUpdate();
  }

  Future<bool> start(String code, void Function() onStop) async {
    if (isSimulating) return false;

    onSerialPrint?.call("Compiling sketch with arduino-cli...\n");
    String compiledHex;
    try {
      compiledHex = await CompilerService.compile(code);
    } catch (e) {
      onSerialPrint?.call("Compilation Failed:\n${e.toString()}\n");
      return false;
    }

    try {
      isSimulating = true;
      isPaused = false;

      _netlist = CircuitNetlist();
      _netlist.build(canvasController.nodes, canvasController.wires);

      _lastLoggedCurrent.clear();
      _spiceEngine = SpiceEngine(onLog: onSpiceLog);
      _spiceEngine.build(_netlist, canvasController.nodes);

      // Launch run loop asynchronously
      _runLoop(compiledHex, onStop);
      return true;
    } catch (e) {
      onSerialPrint?.call("Simulation Initialization Failed:\n${e.toString()}\n");
      isSimulating = false;
      return false;
    }
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

  void _updateAnalogLeds() {
    var changed = false;

    for (final node in canvasController.nodes) {
      if (node.componentModel.name != 'LED') continue;

      final props = node.properties;
      final current = _spiceEngine.getLedCurrent(node.key.toString());

      // The sense source is oriented anode-side (+) to cathode-side (-), so
      // its branch current is already positive for forward LED current.
      final forwardCurrent = current;

      if (forwardCurrent != _lastLoggedCurrent[node.key]) {
        _lastLoggedCurrent[node.key] = forwardCurrent;
        onSpiceLog?.call("LED ${node.key} current: $forwardCurrent A\n");
      }

      final bool isOn;
      final bool hasError;
      if (forwardCurrent > 0.001) {
        isOn = true;
        hasError = false;
      } else if (forwardCurrent < -0.005) {
        isOn = false;
        hasError = true;
        onSpiceLog?.call("ERROR: LED reverse breakdown current detected.\n");
      } else {
        isOn = false;
        hasError = false;
      }

      if (props['isOn'] != isOn || props['hasError'] != hasError) {
        props['isOn'] = isOn;
        props['hasError'] = hasError;
        changed = true;
      }
    }

    // Repainting the whole canvas 60x a second when nothing changed starves
    // the run loop of the very frames it needs to advance the emulator.
    if (changed) canvasController.forceUpdate();
  }

  Future<void> _runLoop(String compiledHex, void Function() onStop) async {
    try {
      // 1. Load the freshly compiled HEX file into the JS AVR Bridge
      AVRBridge.onSerialByte = (text) => onSerialPrint?.call(text);
      AVRBridge.loadHex(compiledHex);
    } catch (e) {
      onSerialPrint?.call("Error loading HEX: ${e.toString()}\n");
      isSimulating = false;
      onStop();
      return;
    }

    onSerialPrint?.call("Running real AVR execution of sketch...\n");

    // The ATmega328p on an Uno runs at 16 MHz. Rather than assuming a fixed
    // budget per frame, pace the emulator off the wall clock so a delay(1000)
    // takes about a second no matter how fast the host executes instructions.
    const int cyclesPerMicrosecond = 16;
    const int maxCatchUpUs = 50000; // never try to make up more than 50 ms
    bool lastState = false;

    final clock = Stopwatch()..start();
    int lastElapsedUs = clock.elapsedMicroseconds;

    while (isSimulating) {
      while (isSimulating && isPaused) {
        await Future.delayed(const Duration(milliseconds: 100));
        // Time spent paused is not simulated time.
        lastElapsedUs = clock.elapsedMicroseconds;
      }
      if (!isSimulating) break;

      try {
        // 2. Advance the emulator by however much real time has passed,
        //    clamped so a slow frame cannot spiral into an ever-growing debt.
        final nowUs = clock.elapsedMicroseconds;
        var deltaUs = nowUs - lastElapsedUs;
        lastElapsedUs = nowUs;
        if (deltaUs > maxCatchUpUs) deltaUs = maxCatchUpUs;
        if (deltaUs > 0) {
          AVRBridge.runCycles(deltaUs * cyclesPerMicrosecond);
        }

        // 3. Read Pin 13 state and update SPICE voltage source
        final isHigh = AVRBridge.getPin13State();
        if (isHigh != lastState) {
          onSerialPrint?.call("Pin 13 hardware state changed to: $isHigh\n");
          lastState = isHigh;
        }

        _spiceEngine.setPinVoltage('13', isHigh ? 5.0 : 0.0);

        // 4. Solve the analog circuit
        _spiceEngine.solve();

        // 5. Update LEDs based on analog currents
        _updateAnalogLeds();

        // Yield to Flutter to render the frame
        await Future.delayed(const Duration(milliseconds: 16));
      } catch (e) {
        onSpiceLog?.call("Emulator/SPICE crashed: ${e.toString()}\n");
        break;
      }
    }

    onStop();
  }
}
