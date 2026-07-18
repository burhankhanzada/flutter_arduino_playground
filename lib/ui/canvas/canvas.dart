import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/canvas_node.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_painter.dart';
import 'package:flutter_arduino_playground/ui/canvas/keybaord_event.dart';
import 'package:flutter_arduino_playground/ui/canvas/pointer_event.dart';
import 'package:flutter_arduino_playground/ui/canvas/wire_painter.dart';
import 'package:interactive_viewer_plus/interactive_viewer_plus.dart';

class Canvas extends StatefulWidget {
  const Canvas({super.key, required this.controller});

  final CanvasController controller;

  @override
  State<Canvas> createState() => CanvasState();
}

class CanvasState extends State<Canvas> {
  final gridSize = const Size.square(50);

  CanvasController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(onUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(onUpdate);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Canvas oldWidget) {
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(onUpdate);
      controller.addListener(onUpdate);
    }
    super.didUpdateWidget(oldWidget);
  }

  void onUpdate() {
    if (mounted) setState(() {});
  }

  bool _isCentered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_isCentered) {
          _isCentered = true;
          if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.centerOrigin(constraints.biggest);
            });
          }
        }

        return KeyboardEvent(
          controller: controller,
          child: CanvasPointerEvent(
            controller: controller,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: GridPainter(context, controller),
                ),
                InteractiveViewerPlus(
                  controller: controller.viewerController,
                  constrained: true,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: controller.minScale,
                  maxScale: controller.maxScale,
                  panEnabled: controller.canvasMoveEnabled,
                  scaleEnabled: true,
                  clipBehavior: Clip.none,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: CustomMultiChildLayout(
                          delegate: InfiniteCanvasNodesDelegate(controller.nodes),
                          children: controller.nodes
                              .map(
                                (canvasComponentModel) => LayoutId(
                                  id: canvasComponentModel,
                                  key: canvasComponentModel.key,
                                  child: CanvasNode(
                                    controller: controller,
                                    node: canvasComponentModel,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: WirePainter(
                            wires: List.of(controller.wires),
                            nodes: List.of(controller.nodes),
                            pendingStart: controller.startPort,
                            pendingEndMouse: controller.currentDragPosition,
                            hoveredPort: controller.hoveredPort,
                            hoveredWireId: controller.hoveredWireId,
                            selectedWireId: controller.selectedWireId,
                            selectionColor: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class InfiniteCanvasNodesDelegate extends MultiChildLayoutDelegate {
  InfiniteCanvasNodesDelegate(this.nodes);
  final List<CanvasNodeModel> nodes;

  @override
  void performLayout(Size size) {
    for (final widget in nodes) {
      layoutChild(widget, BoxConstraints.tight(widget.componentModel.size));
      positionChild(widget, widget.position);
    }
  }

  @override
  bool shouldRelayout(InfiniteCanvasNodesDelegate oldDelegate) => false;
}
