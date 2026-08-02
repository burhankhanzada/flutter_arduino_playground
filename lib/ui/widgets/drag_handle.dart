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

  final double hoveredThickness = 4.0;
  final double normalThickness = 1.0;
  final double hitAreaSize = 4.0;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = _isHovered || _isDragging;

    final color = isHighlighted
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;

    final isHorizontal = widget.direction == Axis.horizontal;

    return MouseRegion(
      cursor: isHorizontal
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
        child: SizedBox(
          width: isHorizontal ? hitAreaSize : double.infinity,
          height: isHorizontal ? double.infinity : hitAreaSize,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: isHorizontal
                  ? (isHighlighted ? hoveredThickness : normalThickness)
                  : double.infinity,
              height: isHorizontal
                  ? double.infinity
                  : (isHighlighted ? hoveredThickness : normalThickness),
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
