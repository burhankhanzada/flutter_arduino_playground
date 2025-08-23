import 'package:flutter/material.dart';
import 'package:flutter_arduino_playground/models/canvas_node_model.dart';

// Absolute state controller for high precision zoom/pan
class BaseCanvasController extends ChangeNotifier {
  double gridSize = 10.0;
  bool snapToGrid = true;

  double minScale = 0.4;
  double maxScale = 4.0;

  double _scale = 1.0;
  double get scale => _scale;
  set scale(double value) {
    final clamped = value.clamp(minScale, maxScale);
    if (_scale == clamped) return;
    _scale = clamped;
    notifyListeners();
  }

  Offset _offset = Offset.zero;
  Offset get offset => _offset;
  set offset(Offset value) {
    if (_offset == value) return;
    _offset = value;
    notifyListeners();
  }

  void zoomReset() {
    _scale = 1.0;
    _offset = Offset.zero;
    notifyListeners();
  }

  void centerOrigin(Size size) {
    offset = Offset(size.width / 2, size.height / 2);
  }

  late Offset mouseLocalPosition;

  final List<CanvasNodeModel> nodes = [];

  Matrix4 get transform => Matrix4.identity()
    ..translate(offset.dx, offset.dy)
    ..scale(scale, scale);

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
}
