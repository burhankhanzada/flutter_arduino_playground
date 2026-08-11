import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/providers/component_provider.dart';
import 'package:flutter_arduino_playground/ui/palette/palette_component.dart';

class ComponentPalette extends ConsumerWidget {
  const ComponentPalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final componentsAsync = ref.watch(componentRegistryProvider);

    return componentsAsync.when(
      data: (components) => GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.6,
        ),
        itemCount: components.length,
        itemBuilder: (context, index) {
          return PaletteComponent(componentModel: components[index]);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading components: $e')),
    );
  }
}
