import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/constants.dart';
import 'package:flutter_arduino_playground/ui/widgets/palette_component.dart';

class ComponentPalette extends StatelessWidget {
  const ComponentPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: SizedBox(
        width: 250,
        child: ListView.builder(
          itemCount: components.length,
          itemBuilder: (context, index) {
            return PaletteComponent(componentModel: components[index]);
          },
        ),
      ),
    );
  }
}
