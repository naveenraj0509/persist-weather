import 'dart:math';
import 'package:flutter/material.dart';

class TwinklingStarsBackground extends StatefulWidget {
  final Widget child;

  const TwinklingStarsBackground({super.key, required this.child});

  @override
  State<TwinklingStarsBackground> createState() => _TwinklingStarsBackgroundState();
}

class _TwinklingStarsBackgroundState extends State<TwinklingStarsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Generate random stars
    for (int i = 0; i < 90; i++) {
      _stars.add(
        Star(
          x: _random.nextDouble(),
          y: _random.nextDouble() * 0.75, // Keep stars mostly in the upper 75% of screen
          size: _random.nextDouble() * 2.2 + 0.8,
          twinkleSpeed: _random.nextDouble() * 0.5 + 0.5,
          phase: _random.nextDouble() * pi * 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarsPainter(
            stars: _stars,
            animationValue: _controller.value,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class Star {
  final double x; // percentage of screen width (0.0 to 1.0)
  final double y; // percentage of screen height (0.0 to 1.0)
  final double size; // size of the star in pixels
  final double twinkleSpeed; // speed multiplier
  final double phase; // starting phase offset

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.phase,
  });
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarsPainter({required this.stars, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
        // 1. Paint the gorgeous background gradient
    final Rect rect = Offset.zero & size;
    final Paint backgroundPaint = Paint();
    backgroundPaint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF2E335A), // Deep violet blue
        Color(0xFF1C1B33), // Dark navy space
      ],
    ).createShader(rect);
    canvas.drawRect(rect, backgroundPaint);

    // 2. Draw subtle background glow blobs for depth
    final Paint glowPaint1 = Paint()
      ..color = const Color(0xFF612FAB).withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), size.width * 0.4, glowPaint1);

    final Paint glowPaint2 = Paint()
      ..color = const Color(0xB23B267B).withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.6), size.width * 0.5, glowPaint2);

    // 3. Paint the stars
    for (final star in stars) {
      // Calculate pulsating opacity based on animation value and star parameters
      final double sinVal = sin((animationValue * pi * 2 * star.twinkleSpeed) + star.phase);
      final double opacity = ((sinVal + 1) / 2) * 0.7 + 0.3; // opacity between 0.3 and 1.0

      final Paint starPaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Draw star coordinate mapping percentage to actual size
      final Offset position = Offset(star.x * size.width, star.y * size.height);
      
      // Draw standard stars as small circles
      canvas.drawCircle(position, star.size, starPaint);

      // Add a subtle glow/cross to larger stars
      if (star.size > 2.2 && opacity > 0.8) {
        final Paint flarePaint = Paint()
          ..color = Colors.white.withOpacity(opacity * 0.3)
          ..strokeWidth = 0.5;
        
        canvas.drawLine(Offset(position.dx - 4, position.dy), Offset(position.dx + 4, position.dy), flarePaint);
        canvas.drawLine(Offset(position.dx, position.dy - 4), Offset(position.dx, position.dy + 4), flarePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StarsPainter oldDelegate) => true;
}
