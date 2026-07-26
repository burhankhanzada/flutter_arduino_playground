import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/models/circuit_model.dart';
import 'package:flutter_arduino_playground/models/wire_model.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/constants.dart';
import 'package:flutter_arduino_playground/ui/components/led_painter.dart';

class CircuitParser {
  static CircuitData parse(String code) {
    final parts = <PartData>[];
    final wires = <WireData>[];

    // Parser for Part(type: '...', id: '...', x: ..., y: ..., rotate: ..., flipHorizontal: ..., flipVertical: ...)
    final partRegex = RegExp(r"Part\(([^)]+)\)");
    for (final match in partRegex.allMatches(code)) {
      final body = match.group(1)!;

      final typeMatch = RegExp(r"type:\s*'([^']+)'").firstMatch(body);
      final idMatch = RegExp(r"id:\s*'([^']+)'").firstMatch(body);
      final xMatch = RegExp(r"x:\s*([-\d.]+)").firstMatch(body);
      final yMatch = RegExp(r"y:\s*([-\d.]+)").firstMatch(body);
      final colorMatch = RegExp(r"color:\s*'([^']+)'").firstMatch(body);
      final rotateMatch = RegExp(
        r"(?:rotate|rotationAngle):\s*([-\d.]+)",
      ).firstMatch(body);
      final flipHMatch = RegExp(
        r"flipHorizontal:\s*(true|false)",
      ).firstMatch(body);
      final flipVMatch = RegExp(
        r"flipVertical:\s*(true|false)",
      ).firstMatch(body);

      if (typeMatch != null &&
          idMatch != null &&
          xMatch != null &&
          yMatch != null) {
        parts.add(
          PartData(
            type: typeMatch.group(1)!,
            id: idMatch.group(1)!,
            x: double.tryParse(xMatch.group(1)!) ?? 0,
            y: double.tryParse(yMatch.group(1)!) ?? 0,
            color: colorMatch?.group(1),
            rotate: double.tryParse(rotateMatch?.group(1) ?? '') ?? 0.0,
            flipHorizontal: flipHMatch?.group(1) == 'true',
            flipVertical: flipVMatch?.group(1) == 'true',
          ),
        );
      }
    }

    // Regex for Wire
    final wireRegex = RegExp(
      r"Wire\(\s*from:\s*'([^']+)'\s*,\s*to:\s*'([^']+)'\s*(?:,\s*color:\s*'([^']+)'\s*)?(?:,\s*bendPoints:\s*\[([^\]]*)\])?\s*\)",
    );
    for (final match in wireRegex.allMatches(code)) {
      final fromFull = match.group(1)!;
      final toFull = match.group(2)!;
      final colorStr = match.group(3) ?? 'green';
      final bendPointsStr = match.group(4) ?? '';

      final fromParts = fromFull.split(':');
      final toParts = toFull.split(':');

      if (fromParts.length == 2 && toParts.length == 2) {
        final bendPoints = <Offset>[];
        final offsetRegex = RegExp(
          r"Offset\(\s*([-\d.]+)\s*,\s*([-\d.]+)\s*\)",
        );
        for (final offsetMatch in offsetRegex.allMatches(bendPointsStr)) {
          bendPoints.add(
            Offset(
              double.tryParse(offsetMatch.group(1)!) ?? 0,
              double.tryParse(offsetMatch.group(2)!) ?? 0,
            ),
          );
        }

        wires.add(
          WireData(
            fromId: fromParts[0],
            fromPort: fromParts[1],
            toId: toParts[0],
            toPort: toParts[1],
            color: colorStr,
            bendPoints: bendPoints,
          ),
        );
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
    buffer.writeln('Circuit(');
    buffer.writeln('  parts: [');

    // Map LocalKey to a readable ID
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

      final extraProps = <String>[];
      if (node.componentModel.name == 'LED' &&
          node.componentModel.painter is LEDPainter) {
        final ledPainter = node.componentModel.painter as LEDPainter;
        final colorName = _colorToName(ledPainter.color);
        extraProps.add("color: '$colorName'");
      }
      if (node.rotationAngle != 0.0) {
        final formattedAngle = double.parse(
          node.rotationAngle.toStringAsFixed(4),
        );
        extraProps.add('rotate: $formattedAngle');
      }
      if (node.flipHorizontal) {
        extraProps.add('flipHorizontal: true');
      }
      if (node.flipVertical) {
        extraProps.add('flipVertical: true');
      }

      final extraStr = extraProps.isNotEmpty
          ? ', ${extraProps.join(', ')}'
          : '';
      buffer.writeln(
        '    Part(type: \'${node.componentModel.name}\', id: \'$id\', x: ${node.position.dx}, y: ${node.position.dy}$extraStr),',
      );
    }
    buffer.writeln('  ],');
    buffer.writeln('  wires: [');

    for (final wire in wires) {
      final fromId = idMap[wire.start.nodeKey];
      final toId = idMap[wire.end.nodeKey];
      if (fromId == null || toId == null) continue;

      final colorName = _colorToName(wire.color);

      String bendPointsStr = '';
      if (wire.bendPoints.isNotEmpty) {
        bendPointsStr =
            ', bendPoints: [${wire.bendPoints.map((p) => 'Offset(${p.dx}, ${p.dy})').join(', ')}]';
      }

      buffer.writeln(
        '    Wire(from: \'$fromId:${wire.start.portId}\', to: \'$toId:${wire.end.portId}\', color: \'$colorName\'$bendPointsStr),',
      );
    }
    buffer.writeln('  ]');
    buffer.writeln(')');
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
  ) {
    outNodes.clear();
    outWires.clear();

    final idToKey = <String, Key>{};

    for (final part in data.parts) {
      try {
        final componentModel = components
            .firstWhere((c) => c.name == part.type)
            .clone();
        if (componentModel.painter is LEDPainter && part.color != null) {
          (componentModel.painter as LEDPainter).color = _nameToColor(
            part.color!,
          );
        }

        final key = UniqueKey();
        idToKey[part.id] = key;

        outNodes.add(
          CanvasNodeModel(
            key: key,
            position: Offset(part.x, part.y),
            componentModel: componentModel,
            rotationAngle: part.rotate,
            flipHorizontal: part.flipHorizontal,
            flipVertical: part.flipVertical,
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
