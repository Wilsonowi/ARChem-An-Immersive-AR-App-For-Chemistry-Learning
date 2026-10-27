import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'auth/auth_controller.dart';
import 'widgets/app_logo.dart';

// --- Light Theme Colors ---
// Matches the onboarding screen's white-to-lilac + deep navy/indigo theme
// (replaces the previous cyan/blue theme).
const Color _lightBgCenter = Color(0xFFFFFFFF);
const Color _lightBgEdge = Color(0xFFE7DEFB); // Soft lilac
const Color _primaryAccent = Color(0xFF581C87); // Dark purple
const Color _textMuted = Color(0xFF4D6B84); // Muted blue slate

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();
  Offset? _userTouchPosition;

  @override
  void initState() {
    super.initState();

    // Ticker to drive the floating chemistry atoms/particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize random interactive chemistry nodes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _generateParticles(size);
    });

    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _generateParticles(Size size) {
    for (int i = 0; i < 25; i++) {
      _particles.add(
        _Particle(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 1.5,
            (_random.nextDouble() - 0.5) * 1.5,
          ),
          radius: _random.nextDouble() * 4 + 2,
        ),
      );
    }
  }

  Future<void> _navigateToNextScreen() async {
    // Minimum visual time for logo pop-in animation
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // Continuously check if AuthController is done loading instead of hardcoded extra delays
    while (ref.read(authControllerProvider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    final isLoggedIn = ref.read(authControllerProvider).isLoggedIn;
    if (isLoggedIn) {
      if (mounted) context.go('/home');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!mounted) return;
    if (onboardingDone) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // Tracking user drags and taps to interactively warp the background atoms
        onPanUpdate: (details) =>
            setState(() => _userTouchPosition = details.localPosition),
        onPanEnd: (_) => setState(() => _userTouchPosition = null),
        onTapDown: (details) =>
            setState(() => _userTouchPosition = details.localPosition),
        onTapUp: (_) => setState(() => _userTouchPosition = null),
        child: Container(
          // Premium radial gradient background for light theme
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [_lightBgCenter, _lightBgEdge],
            ),
          ),
          child: Stack(
            children: [
              // Interactive Chemistry Node Field
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _InteractiveGridPainter(
                      particles: _particles,
                      userTouch: _userTouchPosition,
                    ),
                    size: Size.infinite,
                  );
                },
              ),

              // Foreground Content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Interactive Floating & Scaling Logo
                    const AppLogo(iconSize: 140)
                        .animate()
                        .scale(
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                          begin: const Offset(0.2, 0.2),
                          end: const Offset(1, 1),
                        )
                        .fadeIn(duration: 600.ms),
                  ],
                ),
              ),

              // Subtle feedback instruction for the user
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                          'Swivel screen to bond atoms',
                          style: TextStyle(
                            color: _primaryAccent.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        )
                        .animate(delay: 1200.ms)
                        .fadeIn()
                        .shimmer(
                          duration: 3.seconds,
                          color: _primaryAccent.withOpacity(0.3),
                        ),
                    const SizedBox(height: 12),
                    Text(
                      'v2.0.0',
                      style: TextStyle(
                        color: _textMuted.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── INTERACTIVE CHEMICAL NODE FIELD PAINTER ───────────────────────────────
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
    // Bounce boundaries
    if (position.dx <= 0 || position.dx >= size.width) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }
    if (position.dy <= 0 || position.dy >= size.height) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }
  }
}

class _InteractiveGridPainter extends CustomPainter {
  final List<_Particle> particles;
  final Offset? userTouch;

  _InteractiveGridPainter({required this.particles, this.userTouch});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Subtle Tech Grid Lines (Light Theme version)
    final gridPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
          .withOpacity(0.35) // Slate 300
      ..strokeWidth = 0.5;

    const spacing = 50.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Light Theme Atom and Bond Colors
    final atomPaint = Paint()..color = _primaryAccent.withOpacity(0.5);
    final bondPaint = Paint()..strokeWidth = 1.0;

    // 2. Process and draw live structural chemical elements
    for (int i = 0; i < particles.length; i++) {
      var p = particles[i];
      p.update(size);

      // Interactivity: Attract atoms slightly towards user's finger touch
      if (userTouch != null) {
        double dx = userTouch!.dx - p.position.dx;
        double dy = userTouch!.dy - p.position.dy;
        double dist = math.sqrt(dx * dx + dy * dy);
        if (dist < 180) {
          p.position += Offset(dx / dist * 0.8, dy / dist * 0.8);
        }
      }

      // Draw the core molecule/atom
      canvas.drawCircle(p.position, p.radius, atomPaint);

      // Connect proximal atoms with chemical bonds (valency lines)
      for (int j = i + 1; j < particles.length; j++) {
        var p2 = particles[j];
        double dx = p.position.dx - p2.position.dx;
        double dy = p.position.dy - p2.position.dy;
        double distance = math.sqrt(dx * dx + dy * dy);

        if (distance < 110) {
          // Fade out the bonds smoothly as distance increases
          bondPaint.color = _primaryAccent.withOpacity(
            (1.0 - (distance / 110)) * 0.4,
          );
          canvas.drawLine(p.position, p2.position, bondPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
