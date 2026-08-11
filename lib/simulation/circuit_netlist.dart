import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/models/wire_model.dart';
import 'package:flutter_arduino_playground/ui/components/port_provider.dart';

class CircuitNetlist {
  final Map<PortLocation, Set<PortLocation>> adj = {};

  void _addEdge(PortLocation a, PortLocation b) {
    adj.putIfAbsent(a, () => {}).add(b);
    adj.putIfAbsent(b, () => {}).add(a);
  }

  void build(List<CanvasNodeModel> nodes, List<WireModel> wires) {
    adj.clear();

    // 1. Add explicitly drawn wires
    for (final wire in wires) {
      _addEdge(wire.start, wire.end);
    }

    // 2. Add physical overlaps (components plugged into breadboards or each other)
    for (int i = 0; i < nodes.length; i++) {
      final nodeA = nodes[i];
      
      // Large boards do not physically plug into other boards underneath them.
      // (They must be connected via wires).
      if (nodeA.componentModel.name == 'Arduino Uno' || 
          nodeA.componentModel.name.contains('Breadboard')) {
        continue;
      }

      final painterA = nodeA.componentModel.painter;
      if (painterA is! PortProvider) continue;

      final portProviderA = painterA as PortProvider;
      final portsA = portProviderA.getPorts();

      for (final portA in portsA) {
        final absolutePosA = nodeA.position + portA.localOffset;
        final locA = PortLocation(nodeKey: nodeA.key, portId: portA.id);

        for (int j = 0; j < nodes.length; j++) {
          if (i == j) continue;
          final nodeB = nodes[j];
          final painterB = nodeB.componentModel.painter;
          if (painterB is! PortProvider) continue;
          
          final portProviderB = painterB as PortProvider;

          // Check if nodeB has a port at this exact absolute position
          final localPosB = absolutePosA - nodeB.position;
          
          // Use getPortAt for dynamic ports (like Breadboards)
          var portB = portProviderB.getPortAt(localPosB);
          
          // If getPortAt didn't return anything, check static ports
          if (portB == null) {
             final staticPortsB = portProviderB.getPorts();
             for (final pb in staticPortsB) {
                // Allow a tiny margin of error for floating point inaccuracies
                if ((pb.localOffset - localPosB).distance < 0.1) {
                   portB = pb;
                   break;
                }
             }
          }

          if (portB != null) {
            final locB = PortLocation(nodeKey: nodeB.key, portId: portB.id);
            _addEdge(locA, locB);
          }
        }
      }
    }

    // 3. Resolve internal Breadboard connections
    final breadboardPorts = <Key, List<PortLocation>>{};
    for (final loc in adj.keys) {
      final node = nodes.firstWhere((n) => n.key == loc.nodeKey, orElse: () => nodes.first);
      if (node.componentModel.name.contains('Breadboard')) {
        breadboardPorts.putIfAbsent(node.key, () => []).add(loc);
      }
    }

    for (final entry in breadboardPorts.entries) {
      final locations = entry.value;

      // Group by internal net ID
      final nets = <String, List<PortLocation>>{};
      for (final loc in locations) {
        final netId = _getBreadboardNetId(loc.portId);
        nets.putIfAbsent(netId, () => []).add(loc);
      }

      // Connect all ports in the same net
      for (final netPorts in nets.values) {
        for (int i = 0; i < netPorts.length; i++) {
          for (int j = i + 1; j < netPorts.length; j++) {
            _addEdge(netPorts[i], netPorts[j]);
          }
        }
      }
    }

    // 4. Resolve pass-through components like Resistors
    for (final node in nodes) {
      if (node.componentModel.name == 'Resistor') {
        final locLeft = PortLocation(nodeKey: node.key, portId: 'left');
        final locRight = PortLocation(nodeKey: node.key, portId: 'right');
        _addEdge(locLeft, locRight);
      }
    }
  }

  String _getBreadboardNetId(String portId) {
    if (portId.startsWith('rail_')) {
      final parts = portId.split('_'); // e.g. [rail, left, plus, 0]
      if (parts.length >= 3) {
        return '${parts[0]}_${parts[1]}_${parts[2]}'; // rail_left_plus
      }
    } else if (portId.startsWith('sig_')) {
      final parts = portId.split('_'); // e.g. [sig, left, a, 5]
      if (parts.length >= 4) {
        return '${parts[0]}_${parts[1]}_${parts[3]}'; // sig_left_5
      }
    }
    return portId;
  }

  Set<PortLocation> findConnectedPorts(PortLocation start) {
    final visited = <PortLocation>{};
    final queue = <PortLocation>[start];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.contains(current)) continue;
      
      visited.add(current);
      
      final neighbors = adj[current];
      if (neighbors != null) {
        queue.addAll(neighbors.where((n) => !visited.contains(n)));
      }
    }

    return visited;
  }
}
