import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/constants.dart';
import 'package:flutter_arduino_playground/models/placed_component.dart';
import 'package:flutter_arduino_playground/ui/widgets/placed_component.dart';
import 'package:interactive_viewer_2/interactive_viewer_2.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class CanvasArea extends StatefulWidget {
  const CanvasArea({super.key});

  @override
  State<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<CanvasArea> {
  final List<PlacedComponentModel> placedComponents = [];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card.outlined(
        clipBehavior: Clip.antiAlias,
        child: InteractiveViewer2(
          child: DropRegion(
            formats: Formats.standardFormats,
            onDropOver: (event) => DropOperation.copy,
            onPerformDrop: (event) async {
              final localData = event.session.items
                  .where((item) => item.localData != null)
                  .map((item) => item.localData)
                  .firstOrNull;

              String? componentName;

              if (localData != null) {
                componentName = localData as String;
              }

              if (componentName != null) {
                final renderBox = context.findRenderObject() as RenderBox;
                final localPosition = renderBox.globalToLocal(
                  event.position.local,
                );

                final componentType = components.firstWhere(
                  (type) => type.name == componentName,
                );

                final placedComponent = PlacedComponentModel(
                  position: localPosition,
                  componentModel: componentType,
                  id: DateTime.now().millisecondsSinceEpoch,
                );

                setState(() {
                  placedComponents.add(placedComponent);
                });
              }
            },
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: GridPainter(context),
                child: Stack(
                  children: [
                    ...placedComponents.asMap().entries.map((entry) {
                      final index = entry.key;
                      final component = entry.value;

                      return PlacedComponenetWidget(
                        key: ValueKey(component.id),
                        component: component,
                        onPanUpdate: (details) {
                          final newPosition =
                              component.position + details.delta;
                          setState(() {
                            placedComponents[index] = placedComponents[index]
                                .copyWith(position: newPosition);
                          });
                        },
                        onDoubleTap: () {
                          setState(() {
                            placedComponents.removeAt(index);
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  GridPainter(this.context);

  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).colorScheme.onSurface.withAlpha(25)
      ..strokeWidth = 0.5;

    const gridSize = 10;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
