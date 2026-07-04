import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/placed_component.dart';
import 'package:flutter_arduino_playground/ui/widgets/component_widget.dart';

class PlacedComponenetWidget extends StatefulWidget {
  const PlacedComponenetWidget({
    super.key,
    required this.component,
    required this.onPanUpdate,
    required this.onDoubleTap,
  });

  final PlacedComponentModel component;

  final Function(DragUpdateDetails) onPanUpdate;

  final Function() onDoubleTap;

  @override
  State<PlacedComponenetWidget> createState() => _PlacedComponenetWidgetState();
}

class _PlacedComponenetWidgetState extends State<PlacedComponenetWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left:
          widget.component.position.dx -
          widget.component.componentModel.size.width / 2,
      top:
          widget.component.position.dy -
          widget.component.componentModel.size.height / 2,
      child: GestureDetector(
        onPanUpdate: widget.onPanUpdate,
        onDoubleTap: widget.onDoubleTap,
        child: ComponentWidget(componentModel: widget.component.componentModel),
      ),
    );
  }
}
