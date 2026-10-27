import 'dart:math' as math;

import 'package:flutter/material.dart';

class ChemistryBackground extends StatefulWidget {
  final Widget child;

  /// Optional color overrides, all defaulting to this widget's original
  /// blue palette - every existing call site keeps its exact current look
  /// unless it explicitly opts in to different colors (see HomeScreen for
  /// the purple override).
  final Color? gradientCenter;
  final Color? gradientEdge;
  final Color? gridColor;
  final Color? accentColor;

  const ChemistryBackground({
    super.key,
    required this.child,
    this.gradientCenter,
    this.gradientEdge,
    this.gridColor,
    this.accentColor,
  });

  @override
  State<ChemistryBackground> createState() => _ChemistryBackgroundState();
}

class _ChemistryBackgroundState extends State<ChemistryBackground>
    with SingleTickerProviderStateMixin {
  static const _bgCenter = Color(0xFFF8FCFF);
  static const _bgEdge = Color(0xFFDDF2FF);
  static const _gridColor = Color(0xFF7DD3FC);
  static const _primaryCyan = Color(0xFF0284C7);

  final _particles = <_Particle>[];
  final _random = math.Random();
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _particles.isNotEmpty) return;
      final size = MediaQuery.sizeOf(context);
      setState(() {
        for (int i = 0; i < 24; i++) {
          _particles.add(
            _Particle(
              position: Offset(
                _random.nextDouble() * size.width,
                _random.nextDouble() * size.height,
              ),
              velocity: Offset(
                (_random.nextDouble() - 0.5) * 0.9,
                (_random.nextDouble() - 0.5) * 0.9,
              ),
              radius: _random.nextDouble() * 3 + 1.8,
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.15,
          colors: [
            widget.gradientCenter ?? _bgCenter,
            widget.gradientEdge ?? _bgEdge,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ChemistryBackgroundPainter(
                  particles: _particles,
                  accent: widget.accentColor ?? _primaryCyan,
                  gridColor: widget.gridColor ?? _gridColor,
                ),
                size: Size.infinite,
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Particle {
  Offset position;
  Offset velocity;
  final double radius;

  _Particle({
    required this.position,
    required this.velocity,
    required this.radius,
  });

  void update(Size size) {
    position += velocity;
    if (position.dx <= 0 || position.dx >= size.width) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }
    if (position.dy <= 0 || position.dy >= size.height) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }
  }
}

class _ChemistryBackgroundPainter extends CustomPainter {
  final List<_Particle> particles;
  final Color accent;
  final Color gridColor;

  _ChemistryBackgroundPainter({
    required this.particles,
    required this.accent,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor.withOpacity(0.2)
      ..strokeWidth = 0.5;
    const spacing = 54.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final atomPaint = Paint()..color = accent.withOpacity(0.38);
    final bondPaint = Paint()..strokeWidth = 1;

    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      particle.update(size);
      canvas.drawCircle(particle.position, particle.radius, atomPaint);

      for (int j = i + 1; j < particles.length; j++) {
        final other = particles[j];
        final distance = (particle.position - other.position).distance;
        if (distance < 112) {
          bondPaint.color = accent.withOpacity((1 - (distance / 112)) * 0.32);
          canvas.drawLine(particle.position, other.position, bondPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
