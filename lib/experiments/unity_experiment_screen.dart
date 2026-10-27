import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class UnityExperimentScreen extends StatefulWidget {
  final String experimentName;

  const UnityExperimentScreen({super.key, required this.experimentName});

  @override
  State<UnityExperimentScreen> createState() => _UnityExperimentScreenState();
}

class _UnityExperimentScreenState extends State<UnityExperimentScreen> {
  UnityWidgetController? _unityController;
  bool _unityReady = false;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    final displayName = _displayName(widget.experimentName);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: UnityWidget(
              onUnityCreated: _onUnityCreated,
              onUnityMessage: _onUnityMessage,
              fullscreen: false,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GlassIconButton(
                      icon: Icons.close_rounded,
                      onTap: _leaveExperiment,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UNITY LAB', style: AppTextStyles.labelSmall),
                            const SizedBox(height: 2),
                            Text(
                              displayName,
                              style: AppTextStyles.headingSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_unityReady)
            const Positioned.fill(child: _UnityLoadingOverlay()),
          if (_completed)
            Positioned(
              left: 16,
              right: 16,
              bottom: 28,
              child: _CompletionBanner(onBack: _leaveExperiment),
            ),
        ],
      ),
    );
  }

  void _onUnityCreated(UnityWidgetController controller) {
    _unityController = controller;
    setState(() => _unityReady = true);
    _loadExperimentScene();
  }

  void _loadExperimentScene() {
    final controller = _unityController;
    if (controller == null) return;

    controller.postMessage(
      'SceneLoader',
      'LoadReaction',
      widget.experimentName,
    );
  }

  void _onUnityMessage(dynamic message) {
    final text = message.toString();
    if (text.contains('REACTION_COMPLETE')) {
      setState(() => _completed = true);
    }
  }

  void _leaveExperiment() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/experiments');
    }
  }

  String _displayName(String raw) {
    switch (raw) {
      case 'CuCO3_Heating':
        return 'CuCO3 Heating';
      case 'RateOfReactionExperiment':
        return 'Rate of Reaction';
      case 'Neutralisation':
        return 'Neutralisation';
      case 'SaltFormation':
        return 'Salt Formation';
      default:
        return raw.replaceAll('_', ' ');
    }
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}

class _UnityLoadingOverlay extends StatelessWidget {
  const _UnityLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.72)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 46,
              height: 46,
              child: CircularProgressIndicator(
                color: AppColors.cyan,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Loading Unity experiment...',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  final VoidCallback onBack;

  const _CompletionBanner({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Experiment completed',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.green,
              ),
            ),
          ),
          TextButton(onPressed: onBack, child: const Text('Done')),
        ],
      ),
    );
  }
}
