import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showDots;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.showDots = true,
  });

  @override
  AnimatedBackgroundState createState() => AnimatedBackgroundState();
}

class AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Dot> _dots = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Initialize dots
    for (int i = 0; i < 30; i++) {
      _dots.add(Dot());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E88E5),  // Darker blue
                Color(0xFF0D47A1),  // Even darker blue
              ],
            ),
          ),
        ),

        // Animated Dots
        if (widget.showDots)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: DotsPainter(
                  dots: _dots,
                  progress: _controller.value,
                ),
                size: Size.infinite,
              );
            },
          ),

        // Content
        widget.child,
      ],
    );
  }
}

class Dot {
  final double size;
  final double x;
  double y;
  final double speed;
  final double opacity;

  Dot()
      : size = Random().nextDouble() * 3 + 1,
        x = Random().nextDouble(),
        y = Random().nextDouble(),
        speed = Random().nextDouble() * 0.5 + 0.1,
        opacity = Random().nextDouble() * 0.5 + 0.2;
}

class DotsPainter extends CustomPainter {
  final List<Dot> dots;
  final double progress;

  DotsPainter({required this.dots, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color.fromRGBO(255, 255, 255, 0.7);

    for (var dot in dots) {
      // Update dot position
      dot.y = (dot.y + dot.speed * 0.01) % 1.0;

      // Draw dot
      final x = dot.x * size.width;
      final y = dot.y * size.height;
      canvas.drawCircle(
        Offset(x, y),
        dot.size,
        paint..color = Color.fromRGBO(255, 255, 255, dot.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}