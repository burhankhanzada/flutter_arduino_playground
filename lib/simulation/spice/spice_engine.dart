import 'package:flutter/material.dart';
import 'package:ngspice_dart/ngspice_dart.dart';

import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/simulation/circuit_netlist.dart';

class SpiceEngine {
  final Ngspice _ngspice = Ngspice();
  final Map<PortLocation, int> _portToNode = {};

  final Map<String, double> _pinVoltages = {};
  final List<String> _ledKeys = [];
  final Map<String, double> _ledCurrents = {};

  /// Set when a pin voltage changed and the operating point is stale.
  bool _dirty = true;

  /// Optional sink for netlist/solver diagnostics.
  final void Function(String)? onLog;

  SpiceEngine({this.onLog}) {
    _ngspice.init();
  }

  void build(CircuitNetlist netlist, List<CanvasNodeModel> nodes) {
    _pinVoltages.clear();
    _ledKeys.clear();
    _ledCurrents.clear();
    _portToNode.clear();
    _dirty = true;

    int nextNodeId = 1;
    final visitedPorts = <PortLocation>{};

    // Find Ground ports
    final groundPorts = <PortLocation>{};
    for (final loc in netlist.adj.keys) {
      if (loc.portId.startsWith('GND') || loc.portId.contains('minus')) {
        groundPorts.addAll(netlist.findConnectedPorts(loc));
      }
    }

    for (final loc in groundPorts) {
      _portToNode[loc] = 0;
      visitedPorts.add(loc);
    }

    for (final loc in netlist.adj.keys) {
      if (!visitedPorts.contains(loc)) {
        final netPorts = netlist.findConnectedPorts(loc);
        for (final p in netPorts) {
          _portToNode[p] = nextNodeId;
          visitedPorts.add(p);
        }
        nextNodeId++;
      }
    }

    List<String> circArray = ['* Flutter Arduino Playground Simulation'];

    CanvasNodeModel? arduinoNode;

    for (final node in nodes) {
      final name = node.componentModel.name;
      final keyStr = node.key.toString().replaceAll(
        RegExp(r'[^a-zA-Z0-9]'),
        '_',
      );

      // Legacy fallback
      if (name == 'Arduino Uno') {
        arduinoNode = node;
      } else if (name == 'Resistor') {
        final n1 = _getNode(node.key, 'left');
        final n2 = _getNode(node.key, 'right');
        // A resistor whose terminals land on the same net (or that is not
        // wired up at all) is not a valid ngspice element.
        if (n1 == n2) continue;
        circArray.add('R_$keyStr ${_net(n1)} ${_net(n2)} 220');
      } else if (name == 'LED') {
        final n1 = _getNode(node.key, 'anode');
        final n2 = _getNode(node.key, 'cathode');
        if (n1 == n2) continue;
        circArray.add('.model D_$keyStr D(Is=1e-14 N=1.5)');
        circArray.add('D_$keyStr ${_net(n1)} n_int_$keyStr D_$keyStr');
        // 0 V source used purely as a current sense element.
        circArray.add('V_led_$keyStr n_int_$keyStr ${_net(n2)} 0');
        _ledKeys.add(node.key.toString());
      }
    }

    if (arduinoNode != null) {
      const pins = [
        '0', '1', '2', '3', '4', '5', '6', '7',
        '8', '9', '10', '11', '12', '13',
        'A0', 'A1', 'A2', 'A3', 'A4', 'A5',
      ];
      for (final pin in pins) {
        final n1 = _getNode(arduinoNode.key, pin);
        // Only drive pins that are actually wired to something. Emitting a
        // source for every pin puts a whole bank of 0 V sources in parallel
        // across ground, which makes the DC solution singular.
        if (n1 == 0) continue;
        circArray.add('V_uno_$pin ${_net(n1)} 0 0.0');
        _pinVoltages[pin] = 0.0;
      }
    }

    circArray.add('.op');
    circArray.add('.end');

    // Reset ngspice to clear old circuit
    _ngspice.command('destroy all');
    final rc = _ngspice.circuit(circArray);
    if (rc != 0) {
      onLog?.call('ngspice rejected the netlist (code $rc):\n'
          '${circArray.join('\n')}\n');
    }
  }

  /// ngspice node name for an internal net id. Net 0 is the global ground,
  /// which must be spelled `0` rather than given a name of its own.
  String _net(int id) => id == 0 ? '0' : 'n_$id';

  int _getNode(Key nodeKey, String portId) {
    return _portToNode[PortLocation(nodeKey: nodeKey, portId: portId)] ?? 0;
  }

  void setPinVoltage(String pin, double voltage) {
    // Pins with no source in the deck cannot be altered.
    if (!_pinVoltages.containsKey(pin)) return;
    if (_pinVoltages[pin] == voltage) return;
    _pinVoltages[pin] = voltage;
    _dirty = true;
  }

  /// Re-solves the operating point, but only when a pin voltage actually
  /// changed. Solving on every frame is pure waste for digital circuits.
  void solve() {
    if (!_dirty) return;
    _dirty = false;

    for (final entry in _pinVoltages.entries) {
      _ngspice.command('alter V_uno_${entry.key} = ${entry.value}');
    }
    _ngspice.command('op');

    // Read every sense current while this plot is still current...
    for (final key in _ledKeys) {
      final keyStr = key.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      // ngGet_Vec_Info resolves raw vector names, not `i(...)` expressions.
      // A voltage source's branch current is exposed as `<name>#branch`, and
      // ngspice folds all identifiers to lower case.
      final vec = _ngspice.getVector('v_led_$keyStr#branch'.toLowerCase());
      _ledCurrents[key] =
          (vec != null && vec.isNotEmpty) ? vec.last : 0.0;
    }

    // ...then drop it. Every `op` allocates a new plot that ngspice keeps
    // forever, and the per-solve cost grows quadratically with the number of
    // retained plots -- after a few hundred frames the loop crawls.
    _ngspice.command('destroy all');
  }

  double getLedCurrent(String key) => _ledCurrents[key] ?? 0.0;
}
