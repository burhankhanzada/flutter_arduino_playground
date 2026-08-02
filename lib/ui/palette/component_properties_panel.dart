import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'dart:math' as math;

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
            _buildPropertyRow('Name', comp.name),
            const Divider(),
            _buildPropertyRow('Position X', node.position.dx.toStringAsFixed(1)),
            _buildPropertyRow('Position Y', node.position.dy.toStringAsFixed(1)),
            const Divider(),
            _buildPropertyRow('Rotation', '${(node.rotationAngle * 180 / math.pi).toStringAsFixed(0)}°'),
            _buildPropertyRow('Flipped H', node.flipHorizontal ? 'Yes' : 'No'),
            _buildPropertyRow('Flipped V', node.flipVertical ? 'Yes' : 'No'),
            const Divider(),
            _buildPropertyRow('Width', comp.size.width.toStringAsFixed(1)),
            _buildPropertyRow('Height', comp.size.height.toStringAsFixed(1)),
            if (node.properties.isNotEmpty) ...[
              const Divider(),
              ...node.properties.entries.map(
                (e) {
                  if (e.key == 'Color') {
                    return _buildColorDropdown(node, e.key, e.value.toString());
                  }
                  return _buildPropertyRow(e.key, e.value.toString());
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
                child: Text(val),
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

  Widget _buildPropertyRow(String label, String value) {
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
}
