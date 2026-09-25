import 'package:flutter/material.dart';
import 'package:myexpence/core/theme/app_theme.dart';

class DraggableFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double initialBottom;
  final double initialRight;

  const DraggableFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.initialBottom = 20,
    this.initialRight = 16,
  });

  @override
  State<DraggableFloatingActionButton> createState() => _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState extends State<DraggableFloatingActionButton> {
  Offset? _position;
  bool _isDragging = false;
  double _dragDistance = 0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;
    const fabSize = 56.0;

    // Default starting position: bottom right relative to screen padding
    final defaultX = screenSize.width - fabSize - widget.initialRight;
    final defaultY = screenSize.height - fabSize - widget.initialBottom - padding.bottom;

    final minX = 12.0;
    final maxX = screenSize.width - fabSize - 12.0;
    final minY = padding.top + 12.0;
    final maxY = screenSize.height - padding.bottom - fabSize - 12.0;

    double currentX = _position?.dx ?? defaultX;
    double currentY = _position?.dy ?? defaultY;

    // Keep position clamped within screen bounds
    currentX = currentX.clamp(minX, maxX);
    currentY = currentY.clamp(minY, maxY);

    return Positioned(
      left: currentX,
      top: currentY,
      child: GestureDetector(
        onPanStart: (_) {
          _dragDistance = 0;
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          _dragDistance += details.delta.distance;
          setState(() {
            double newX = (currentX + details.delta.dx).clamp(minX, maxX);
            double newY = (currentY + details.delta.dy).clamp(minY, maxY);
            _position = Offset(newX, newY);
          });
        },
        onPanEnd: (_) {
          setState(() {
            _isDragging = false;
          });
          if (_dragDistance < 10) {
            widget.onPressed();
          }
        },
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isDragging ? 1.12 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Material(
            elevation: _isDragging ? 10.0 : 6.0,
            shape: const CircleBorder(),
            color: widget.backgroundColor ?? AppTheme.primaryColor,
            shadowColor: Colors.black45,
            child: SizedBox(
              width: fabSize,
              height: fabSize,
              child: Center(
                child: Icon(
                  widget.icon,
                  color: widget.foregroundColor ?? Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
