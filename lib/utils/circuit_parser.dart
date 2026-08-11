import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/models/circuit_model.dart';
import 'package:flutter_arduino_playground/models/wire_model.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/ui/components/led_painter.dart';

class CircuitParser {
  static CircuitData parse(String code) {
    final parts = <PartData>[];
    final wires = <WireData>[];

    String currentSection = '';
    final lines = code.split('\n');
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('//')) continue;

      if (line.startsWith('CIRCUIT ')) {
        continue;
      } else if (line == 'PARTS' || line == 'WIRES') {
        currentSection = line;
      } else {
        if (currentSection == 'PARTS') {
          final partRegex = RegExp(r'^(\w+)\s+"([^"]+)"\s+AT\s+([-\d.]+)\s+([-\d.]+)(?:\s+PROPERTIES\s+\{(.+)\})?');
          final match = partRegex.firstMatch(line);
          if (match != null) {
            final id = match.group(1)!;
            final type = match.group(2)!;
            final x = double.tryParse(match.group(3)!) ?? 0;
            final y = double.tryParse(match.group(4)!) ?? 0;
            
            Map<String, dynamic>? properties;
            final propsStr = match.group(5);
            if (propsStr != null && propsStr.trim().isNotEmpty) {
              properties = {};
              final pairs = propsStr.split(',');
              for (final pair in pairs) {
                final kv = pair.split(':');
                if (kv.length == 2) {
                  final key = kv[0].trim();
                  final value = kv[1].replaceAll('"', '').trim();
                  properties[key] = value;
                }
              }
            }
            parts.add(PartData(id: id, type: type, x: x, y: y, properties: properties));
          }
        } else if (currentSection == 'WIRES') {
          final wireRegex = RegExp(r'^(\w+):([^\s]+)\s+TO\s+(\w+):([^\s]+)(?:\s+COLOR\s+(\w+))?(?:\s+BEND\s+\[(.*?)\])?');
          final match = wireRegex.firstMatch(line);
          if (match != null) {
            final fromId = match.group(1)!;
            final fromPort = match.group(2)!;
            final toId = match.group(3)!;
            final toPort = match.group(4)!;
            final color = match.group(5) ?? 'green';
            
            final bendPoints = <Offset>[];
            final bendStr = match.group(6);
            if (bendStr != null && bendStr.isNotEmpty) {
              final points = bendStr.split(' ');
              for (final p in points) {
                if (p.trim().isEmpty) continue;
                final xy = p.split(',');
                if (xy.length == 2) {
                  bendPoints.add(Offset(
                    double.tryParse(xy[0]) ?? 0,
                    double.tryParse(xy[1]) ?? 0,
                  ));
                }
              }
            }
            
            wires.add(WireData(
              fromId: fromId,
              fromPort: fromPort,
              toId: toId,
              toPort: toPort,
              color: color,
              bendPoints: bendPoints,
            ));
          }
        }
      }
    }

    return CircuitData(parts: parts, wires: wires);
  }

  static String generate(
    List<CanvasNodeModel> nodes,
    List<WireModel> wires, {
    Map<Key, String>? outNodeIdMap,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('CIRCUIT "My Circuit"');
    buffer.writeln('');
    buffer.writeln('PARTS');
    
    final idMap = <Key, String>{};

    int unoCount = 1;
    int ledCount = 1;
    int resistorCount = 1;
    int otherCount = 1;

    for (final node in nodes) {
      String id;
      if (node.componentModel.name == 'Arduino Uno') {
        id = 'uno${unoCount == 1 ? '' : unoCount}';
        unoCount++;
      } else if (node.componentModel.name == 'LED') {
        id = 'led$ledCount';
        ledCount++;
      } else if (node.componentModel.name == 'Resistor') {
        id = 'r$resistorCount';
        resistorCount++;
      } else {
        id = 'part$otherCount';
        otherCount++;
      }
      idMap[node.key] = id;
      if (outNodeIdMap != null) outNodeIdMap[node.key] = id;

      String propsStr = '';
      if (node.properties.isNotEmpty) {
        final propsList = node.properties.entries.map((e) => "${e.key}: \"${e.value}\"").join(', ');
        propsStr = ' PROPERTIES {$propsList}';
      }

      buffer.writeln('  $id "${node.componentModel.name}" AT ${node.position.dx.toStringAsFixed(1)} ${node.position.dy.toStringAsFixed(1)}$propsStr');
    }
    buffer.writeln('');
    buffer.writeln('WIRES');

    for (final wire in wires) {
      final fromId = idMap[wire.start.nodeKey];
      final toId = idMap[wire.end.nodeKey];
      if (fromId == null || toId == null) continue;

      final colorName = _colorToName(wire.color);

      String bendPointsStr = '';
      if (wire.bendPoints.isNotEmpty) {
        bendPointsStr = ' BEND [${wire.bendPoints.map((p) => '${p.dx.toStringAsFixed(1)},${p.dy.toStringAsFixed(1)}').join(' ')}]';
      }

      buffer.writeln('  $fromId:${wire.start.portId} TO $toId:${wire.end.portId} COLOR $colorName$bendPointsStr');
    }
    return buffer.toString();
  }

  static String _colorToName(Color color) {
    final argb = color.toARGB32();
    if (argb == Colors.red.toARGB32()) return 'red';
    if (argb == Colors.black.toARGB32()) return 'black';
    if (argb == Colors.blue.toARGB32()) return 'blue';
    if (argb == Colors.green.toARGB32()) return 'green';
    if (argb == Colors.yellow.toARGB32()) return 'yellow';
    if (argb == Colors.orange.toARGB32()) return 'orange';
    if (argb == Colors.purple.toARGB32()) return 'purple';
    if (argb == Colors.white.toARGB32()) return 'white';
    if (argb == Colors.grey.toARGB32()) return 'grey';
    return 'red';
  }

  static Color _nameToColor(String name) {
    switch (name.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'black':
        return Colors.black;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'white':
        return Colors.white;
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  static void applyToCanvas(
    CircuitData data,
    List<CanvasNodeModel> outNodes,
    List<WireModel> outWires,
    List<ComponentModel> components,
  ) {
    outNodes.clear();
    outWires.clear();

    final idToKey = <String, Key>{};

    for (final part in data.parts) {
      try {
        final componentModel = components
            .firstWhere((c) => c.name == part.type)
            .clone();
        final ledColor = part.properties?['color'] ?? part.properties?['Color'];
        if (componentModel.painter is LEDPainter && ledColor != null) {
          (componentModel.painter as LEDPainter).color = _nameToColor(
            ledColor.toString(),
          );
        }

        final key = UniqueKey();
        idToKey[part.id] = key;

        outNodes.add(
          CanvasNodeModel(
            key: key,
            position: Offset(part.x, part.y),
            componentModel: componentModel,
            rotationAngle: part.rotation,
            properties: part.properties,
          ),
        );
      } catch (_) {
        // Component type not found
      }
    }

    for (final wire in data.wires) {
      final startKey = idToKey[wire.fromId];
      final endKey = idToKey[wire.toId];
      if (startKey != null && endKey != null) {
        outWires.add(
          WireModel(
            id: UniqueKey().toString(),
            start: PortLocation(nodeKey: startKey, portId: wire.fromPort),
            end: PortLocation(nodeKey: endKey, portId: wire.toPort),
            color: _nameToColor(wire.color),
            bendPoints: wire.bendPoints,
          ),
        );
      }
    }
  }
}
