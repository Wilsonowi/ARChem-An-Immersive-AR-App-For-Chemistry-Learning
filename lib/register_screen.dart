import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_controller.dart';
import 'validators.dart';
import 'widgets/app_logo.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _particles = <_AuthParticle>[];
  final _random = math.Random();
  late final AnimationController _particleController;

  bool _showVerify = false;
  String _verifyEmail = '';

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _generateParticles(MediaQuery.sizeOf(context));
    });
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmCtrl.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _generateParticles(Size size) {
    if (_particles.isNotEmpty) return;
    setState(() {
      for (int i = 0; i < 24; i++) {
        _particles.add(
          _AuthParticle(
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
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = ref.read(authControllerProvider.notifier);
    final success = await controller.signUp(
      email: _emailCtrl.text,
      password: _pwdCtrl.text,
      username: _usernameCtrl.text,
      fullName: _fullNameCtrl.text,
    );

    if (!success || !mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.isLoggedIn) {
      context.go('/home');
    } else if (authState.needsVerification) {
      setState(() {
        _showVerify = true;
        _verifyEmail = _emailCtrl.text.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final error = authState.errorMessage;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.15,
            colors: [_AuthPalette.bgCenter, _AuthPalette.bgEdge],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _AuthBackgroundPainter(particles: _particles),
                  size: Size.infinite,
                );
              },
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _showVerify
                            ? _VerifyPanel(
                                email: _verifyEmail,
                                onBackToLogin: () => context.go('/login'),
                              )
                            : Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    const _AuthBrandHeader(
                                      title: 'Create account',
                                      subtitle:
                                          'Start your personalised Form 4 Chemistry plan',
                                    )
                                        .animate()
                                        .fadeIn(duration: 420.ms)
                                        .slideY(begin: -0.04),
                                    const SizedBox(height: 30),
                                    _AuthCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (error != null) ...[
                                            _ErrorBanner(message: error),
                                            const SizedBox(height: 18),
                                          ],
                                          _WhiteAuthField(
                                            label: 'Full Name',
                                            hint: 'Your full name',
                                            icon:
                                                Icons.person_outline_rounded,
                                            controller: _fullNameCtrl,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: Validators.fullName,
                                          ),
                                          const SizedBox(height: 16),
                                          _WhiteAuthField(
                                            label: 'Username',
                                            hint:
                                                'No spaces, min 3 characters',
                                            icon: Icons
                                                .alternate_email_rounded,
                                            controller: _usernameCtrl,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: Validators.username,
                                          ),
                                          const SizedBox(height: 16),
                                          _WhiteAuthField(
                                            label: 'Email',
                                            hint: 'you@example.com',
                                            icon: Icons.mail_outline_rounded,
                                            controller: _emailCtrl,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: Validators.email,
                                          ),
                                          const SizedBox(height: 16),
                                          _WhiteAuthField(
                                            label: 'Password',
                                            hint: 'Create password',
                                            icon: Icons.lock_outline_rounded,
                                            controller: _pwdCtrl,
                                            isPassword: true,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: Validators.password,
                                          ),
                                          const SizedBox(height: 16),
                                          _WhiteAuthField(
                                            label: 'Confirm Password',
                                            hint: 'Repeat password',
                                            icon: Icons.lock_outline_rounded,
                                            controller: _confirmCtrl,
                                            isPassword: true,
                                            textInputAction:
                                                TextInputAction.done,
                                            onEditingComplete: _submit,
                                            validator: (value) =>
                                                Validators.confirmPassword(
                                              value,
                                              _pwdCtrl.text,
                                            ),
                                          ),
                                          const SizedBox(height: 26),
                                          _PrimaryAuthButton(
                                            label: 'Create Account',
                                            isLoading: authState.isLoading,
                                            onPressed: _submit,
                                          ),
                                        ],
                                      ),
                                    )
                                        .animate(delay: 90.ms)
                                        .fadeIn()
                                        .slideY(begin: 0.06),
                                    const SizedBox(height: 22),
                                    _SwitchAuthMode(
                                      mutedText: 'Already with ARChem?',
                                      actionText: 'Sign in',
                                      onTap: () => context.go('/login'),
                                    ).animate(delay: 170.ms).fadeIn(),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthPalette {
  // Light-white-to-lilac background and a deep navy/indigo accent, matching
  // the onboarding, login, and splash screens' theme (replaces the previous
  // cyan/blue theme).
  static const bgCenter = Color(0xFFFFFFFF);
  static const bgEdge = Color(0xFFE7DEFB);
  static const card = Color(0xF2FFFFFF);
  static const field = Color(0xFFFFFFFF);
  static const border = Color(0xFFC8E4F4);
  static const text = Color(0xFF0F2942);
  static const muted = Color(0xFF4D6B84);
  static const accent = Color(0xFF581C87);
  static const accentSoft = Color(0xFFE9E4FB);
  static const danger = Color(0xFFEF4444);
  static const green = Color(0xFF10B981);
}

class _AuthBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AuthBrandHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppLogo(iconSize: 100),
        const SizedBox(height: 26),
        Text(
          title,
          style: const TextStyle(
            color: _AuthPalette.text,
            fontSize: 31,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            color: _AuthPalette.muted,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  final Widget child;

  const _AuthCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _AuthPalette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _AuthPalette.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.15),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _WhiteAuthField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final String? Function(String?)? validator;

  const _WhiteAuthField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onEditingComplete,
    this.validator,
  });

  @override
  State<_WhiteAuthField> createState() => _WhiteAuthFieldState();
}

class _WhiteAuthFieldState extends State<_WhiteAuthField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: _AuthPalette.muted,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onEditingComplete: widget.onEditingComplete,
          validator: widget.validator,
          style: const TextStyle(
            color: _AuthPalette.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: Color(0xFFB4BCC8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(widget.icon, color: _AuthPalette.muted),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _AuthPalette.muted,
                    ),
                  )
                : null,
            filled: true,
            fillColor: _AuthPalette.field,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 19,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _AuthPalette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _AuthPalette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: _AuthPalette.accent,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _AuthPalette.danger),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryAuthButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, size: 24),
                ],
              ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _AuthPalette.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _AuthPalette.accent.withOpacity(0.65),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _SwitchAuthMode extends StatelessWidget {
  final String mutedText;
  final String actionText;
  final VoidCallback onTap;

  const _SwitchAuthMode({
    required this.mutedText,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _AuthPalette.muted,
          ),
          children: [
            TextSpan(text: '$mutedText '),
            TextSpan(
              text: actionText,
              style: const TextStyle(
                color: _AuthPalette.accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifyPanel extends StatelessWidget {
  final String email;
  final VoidCallback onBackToLogin;

  const _VerifyPanel({required this.email, required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('verify_panel'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 28),
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
          color: _AuthPalette.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: _AuthPalette.green.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                color: _AuthPalette.green.withOpacity(0.16),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: _AuthPalette.green,
            size: 44,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Check your email',
          style: TextStyle(
            color: _AuthPalette.text,
            fontSize: 31,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          email,
          style: const TextStyle(
            color: _AuthPalette.accent,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Open the verification link, then return here to sign in.',
            style: TextStyle(
              color: _AuthPalette.muted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 30),
        _PrimaryAuthButton(
          label: 'Back to Login',
          isLoading: false,
          onPressed: onBackToLogin,
        ),
      ],
    ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.06);
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AuthPalette.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AuthPalette.danger.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: _AuthPalette.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _AuthPalette.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthParticle {
  Offset position;
  Offset velocity;
  final double radius;

  _AuthParticle({
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

class _AuthBackgroundPainter extends CustomPainter {
  final List<_AuthParticle> particles;

  _AuthBackgroundPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withOpacity(0.28)
      ..strokeWidth = 0.5;
    const spacing = 54.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final atomPaint = Paint()..color = _AuthPalette.accent.withOpacity(0.38);
    final bondPaint = Paint()..strokeWidth = 1;

    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      particle.update(size);
      canvas.drawCircle(particle.position, particle.radius, atomPaint);

      for (int j = i + 1; j < particles.length; j++) {
        final other = particles[j];
        final distance = (particle.position - other.position).distance;
        if (distance < 112) {
          bondPaint.color = _AuthPalette.accent.withOpacity(
            (1 - (distance / 112)) * 0.32,
          );
          canvas.drawLine(particle.position, other.position, bondPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
