import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';

class WireColorDropDownMenu extends StatefulWidget {
  final CanvasController controller;
  const WireColorDropDownMenu({super.key, required this.controller});

  @override
  State<WireColorDropDownMenu> createState() => _WireColorDropDownMenuState();
}

class _WireColorDropDownMenuState extends State<WireColorDropDownMenu> {
  String selectedColorName = 'Auto';

  final Map<String, Color?> colors = {
    'Auto': null,
    'Black': Colors.black,
    'Red': Colors.red,
    'Orange': Colors.orange,
    'Amber': Colors.amber,
    'Yellow': Colors.yellow,
    'Lime': Colors.lime,
    'Green': Colors.green,
    'Teal': Colors.teal,
    'Cyan': Colors.cyan,
    'Blue': Colors.blue,
    'Indigo': Colors.indigo,
    'Purple': Colors.purple,
    'Pink': Colors.pink,
    'Brown': Colors.brown,
    'Grey': Colors.grey,
    'White': Colors.white,
  };

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncColorWithController);
    // Initial sync
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

    if (controller.selectedWireId != null) {
      final wireIndex = controller.wires.indexWhere((w) => w.id == controller.selectedWireId);
      if (wireIndex != -1) {
        targetColor = controller.wires[wireIndex].color;
      }
    }

    String newName = 'Auto';
    for (final entry in colors.entries) {
      if (entry.value?.value == targetColor?.value) {
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

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedColorName,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              selectedColorName = newValue;
            });
            widget.controller.updateWireColor(colors[newValue]);
          }
        },
        items: colors.entries.map((entry) {
          Widget colorCircle;
          if (entry.key == 'Auto') {
            colorCircle = Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
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
                  ],
                ),
              ),
            );
          } else {
            colorCircle = CircleAvatar(
              radius: 10,
              backgroundColor: entry.value,
            );
          }

          return DropdownMenuItem<String>(
            value: entry.key,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [colorCircle, Text(entry.key)],
            ),
          );
        }).toList(),
      ),
    );
  }
}
