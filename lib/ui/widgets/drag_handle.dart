import 'package:flutter/material.dart';

class DragHandle extends StatefulWidget {
  final ValueChanged<DragUpdateDetails> onPanUpdate;
  final Axis direction;

  const DragHandle({
    super.key,
    required this.onPanUpdate,
    this.direction = Axis.horizontal,
  });

  @override
  State<DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<DragHandle> {
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = _isHovered || _isDragging;

    final color = isHighlighted
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).scaffoldBackgroundColor;

    return MouseRegion(
      cursor: widget.direction == Axis.horizontal
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.resizeUpDown,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanEnd: (_) => setState(() => _isDragging = false),
        onPanCancel: () => setState(() => _isDragging = false),
        onPanUpdate: widget.onPanUpdate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.direction == Axis.horizontal ? 4.0 : null,
          height: widget.direction == Axis.vertical ? 4.0 : null,
          color: color,
        ),
      ),
    );
  }
}
