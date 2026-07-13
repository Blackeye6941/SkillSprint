import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double height;
  final double shadowHeight;
  final Color faceColor;
  final Color shadowColor;
  final BorderRadius borderRadius;

  const AnimatedButton({
    super.key,
    required this.child,
    required this.onTap,
    this.height = 45.0,
    this.shadowHeight = 6.0,
    required this.faceColor,
    required this.shadowColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // Shadow layer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: widget.height - widget.shadowHeight,
                decoration: BoxDecoration(
                  color: widget.shadowColor,
                  borderRadius: widget.borderRadius,
                ),
              ),
            ),
            // Face layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              top: _isPressed ? widget.shadowHeight : 0,
              left: 0,
              right: 0,
              child: Container(
                height: widget.height - widget.shadowHeight,
                decoration: BoxDecoration(
                  color: widget.faceColor,
                  borderRadius: widget.borderRadius,
                  boxShadow: [
                    if (!_isPressed)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                alignment: Alignment.center,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
