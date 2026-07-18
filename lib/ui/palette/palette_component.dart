import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/ui/widgets/component_widget.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class PaletteComponent extends StatelessWidget {
  final ComponentModel componentModel;

  const PaletteComponent({super.key, required this.componentModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: DragItemWidget(
        allowedOperations: () => [DropOperation.copy],
        dragItemProvider: (request) => DragItem(
          localData: componentModel.name,
          suggestedName: componentModel.name,
        )..add(Formats.plainText(componentModel.name)),
        child: DraggableWidget(
          child: Column(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: ComponentWidget(componentModel: componentModel),
                ),
              ),
              Text(componentModel.name, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
