import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';
import 'widgets/chemistry_background.dart';

class GeneratingPlanScreen extends StatefulWidget {
  final String statusMessage;
  const GeneratingPlanScreen({
    super.key,
    this.statusMessage = 'Generating your study plan...',
  });

  @override
  State<GeneratingPlanScreen> createState() => _GeneratingPlanScreenState();
}

class _GeneratingPlanScreenState extends State<GeneratingPlanScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  int _stepIndex = 0;

  final _steps = [
    _Step(
      icon: Icons.analytics_outlined,
      color: AppColors.indigo,
      label: 'Analysing your results...',
    ),
    _Step(
      icon: Icons.psychology_outlined,
      color: AppColors.green,
      label: 'Identifying weak chapters...',
    ),
    _Step(
      icon: Icons.calendar_month_outlined,
      color: AppColors.amber,
      label: 'Building your daily schedule...',
    ),
    _Step(
      icon: Icons.auto_awesome_rounded,
      color: AppColors.chapter7,
      label: 'Personalising your plan...',
    ),
    _Step(
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.green,
      label: 'Your study plan is ready!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Cycle through steps
    _cycleSteps();
  }

  Future<void> _cycleSteps() async {
    for (int i = 0; i < _steps.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;
      setState(() => _stepIndex = i + 1);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_stepIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        // Purple theme, matching the rest of the app.
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon
              AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + _pulseController.value * 0.08,
                        child: child,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: step.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: step.color.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(step.icon, color: step.color, size: 52),
                    ),
                  )
                  .animate(key: ValueKey(_stepIndex))
                  .scale(
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.6, 0.6),
                  )
                  .fadeIn(),

              const SizedBox(height: 40),

              // Status text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  step.label,
                  key: ValueKey(_stepIndex),
                  style: AppTextStyles.headingMedium.copyWith(
                    color: step.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Please wait while our AI analyses your\ndiagnostic results and builds your plan.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 48),

              // Step indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (i) {
                  final isDone = i < _stepIndex;
                  final isActive = i == _stepIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.green
                          : isActive
                          ? _steps[i].color
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 48),

              // Linear progress
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_stepIndex + 1) / _steps.length,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(step.color),
                  minHeight: 6,
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 12),

              Text(
                '${((_stepIndex + 1) / _steps.length * 100).toInt()}%',
                style: AppTextStyles.labelMedium.copyWith(color: step.color),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final Color color;
  final String label;
  const _Step({required this.icon, required this.color, required this.label});
}
