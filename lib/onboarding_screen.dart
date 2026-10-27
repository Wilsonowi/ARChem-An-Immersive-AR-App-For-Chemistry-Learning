import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';

/// Single, standalone welcome screen shown once before login/register -
/// not a multi-step carousel, so there are no page dots or a skip button.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.1,
            colors: [AppColors.lilacGlow, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(28, 12, 28, 20),
            child: _OnboardingContent(),
          ),
        ),
      ),
    );
  }
}

Future<void> _getStarted(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_done', true);
  if (context.mounted) context.go('/login');
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical -
                    150, // leaves room for the CTA button below
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _HeroGraphic(),
                  SizedBox(height: 40),
                  _Headline(),
                  SizedBox(height: 14),
                  _Subtext(),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _GetStartedSlider(onConfirmed: () => _getStarted(context)),
      ],
    );
  }
}

class _HeroGraphic extends StatelessWidget {
  const _HeroGraphic();

  @override
  Widget build(BuildContext context) {
    final size = (MediaQuery.sizeOf(context).width * 0.62).clamp(180.0, 260.0);
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.indigo.withValues(alpha: 0.18),
                blurRadius: 40,
                offset: const Offset(0, 18),
                spreadRadius: -10,
              ),
            ],
          ),
          child: SvgPicture.asset(
            'assets/illustrations/onboarding_atom.svg',
            width: size,
            height: size,
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          duration: 600.ms,
        );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
          TextSpan(
            style: AppTextStyles.displayMedium.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
            children: [
              const TextSpan(text: 'Your Smart Gateway to\n'),
              TextSpan(
                text: 'Better Learning!',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.indigo,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        )
        .animate(delay: 150.ms)
        .fadeIn(duration: 450.ms)
        .slideY(begin: 0.12, end: 0);
  }
}

class _Subtext extends StatelessWidget {
  const _Subtext();

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Enjoy interactive lessons, quick quizzes, and streaks that make '
            'learning fun every day.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        )
        .animate(delay: 250.ms)
        .fadeIn(duration: 450.ms)
        .slideY(begin: 0.12, end: 0);
  }
}

/// Swipe-to-confirm slider: drag the thumb to the end of the track to
/// trigger [onConfirmed], instead of a plain tap button.
class _GetStartedSlider extends StatefulWidget {
  final VoidCallback onConfirmed;

  const _GetStartedSlider({required this.onConfirmed});

  @override
  State<_GetStartedSlider> createState() => _GetStartedSliderState();
}

class _GetStartedSliderState extends State<_GetStartedSlider> {
  static const double _trackHeight = 60;
  static const double _thumbSize = 48;
  static const double _thumbInset = 6;
  static const double _confirmThreshold = 0.82;

  double _dragProgress = 0; // 0..1
  bool _dragging = false;
  bool _confirmed = false;

  void _onDragUpdate(DragUpdateDetails details, double maxThumbTravel) {
    if (_confirmed || maxThumbTravel <= 0) return;
    setState(() {
      _dragProgress = (_dragProgress + details.delta.dx / maxThumbTravel).clamp(
        0.0,
        1.0,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_confirmed) return;
    final reachedEnd = _dragProgress >= _confirmThreshold;
    setState(() {
      _dragging = false;
      _dragProgress = reachedEnd ? 1.0 : 0.0;
      _confirmed = reachedEnd;
    });
    if (reachedEnd) widget.onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _trackHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxThumbTravel =
              constraints.maxWidth - _thumbSize - _thumbInset * 2;

          return GestureDetector(
            onHorizontalDragStart: _confirmed
                ? null
                : (_) => setState(() => _dragging = true),
            onHorizontalDragUpdate: _confirmed
                ? null
                : (details) => _onDragUpdate(details, maxThumbTravel),
            onHorizontalDragEnd: _confirmed ? null : _onDragEnd,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 34, 7, 56),
                borderRadius: BorderRadius.circular(_trackHeight / 2),
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: _thumbInset + _thumbSize),
                      Expanded(
                        child: Center(
                          child: Opacity(
                            opacity: (1 - _dragProgress * 1.4).clamp(0.0, 1.0),
                            child: Text(
                              'Get Started',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: _thumbInset),
                    ],
                  ),
                  AnimatedPositioned(
                    duration: _dragging
                        ? Duration.zero
                        : const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    left: _thumbInset + _dragProgress * maxThumbTravel,
                    top: (_trackHeight - _thumbSize) / 2,
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _confirmed
                            ? Icons.check_rounded
                            : Icons.keyboard_double_arrow_right_rounded,
                        color: AppColors.indigoDark,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate(delay: 350.ms).fadeIn(duration: 450.ms);
  }
}
