import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';

/// Shared brand logo: the onboarding screen's atom SVG, the app name, and
/// an optional tagline. Used on splash, login, and register so all three
/// share one consistent identity instead of duplicated markup.
class AppLogo extends StatelessWidget {
  final double iconSize;
  final bool showTagline;

  const AppLogo({super.key, this.iconSize = 96, this.showTagline = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.indigo.withValues(alpha: 0.18),
                blurRadius: iconSize * 0.35,
                offset: Offset(0, iconSize * 0.14),
                spreadRadius: -iconSize * 0.08,
              ),
            ],
          ),
          child: SvgPicture.asset(
            'assets/illustrations/onboarding_atom.svg',
            width: iconSize,
            height: iconSize,
          ),
        ),
        SizedBox(height: iconSize * 0.22),
        Text(
          AppStrings.appName,
          style: AppTextStyles.displayLarge.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            AppStrings.appTagline.toUpperCase(),
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.indigo),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
