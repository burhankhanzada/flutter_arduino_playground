import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_arduino_playground/ui/canvas/controller/controller.dart';

class KeyboardEvent extends StatelessWidget {
  const KeyboardEvent({
    super.key,
    required this.child,
    required this.controller,
  });

  final Widget child;
  final CanvasController controller;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: bindings(context),
      child: Focus(autofocus: true, child: child),
    );
  }

  Map<SingleActivator, VoidCallback> bindings(BuildContext context) => {
    // Zooming
    const SingleActivator(LogicalKeyboardKey.equal): controller.zoomIn,
    const SingleActivator(LogicalKeyboardKey.minus): controller.zoomOut,

    // Panning
    const SingleActivator(LogicalKeyboardKey.arrowUp): controller.panUp,
    const SingleActivator(LogicalKeyboardKey.arrowDown): controller.panDown,
    const SingleActivator(LogicalKeyboardKey.arrowLeft): controller.panLeft,
    const SingleActivator(LogicalKeyboardKey.arrowRight): controller.panRight,

    // Delete
    const SingleActivator(LogicalKeyboardKey.delete): () =>
        _handleDelete(context),
    const SingleActivator(LogicalKeyboardKey.backspace): () =>
        _handleDelete(context),
  };

  Future<void> _handleDelete(BuildContext context) async {
    controller.remove();
  }
}
