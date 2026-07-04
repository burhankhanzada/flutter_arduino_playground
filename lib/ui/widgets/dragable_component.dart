import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';
import 'package:flutter_arduino_playground/ui/widgets/component_widget.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class DraggableComponent extends StatelessWidget {
  final ComponentModel componentModel;

  const DraggableComponent({super.key, required this.componentModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        spacing: 8,
        children: [
          DragItemWidget(
            allowedOperations: () => [DropOperation.copy],
            dragItemProvider: (request) =>
                DragItem(localData: componentModel.name),
            child: DraggableWidget(
              child: FittedBox(
                fit: BoxFit.contain,
                child: ComponentWidget(componentModel: componentModel)),
            ),
          ),
          Text(componentModel.name),
        ],
      ),
    );
  }
}
