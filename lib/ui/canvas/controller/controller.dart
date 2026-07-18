import 'package:flutter_arduino_playground/models/canvas_node_model.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/base_controller.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/connection_mixin.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/select_mixin.dart';

class CanvasController extends BaseCanvasController
    with ConnectionMixin, SelectMixin {
  bool get canvasMoveEnabled => !mouseDown;

  CanvasController({
    List<CanvasNodeModel> nodes = const [],
    bool snapResizeToGrid = false,
  }) {
    if (nodes.isNotEmpty) {
      this.nodes.addAll(nodes);
    }
  }

  void add(CanvasNodeModel child) {
    nodes.add(child);
    selectedNodeKey = child;
    notifyListeners();
  }

  void remove() {
    nodes.remove(selectedNodeKey);
    clearSelection();
    notifyListeners();
  }
}
