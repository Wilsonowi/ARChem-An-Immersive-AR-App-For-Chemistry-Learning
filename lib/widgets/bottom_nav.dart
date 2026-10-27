import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../home/home_controller.dart';

/// Rounded bottom nav bar with a filled circular button for the centre "AI"
/// tab, sitting flush within the same bar as the other items. Tapping the
/// centre button navigates straight to the AI Agent chat screen, same as
/// any other tab - the AI Tutor and AI Marking flows are one merged screen
/// now, so there's nothing left to disambiguate with a speed-dial.
class AppBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  const AppBottomNavBar({super.key, required this.currentIndex});

  static const _routes = [
    '/home',
    '/chapters',
    '/chat',
    '/experiments',
    '/quiz-type',
  ];
  static const _centerIndex = 2;

  static const _items = [
    _NavItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Chapters',
    ),
    _NavItem(
      icon: Icons.auto_awesome_rounded,
      activeIcon: Icons.auto_awesome_rounded,
      label: 'AI',
    ),
    _NavItem(
      icon: Icons.science_outlined,
      activeIcon: Icons.science_rounded,
      label: 'Lab',
    ),
    _NavItem(
      icon: Icons.quiz_outlined,
      activeIcon: Icons.quiz_rounded,
      label: 'Quizzes',
    ),
  ];

  void _navigate(BuildContext context, WidgetRef ref, int i) {
    if (i == currentIndex) return;
    if (_routes[i] == '/home') {
      ref.read(homeControllerProvider.notifier).load();
    }
    context.go(_routes[i]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.45)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_items.length, (i) {
            if (i == _centerIndex) {
              return Expanded(
                child: Center(
                  child: _CenterButton(
                    icon: _items[i].activeIcon,
                    onTap: () => _navigate(context, ref, i),
                  ),
                ),
              );
            }
            return Expanded(
              child: _NavCell(
                item: _items[i],
                isActive: i == currentIndex,
                onTap: () => _navigate(context, ref, i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavCell({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.textPrimary : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isActive ? item.activeIcon : item.icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CenterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.indigo,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
