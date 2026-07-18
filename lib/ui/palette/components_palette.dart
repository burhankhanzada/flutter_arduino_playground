import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/constants.dart';
import 'package:flutter_arduino_playground/ui/palette/palette_component.dart';

class ComponentPalette extends StatelessWidget {
  const ComponentPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.6,
              ),
              itemCount: components.length,
              itemBuilder: (context, index) {
                return PaletteComponent(componentModel: components[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
