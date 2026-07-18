import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/models/port_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/grid_system.dart';
import 'package:interactive_viewer_plus/interactive_viewer_plus.dart';

// Absolute state controller for high precision zoom/pan
class BaseCanvasController extends ChangeNotifier {
  final InteractiveViewerPlusController viewerController =
      InteractiveViewerPlusController();

  BaseCanvasController() {
    viewerController.addListener(() {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    viewerController.dispose();
    super.dispose();
  }

  double get gridCellSize => GridSystem.cellSize;
  bool snapToGrid = true;

  double minScale = 0.4;
  double maxScale = 4.0;

  double get scale => viewerController.value.getMaxScaleOnAxis();

  Offset get offset {
    final translation = viewerController.value.getTranslation();
    return Offset(translation.x, translation.y);
  }

  void centerOrigin(Size size) {
    viewerController.value = Matrix4.translationValues(
      size.width / 2,
      size.height / 2,
      0.0,
    );
  }

  late Offset mouseLocalPosition;

  final List<CanvasNodeModel> nodes = [];

  Matrix4 get transform => viewerController.value;

  void zoomIn() => viewerController.zoom(1.1);
  void zoomOut() => viewerController.zoom(0.9);
  void zoomReset() => viewerController.value = Matrix4.identity();

  void panUp() => viewerController.pan(const Offset(0, 50));
  void panDown() => viewerController.pan(const Offset(0, -50));
  void panLeft() => viewerController.pan(const Offset(50, 0));
  void panRight() => viewerController.pan(const Offset(-50, 0));

  bool _mouseDown = false;
  bool get mouseDown => _mouseDown;
  set mouseDown(bool value) {
    if (value == _mouseDown) return;
    _mouseDown = value;
    notifyListeners();
  }

  Offset? _dragStartOffset;
  Offset? get dragStartOffset => _dragStartOffset;
  set dragStartOffset(Offset? offset) {
    _dragStartOffset = offset;
    notifyListeners();
  }

  CanvasNodeModel? selectedNodeKey;
  CanvasNodeModel? hoveredNodeKey;
  PortLocation? hoveredPort;

  Offset screenToCanvasCoordinates(Offset screenPosition) {
    return viewerController.toScene(screenPosition);
  }

  Offset canvasToScreenCoordinates(Offset canvasPosition) {
    return (canvasPosition * scale) + offset;
  }
}
