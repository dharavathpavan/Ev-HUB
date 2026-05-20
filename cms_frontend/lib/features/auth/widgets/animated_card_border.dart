import 'package:flutter/material.dart';

class AnimatedCardBorder extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  const AnimatedCardBorder({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.borderWidth = 1.5,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<AnimatedCardBorder> createState() => _AnimatedCardBorderState();
}

class _AnimatedCardBorderState extends State<AnimatedCardBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The animated neon border stroke
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _TravelingBorderPainter(
                    animationValue: _controller.value,
                    borderRadius: widget.borderRadius,
                    borderWidth: widget.borderWidth,
                  ),
                );
              },
            ),
          ),
          // Inner content (The Glass Card itself)
          Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _TravelingBorderPainter extends CustomPainter {
  final double animationValue;
  final BorderRadius borderRadius;
  final double borderWidth;

  _TravelingBorderPainter({
    required this.animationValue,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    // Create a rotating sweep gradient to simulate traveling light beams
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = SweepGradient(
        colors: const [
          Colors.transparent,
          Color(0x33FFFFFF), // white/20
          Colors.white,      // bright beam
          Color(0x33FFFFFF), // white/20
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
        transform: GradientRotation(animationValue * 2 * 3.141592653589793),
      ).createShader(rect);

    // Apply a blur mask to the stroke to give it a neon glow effect
    paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.0);

    // Draw the rounded rectangle stroke
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _TravelingBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
