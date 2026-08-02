import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';

const colorWheel = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.indigo,
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
];

const colorsLsit = [
  ...colorWheel,
  Colors.brown,
  Colors.grey,
  Colors.black,
  Colors.white,
];

class WireColorDropDownMenu extends StatefulWidget {
  final CanvasController controller;
  const WireColorDropDownMenu({super.key, required this.controller});

  @override
  State<WireColorDropDownMenu> createState() => _WireColorDropDownMenuState();
}

class _WireColorDropDownMenuState extends State<WireColorDropDownMenu> {
  String selectedColorName = 'Auto';

  final Map<String, Color?> colorsMap = {
    'Auto': null,
    'Red': colorsLsit[0],
    'Pink': colorsLsit[1],
    'Purple': colorsLsit[2],
    'Indigo': colorsLsit[3],
    'Blue': colorsLsit[4],
    'Cyan': colorsLsit[5],
    'Teal': colorsLsit[6],
    'Green': colorsLsit[7],
    'Lime': colorsLsit[8],
    'Yellow': colorsLsit[9],
    'Amber': colorsLsit[10],
    'Orange': colorsLsit[11],
    'Brown': colorsLsit[12],
    'Grey': colorsLsit[13],
    'Black': colorsLsit[14],
    'White': colorsLsit[15],
  };

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncColorWithController);
    _syncColorWithController();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncColorWithController);
    super.dispose();
  }

  @override
  void didUpdateWidget(WireColorDropDownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncColorWithController);
      widget.controller.addListener(_syncColorWithController);
    }
  }

  void _syncColorWithController() {
    final controller = widget.controller;
    Color? targetColor = controller.currentWireColor;

    final wireIndex = controller.wires.indexWhere(
      (w) => w.id == controller.selectedWireId,
    );
    if (wireIndex != -1) {
      targetColor = controller.wires[wireIndex].color;
    }

    String newName = 'Auto';
    for (final entry in colorsMap.entries) {
      if (entry.value?.toARGB32() == targetColor?.toARGB32()) {
        newName = entry.key;
        break;
      }
    }

    if (newName != selectedColorName) {
      setState(() {
        selectedColorName = newName;
      });
    }
  }

  Widget _buildColorCircle(MapEntry<String, Color?> entry) {
    if (entry.key == 'Auto') {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: colorWheel,
            transform: GradientRotation(-math.pi / 2),
          ),
        ),
      );
    } else {
      return CircleAvatar(radius: 10, backgroundColor: entry.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedEntry = MapEntry(
      selectedColorName,
      colorsMap[selectedColorName],
    );

    return PopupMenuButton<String>(
      constraints: const BoxConstraints(maxHeight: 250),
      tooltip: 'Wire Color',
      initialValue: selectedColorName,
      onSelected: (String newValue) {
        setState(() {
          selectedColorName = newValue;
        });
        widget.controller.updateWireColor(colorsMap[newValue]);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildColorCircle(selectedEntry),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return colorsMap.entries.map((entry) {
          return PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                _buildColorCircle(entry),
                const SizedBox(width: 12),
                Text(entry.key),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
