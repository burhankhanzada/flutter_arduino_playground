import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';

class ComponentPropertiesPanel extends StatelessWidget {
  final CanvasController controller;
  final CanvasNodeModel? selectedNode;

  const ComponentPropertiesPanel({
    super.key, 
    required this.controller,
    required this.selectedNode,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedNode == null) {
      return const Center(
        child: Text('No component selected', style: TextStyle(color: Colors.grey)),
      );
    }

    final node = selectedNode!;
    final comp = node.componentModel;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Properties',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildStaticRow('Name', comp.name),
            const Divider(),
            _buildNumberInput('Position X', node.position.dx, (val) {
              controller.updateNode(node.key, position: Offset(val, node.position.dy));
            }),
            _buildNumberInput('Position Y', node.position.dy, (val) {
              controller.updateNode(node.key, position: Offset(node.position.dx, val));
            }),
            const Divider(),
            _buildNumberInput('Rotation (°)', (node.rotationAngle * 180 / pi), (val) {
              controller.updateNode(node.key, rotationAngle: val * pi / 180);
            }),
            _buildSwitchRow('Flipped H', node.flipHorizontal, (val) {
              controller.updateNode(node.key, flipHorizontal: val);
            }),
            _buildSwitchRow('Flipped V', node.flipVertical, (val) {
              controller.updateNode(node.key, flipVertical: val);
            }),
            const Divider(),
            _buildNumberInputWithReset(
              'Width',
              node.customWidth ?? comp.size.width,
              comp.size.width,
              (val) {
                controller.updateNode(node.key, customWidth: val);
              },
              () {
                controller.updateNode(node.key, clearCustomWidth: true);
              },
            ),
            _buildNumberInputWithReset(
              'Height',
              node.customHeight ?? comp.size.height,
              comp.size.height,
              (val) {
                controller.updateNode(node.key, customHeight: val);
              },
              () {
                controller.updateNode(node.key, clearCustomHeight: true);
              },
            ),
            if (node.properties.isNotEmpty) ...[
              const Divider(),
              ...node.properties.entries.map(
                (e) {
                  if (e.key == 'Color') {
                    return _buildColorDropdown(node, e.key, e.value.toString());
                  }
                  return _buildTextInput(node, e.key, e.value.toString());
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorDropdown(CanvasNodeModel node, String label, String value) {
    const colorOptions = [
      'Red', 'Green', 'Blue', 'Yellow', 'Cyan', 'Pink', 'Orange'
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: colorOptions.contains(value) ? value : 'Red',
            isDense: true,
            underline: const SizedBox(),
            items: colorOptions.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getColorForPreview(val),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(val),
                  ],
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                final newProps = Map<String, dynamic>.from(node.properties);
                newProps[label] = newValue;
                controller.updateNodeProperties(node.key, newProps);
              }
            },
          ),
        ],
      ),
    );
  }

  Color _getColorForPreview(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'yellow': return Colors.yellow;
      case 'cyan': return Colors.cyan;
      case 'pink': return Colors.pink;
      case 'orange': return Colors.orange;
      case 'red':
      default: return Colors.red;
    }
  }

  Widget _buildStaticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(String label, double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
            width: 80,
            child: TextFormField(
              key: Key('${selectedNode?.key.toString()}_$label'),
              initialValue: value.toStringAsFixed(1),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (val) {
                final numVal = double.tryParse(val);
                if (numVal != null) onChanged(numVal);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInputWithReset(
      String label, double value, double defaultValue, Function(double) onChanged, VoidCallback onReset) {
    final bool isModified = (value - defaultValue).abs() > 0.01;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          if (isModified)
            IconButton(
              icon: const Icon(Icons.restore, size: 16),
              onPressed: onReset,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Reset to default',
            ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextFormField(
              key: Key('${selectedNode?.key.toString()}_$label'),
              initialValue: value.toStringAsFixed(1),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (val) {
                final numVal = double.tryParse(val);
                if (numVal != null) onChanged(numVal);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(CanvasNodeModel node, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
            width: 120,
            child: TextFormField(
              key: Key('${node.key.toString()}_$label'),
              initialValue: value,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (val) {
                final newProps = Map<String, dynamic>.from(node.properties);
                // Attempt to parse to number if it was a number before, or just keep string
                if (double.tryParse(val) != null && double.tryParse(val).toString() == val) {
                   newProps[label] = double.parse(val);
                } else {
                   newProps[label] = val;
                }
                controller.updateNodeProperties(node.key, newProps);
              },
            ),
          ),
        ],
      ),
    );
  }
}
