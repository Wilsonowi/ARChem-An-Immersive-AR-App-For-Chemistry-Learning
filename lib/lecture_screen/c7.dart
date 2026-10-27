import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
// import 'active_quiz_screen.dart'; // Uncomment when ready

// ─────────────────────────────────────────
// DESIGN TOKENS (Light Theme)
// ─────────────────────────────────────────
class C {
  static const bg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const primary = Color(0xFF0EA5E9);
  static const primaryDim = Color(0xFFE0F2FE);
  static const textMain = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
  static const textMuted2 = Color(0xFF94A3B8);
  static const eqBg = Color(0xFFF8FAFC);
  static const success = Color(0xFF10B981);
  static const successDim = Color(0xFFECFDF5);
  static const successText = Color(0xFF047857);
  static const amber = Color(0xFFF59E0B);
  static const amberDim = Color(0xFFFEF3C7);
  static const violet = Color(0xFF8B5CF6);
  static const violetDim = Color(0xFFEDE9FE);
  static const red = Color(0xFFEF4444);
  static const redDim = Color(0xFFFEF2F2);
  static const pink = Color(0xFFEC4899);
  static const teal = Color(0xFF14B8A6);
  static const indigo = Color(0xFF6366F1);
}

// ─────────────────────────────────────────
// ENTRY POINT (standalone preview)
// ─────────────────────────────────────────
void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light().copyWith(
      scaffoldBackgroundColor: C.bg,
      colorScheme: const ColorScheme.light(
        primary: C.primary,
        surface: C.surface,
      ),
    ),
    home: const LectureChapter7Screen(),
  );
}

// ─────────────────────────────────────────
// MAIN LECTURE SCREEN — Chapter 7
// ─────────────────────────────────────────
class LectureChapter7Screen extends StatefulWidget {
  const LectureChapter7Screen({super.key});
  @override
  State<LectureChapter7Screen> createState() => _LectureChapter7ScreenState();
}

class _LectureChapter7ScreenState extends State<LectureChapter7Screen>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int _current = 0;

  static const int _total = 5;

  final List<_PanelMeta> _panels = const [
    _PanelMeta('Measuring Rate', Icons.speed_rounded, C.primary),
    _PanelMeta('Affecting Factors', Icons.tune_rounded, C.amber),
    _PanelMeta('Daily Applications', Icons.home_rounded, C.success),
    _PanelMeta('Collision Theory', Icons.scatter_plot_rounded, C.violet),
    _PanelMeta('Energy Profiles', Icons.show_chart_rounded, C.red),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween(
      begin: const Offset(0.03, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _animCtrl.reverse().then((_) {
      _pageCtrl.jumpToPage(page);
      setState(() => _current = page);
      _animCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = _panels[_current];
    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(
        children: [
          CustomPaint(painter: _DotPainter(), size: Size.infinite),
          Column(
            children: [
              _TopBar(
                tag: 'Chapter 7 · Rate of Reaction',
                accent: meta.color,
                onBack: () => context.go('/home'),
              ),
              _StepTabs(panels: _panels, current: _current, onTap: _goTo),
              _ProgressBar(
                progress: (_current + 1) / _total,
                accent: meta.color,
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: PageView(
                      controller: _pageCtrl,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => setState(() => _current = i),
                      children: [
                        const _Panel1(),
                        const _Panel2(),
                        const _Panel3(),
                        const _Panel4(),
                        _Panel5(
                          onGoToQuiz: () {
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (_) => const ActiveQuizScreen(topic: 'Rate of Reaction'),
                            // ));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _NavRow(
                current: _current,
                total: _total,
                accent: meta.color,
                onPrev: _current > 0 ? () => _goTo(_current - 1) : null,
                onNext: _current < _total - 1
                    ? () => _goTo(_current + 1)
                    : () async {
                        await SupabaseService.instance
                            .markStudyPlanStageProgress(
                              chapterNumber: 7,
                              lectureCompleted: true,
                            );
                        if (context.mounted) context.go('/chapters');
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// PANEL META
// ─────────────────────────────────────────
class _PanelMeta {
  final String title;
  final IconData icon;
  final Color color;
  const _PanelMeta(this.title, this.icon, this.color);
}

// ─────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String tag;
  final Color accent;
  final VoidCallback onBack;
  const _TopBar({
    required this.tag,
    required this.accent,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Container(
      color: C.bg.withOpacity(0.9),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: accent.withOpacity(0.2)),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: C.border),
              ),
              child: const Text(
                'Exit',
                style: TextStyle(
                  fontSize: 13,
                  color: C.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────
// STEP TABS
// ─────────────────────────────────────────
class _StepTabs extends StatelessWidget {
  final List<_PanelMeta> panels;
  final int current;
  final ValueChanged<int> onTap;
  const _StepTabs({
    required this.panels,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: C.bg.withOpacity(0.9),
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(panels.length, (i) {
          final p = panels[i];
          final active = i == current;
          final done = i < current;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: active ? p.color.withOpacity(0.1) : C.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: active ? p.color.withOpacity(0.3) : C.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      done ? Icons.check_circle_rounded : p.icon,
                      size: 14,
                      color: active
                          ? p.color
                          : done
                          ? C.success
                          : C.textMuted2,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      p.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active
                            ? p.color
                            : done
                            ? C.textMain
                            : C.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
}

// ─────────────────────────────────────────
// PROGRESS BAR
// ─────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color accent;
  const _ProgressBar({required this.progress, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
    height: 3,
    color: C.surface,
    child: FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: progress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────
// NAV ROW
// ─────────────────────────────────────────
class _NavRow extends StatelessWidget {
  final int current, total;
  final Color accent;
  final VoidCallback? onPrev, onNext;
  const _NavRow({
    required this.current,
    required this.total,
    required this.accent,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
    decoration: BoxDecoration(
      color: C.bg,
      boxShadow: [
        BoxShadow(
          color: C.textMain.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onPrev,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              decoration: BoxDecoration(
                color: current > 0 ? C.surface : C.surface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: current > 0 ? C.border : Colors.transparent,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Back',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: current > 0 ? C.textMuted : C.textMuted2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: current < total - 1 ? accent : C.success,
                boxShadow: [
                  BoxShadow(
                    color: (current < total - 1 ? accent : C.success)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                current < total - 1 ? 'Continue' : 'Finish',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: C.bg,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────

Widget _panelScroll(List<Widget> children) => SingleChildScrollView(
  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  ),
);

Widget _heading(String text, IconData icon) => Padding(
  padding: const EdgeInsets.only(bottom: 20),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.border),
        ),
        child: Icon(icon, color: C.textMain, size: 24),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: C.textMain,
          ),
        ),
      ),
    ],
  ),
);

class _ContentCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData? icon;
  const _ContentCard({required this.title, required this.body, this.icon});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.border.withOpacity(0.8)),
      boxShadow: [
        BoxShadow(
          color: C.textMain.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: C.primary, size: 22),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: C.textMain,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          body,
          style: const TextStyle(fontSize: 15, color: C.textMuted, height: 1.6),
        ),
      ],
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _InfoCard({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? C.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: c,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EqLabel extends StatelessWidget {
  final String text;
  const _EqLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      color: C.textMuted,
      letterSpacing: 1.0,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _EqBox extends StatelessWidget {
  final String? label;
  final String equation;
  final String? subLabel;
  final String? subEq;
  final Color accent;

  const _EqBox({
    required this.equation,
    this.label,
    this.subLabel,
    this.subEq,
    this.accent = C.primary,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: C.eqBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
    ),
    child: Column(
      children: [
        if (label != null) ...[_EqLabel(label!), const SizedBox(height: 8)],
        Text(
          equation,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: accent,
            height: 1.4,
          ),
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 16),
          Divider(color: accent.withOpacity(0.15), height: 1, thickness: 1.5),
          const SizedBox(height: 16),
          _EqLabel(subLabel!),
          const SizedBox(height: 8),
          Text(
            subEq ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: C.textMain,
              height: 1.4,
            ),
          ),
        ],
      ],
    ),
  );
}

// ─────────────────────────────────────────
// MEASUREMENT METHOD CARD
// ─────────────────────────────────────────
class _MeasurementCard extends StatelessWidget {
  final IconData icon;
  final String change;
  final String method;
  final Color accent;
  final bool isLast;

  const _MeasurementCard({
    required this.icon,
    required this.change,
    required this.method,
    required this.accent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    change,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: C.textMain,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    method,
                    style: const TextStyle(
                      fontSize: 12,
                      color: C.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (!isLast) const Divider(color: C.border, height: 1),
    ],
  );
}

// ─────────────────────────────────────────
// FAST/SLOW REACTION CHIP GROUP
// ─────────────────────────────────────────
class _SpeedGroup extends StatelessWidget {
  final String label;
  final List<String> examples;
  final Color accent;
  final IconData icon;

  const _SpeedGroup({
    required this.label,
    required this.examples,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withOpacity(0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: examples
              .map(
                (e) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: accent.withOpacity(0.2)),
                  ),
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// UNITS TABLE ROW
// ─────────────────────────────────────────
class _UnitRow extends StatelessWidget {
  final String quantity;
  final String units;
  final bool isLast;

  const _UnitRow({
    required this.quantity,
    required this.units,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                quantity,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: C.textMain,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: C.primaryDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                units,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: C.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      if (!isLast) const Divider(color: C.border, height: 1),
    ],
  );
}

// ─────────────────────────────────────────
// FACTOR CARD (with mini causal arrow)
// ─────────────────────────────────────────
class _FactorCard extends StatelessWidget {
  final IconData icon;
  final String factor;
  final String change;
  final String effect;
  final Color accent;

  const _FactorCard({
    required this.icon,
    required this.factor,
    required this.change,
    required this.effect,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: C.textMain.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: accent, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                factor,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                change,
                style: const TextStyle(
                  fontSize: 12,
                  color: C.textMain,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.arrow_forward_rounded, size: 12, color: accent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      effect,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// APPLICATION CARD (use-case + factor tag)
// ─────────────────────────────────────────
class _UseCaseCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final String tag;
  final Color accent;

  const _UseCaseCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.tag,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: C.textMain.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: C.textMuted,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// COLLISION REQUIREMENT CARD
// ─────────────────────────────────────────
class _CollisionRequirementCard extends StatelessWidget {
  final String number;
  final String title;
  final String desc;
  final IconData icon;
  final Color accent;

  const _CollisionRequirementCard({
    required this.number,
    required this.title,
    required this.desc,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withOpacity(0.25)),
      boxShadow: [
        BoxShadow(
          color: C.textMain.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: C.bg,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Icon(icon, color: accent, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: C.textMuted,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// CAUSAL CHAIN VISUAL (factor → ... → rate increases)
// ─────────────────────────────────────────
class _CausalChain extends StatelessWidget {
  final String factor;
  final List<String> steps;
  final Color accent;

  const _CausalChain({
    required this.factor,
    required this.steps,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: C.textMain.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            factor,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: C.bg,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(steps.length, (i) {
          final isLast = i == steps.length - 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isLast
                      ? Icons.check_circle_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: isLast ? C.success : accent.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isLast ? FontWeight.w800 : FontWeight.w600,
                      color: isLast ? C.successText : C.textMain,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// ENERGY PROFILE DIAGRAM (SVG-style via CustomPaint)
// ─────────────────────────────────────────
class _EnergyProfileDiagram extends StatelessWidget {
  final bool isExothermic;
  const _EnergyProfileDiagram({required this.isExothermic});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: (isExothermic ? C.red : C.primary).withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: (isExothermic ? C.red : C.primary).withOpacity(0.25),
      ),
    ),
    child: Column(
      children: [
        _EqLabel(isExothermic ? 'EXOTHERMIC REACTION' : 'ENDOTHERMIC REACTION'),
        const SizedBox(height: 14),
        SizedBox(
          height: 160,
          width: double.infinity,
          child: CustomPaint(
            painter: _EnergyCurvePainter(
              isExothermic: isExothermic,
              accent: isExothermic ? C.red : C.primary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isExothermic
              ? 'Reactants start HIGH, products end LOW.\nΔH is negative — heat is released to surroundings.'
              : 'Reactants start LOW, products end HIGH.\nΔH is positive — heat is absorbed from surroundings.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isExothermic ? C.red : C.primary,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

class _EnergyCurvePainter extends CustomPainter {
  final bool isExothermic;
  final Color accent;
  _EnergyCurvePainter({required this.isExothermic, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final startY = isExothermic ? h * 0.25 : h * 0.65;
    final endY = isExothermic ? h * 0.65 : h * 0.25;
    final peakY = h * 0.08;

    final path = Path()
      ..moveTo(0, startY)
      ..quadraticBezierTo(w * 0.3, startY, w * 0.42, peakY)
      ..quadraticBezierTo(w * 0.5, peakY - 6, w * 0.58, peakY)
      ..quadraticBezierTo(w * 0.7, endY, w, endY);

    final linePaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Dashed baseline for reactants
    final dashPaint = Paint()
      ..color = C.textMuted2
      ..strokeWidth = 1;
    _drawDashedLine(
      canvas,
      Offset(0, startY),
      Offset(w * 0.42, startY),
      dashPaint,
    );
    _drawDashedLine(canvas, Offset(w * 0.58, endY), Offset(w, endY), dashPaint);

    // Ea bracket
    final eaPaint = Paint()
      ..color = C.amber
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(w * 0.42, startY), Offset(w * 0.42, peakY), eaPaint);

    // Labels
    _drawText(
      canvas,
      'Reactants',
      Offset(w * 0.04, startY + (isExothermic ? 10 : -22)),
      C.textMain,
    );
    _drawText(
      canvas,
      'Products',
      Offset(w * 0.74, endY + (isExothermic ? -22 : 10)),
      C.textMain,
    );
    _drawText(
      canvas,
      'Eₐ',
      Offset(w * 0.44, (startY + peakY) / 2 - 6),
      C.amber,
      bold: true,
    );

    final progressPaint = Paint()
      ..color = C.textMuted2
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, h - 2), Offset(w, h - 2), progressPaint);
    _drawText(
      canvas,
      'Progress of reaction →',
      Offset(w * 0.28, h - 2),
      C.textMuted,
      fontSize: 10,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double distance = (end - start).distance;
    final dx = (end.dx - start.dx) / distance;
    final dy = (end.dy - start.dy) / distance;
    double covered = 0;
    while (covered < distance) {
      final segStart = Offset(start.dx + dx * covered, start.dy + dy * covered);
      final segLen = covered + dashWidth > distance
          ? distance - covered
          : dashWidth;
      final segEnd = Offset(
        start.dx + dx * (covered + segLen),
        start.dy + dy * (covered + segLen),
      );
      canvas.drawLine(segStart, segEnd, paint);
      covered += dashWidth + dashSpace;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    Color color, {
    bool bold = false,
    double fontSize = 11,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────
// PANEL 1 — Determining Rate of Reaction (7.1)
// ─────────────────────────────────────────
class _Panel1 extends StatelessWidget {
  const _Panel1();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Measuring Rate', Icons.speed_rounded),

    const _ContentCard(
      title: 'What is Rate of Reaction?',
      icon: Icons.info_outline_rounded,
      body:
          'Rate of reaction measures how fast reactants are used up, or '
          'how fast products form — change in quantity per unit time.\n\n'
          'Reactions can be average (over a time interval) or '
          'instantaneous (at one specific moment, found from the gradient '
          'of a tangent on a graph).',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'AVERAGE RATE OF REACTION',
      equation: 'Rate = ΔV / Δt = (V₂ − V₁) / (t₂ − t₁)',
      subLabel: 'INSTANTANEOUS RATE',
      subEq: 'Gradient of the tangent at time t',
      accent: C.primary,
    ),
    const SizedBox(height: 20),

    const Text(
      'How We Measure Change',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 4),
    const Text(
      'Pick the method that matches what the reaction produces or consumes.',
      style: TextStyle(
        fontSize: 13,
        color: C.textMuted,
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 14),

    Container(
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.border),
        boxShadow: [
          BoxShadow(
            color: C.textMain.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: const [
          SizedBox(height: 6),
          _MeasurementCard(
            icon: Icons.close_rounded,
            change: 'Formation of precipitate',
            method: 'Time for an "X" mark to disappear under a flask',
            accent: C.primary,
          ),
          _MeasurementCard(
            icon: Icons.monitor_weight_outlined,
            change: 'Decrease in mass',
            method: 'Electronic balance (for gas-releasing reactions)',
            accent: C.amber,
          ),
          _MeasurementCard(
            icon: Icons.bubble_chart_rounded,
            change: 'Increase in gas volume',
            method: 'Gas syringe',
            accent: C.violet,
          ),
          _MeasurementCard(
            icon: Icons.speed_rounded,
            change: 'Change in pressure',
            method: 'Pressure meter (for gas reactions)',
            accent: C.teal,
          ),
          _MeasurementCard(
            icon: Icons.bolt_rounded,
            change: 'Electrical conductivity',
            method: 'Ammeter (for reactions involving mobile ions)',
            accent: C.indigo,
          ),
          _MeasurementCard(
            icon: Icons.science_rounded,
            change: 'Change in pH',
            method: 'pH meter',
            accent: C.red,
            isLast: true,
          ),
        ],
      ),
    ),
    const SizedBox(height: 20),

    const Text(
      'Fast vs Slow Reactions',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _SpeedGroup(
      label: 'FAST REACTIONS',
      examples: [
        'Electric cells',
        'Match ignition',
        'Gas combustion',
        'Fireworks',
      ],
      accent: C.red,
      icon: Icons.flash_on_rounded,
    ),
    const SizedBox(height: 10),
    const _SpeedGroup(
      label: 'SLOW REACTIONS',
      examples: [
        'Rock erosion',
        'Fermentation',
        'Food decay',
        'Metal corrosion',
        'Photosynthesis',
      ],
      accent: C.success,
      icon: Icons.hourglass_bottom_rounded,
    ),
    const SizedBox(height: 20),

    const Text(
      'Units of Rate',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),
    Container(
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.border),
        boxShadow: [
          BoxShadow(
            color: C.textMain.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: const [
          SizedBox(height: 4),
          _UnitRow(quantity: 'Solid mass changes', units: 'g s⁻¹ / g min⁻¹'),
          _UnitRow(
            quantity: 'Gas volume changes',
            units: 'cm³ s⁻¹ / cm³ min⁻¹',
          ),
          _UnitRow(
            quantity: 'Concentration changes',
            units: 'mol dm⁻³ s⁻¹',
            isLast: true,
          ),
        ],
      ),
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 2 — Factors Affecting Rate (7.2)
// ─────────────────────────────────────────
class _Panel2 extends StatelessWidget {
  const _Panel2();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Factors Affecting Rate', Icons.tune_rounded),

    const _ContentCard(
      title: 'Four Main Factors',
      icon: Icons.checklist_rounded,
      body:
          'Different substances react at different rates depending on '
          'four key physical factors. Changing any one of these speeds '
          'up — or slows down — the reaction.',
    ),
    const SizedBox(height: 20),

    const _FactorCard(
      icon: Icons.grain_rounded,
      factor: 'Size of Reactants',
      change: 'Smaller solid pieces = larger total surface area',
      effect: 'Higher rate of reaction',
      accent: C.primary,
    ),
    const SizedBox(height: 12),
    const _FactorCard(
      icon: Icons.opacity_rounded,
      factor: 'Concentration',
      change: 'More solute in a fixed volume = more particles packed in',
      effect: 'Higher rate of reaction',
      accent: C.violet,
    ),
    const SizedBox(height: 12),
    const _FactorCard(
      icon: Icons.thermostat_rounded,
      factor: 'Temperature',
      change: 'More heat = particles move faster, more energy',
      effect: 'Higher rate of reaction',
      accent: C.red,
    ),
    const SizedBox(height: 12),
    const _FactorCard(
      icon: Icons.science_rounded,
      factor: 'Presence of a Catalyst',
      change: 'Provides an easier reaction pathway',
      effect: 'Higher rate — catalyst itself stays unchanged',
      accent: C.success,
    ),
    const SizedBox(height: 12),
    const _FactorCard(
      icon: Icons.compress_rounded,
      factor: 'Pressure (gases only)',
      change: 'Compressing a gas packs particles into less volume',
      effect: 'Acts like ↑ concentration → higher rate',
      accent: C.amber,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'A catalyst speeds up the reaction but its OWN mass is identical '
          'before and after — it isn\'t consumed.',
      color: C.success,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 3 — Daily Applications (7.3)
// ─────────────────────────────────────────
class _Panel3 extends StatelessWidget {
  const _Panel3();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Daily Applications', Icons.home_rounded),

    const _ContentCard(
      title: 'Controlling Speed On Purpose',
      icon: Icons.tune_rounded,
      body:
          'We INCREASE rate to make useful processes faster (cooking, '
          'cleaning exhaust gases). We DECREASE rate to delay unwanted '
          'processes (food spoiling).',
    ),
    const SizedBox(height: 20),

    const Text(
      'Examples by Factor',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _UseCaseCard(
      emoji: '💊',
      title: 'Chewing antacid tablets',
      description:
          'Breaking the tablet into pieces increases surface area — speeds up neutralising stomach acid.',
      tag: 'SIZE',
      accent: C.primary,
    ),
    const SizedBox(height: 8),
    const _UseCaseCard(
      emoji: '🥔',
      title: 'Cutting potatoes into strips',
      description:
          'More surface area exposed to heat — cooks faster than a whole potato.',
      tag: 'SIZE',
      accent: C.primary,
    ),
    const SizedBox(height: 8),
    const _UseCaseCard(
      emoji: '🧊',
      title: 'Refrigerating food',
      description:
          'Lower temperature slows down bacterial decay — keeps food fresh longer.',
      tag: 'TEMPERATURE',
      accent: C.red,
    ),
    const SizedBox(height: 8),
    const _UseCaseCard(
      emoji: '🍳',
      title: 'Frying vs boiling',
      description:
          'Oil reaches ~180°C vs water\'s 100°C — frying cooks food much faster.',
      tag: 'TEMPERATURE',
      accent: C.red,
    ),
    const SizedBox(height: 8),
    const _UseCaseCard(
      emoji: '🚗',
      title: 'Compressed petrol-air mixture',
      description:
          'Higher concentration in the engine cylinder burns and explodes rapidly to power the car.',
      tag: 'CONCENTRATION',
      accent: C.violet,
    ),
    const SizedBox(height: 8),
    const _UseCaseCard(
      emoji: '🏭',
      title: 'Acidic pollution corroding buildings',
      description:
          'High concentration of acidic pollutants speeds up iron corrosion.',
      tag: 'CONCENTRATION',
      accent: C.violet,
    ),
    const SizedBox(height: 8),
    const _UseCaseCard(
      emoji: '🌫️',
      title: 'Catalytic converters',
      description:
          'Platinum (Pt) catalyst quickly converts harmful exhaust gases (CO, NOₓ, hydrocarbons) into H₂O, CO₂, N₂.',
      tag: 'CATALYST',
      accent: C.success,
    ),
    const SizedBox(height: 8),
    const _UseCaseCard(
      emoji: '🍞',
      title: 'Yeast in fermentation',
      description:
          'Yeast acts as a biological catalyst, converting glucose into ethanol.',
      tag: 'CATALYST',
      accent: C.success,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 4 — Collision Theory (7.4a)
// ─────────────────────────────────────────
class _Panel4 extends StatelessWidget {
  const _Panel4();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Collision Theory', Icons.scatter_plot_rounded),

    const _ContentCard(
      title: 'Why Reactions Happen At All',
      icon: Icons.bubble_chart_rounded,
      body:
          'For a reaction to occur, particles must constantly move and '
          'COLLIDE. But not every collision works — only EFFECTIVE '
          'collisions lead to a reaction.',
    ),
    const SizedBox(height: 16),

    const Text(
      'Requirements for an Effective Collision',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _CollisionRequirementCard(
      number: '1',
      icon: Icons.bolt_rounded,
      title: 'Minimum Energy (Activation Energy, Eₐ)',
      desc:
          'Particles must collide with at least the activation energy — the energy barrier to start the reaction.',
      accent: C.amber,
    ),
    const SizedBox(height: 10),
    const _CollisionRequirementCard(
      number: '2',
      icon: Icons.explore_rounded,
      title: 'Correct Orientation',
      desc:
          'Particles must collide facing the right way to break old bonds and form new ones.',
      accent: C.violet,
    ),
    const SizedBox(height: 20),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Rate of reaction = frequency of EFFECTIVE collisions. Every '
          'factor (temperature, concentration, size, catalyst) works by '
          'changing this frequency.',
      color: C.violet,
    ),
    const SizedBox(height: 20),

    const Text(
      'How Each Factor Drives Effective Collisions',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _CausalChain(
      factor: 'CONCENTRATION / PRESSURE ↑',
      steps: [
        'More particles per unit volume',
        'Frequency of collisions increases',
        'Frequency of EFFECTIVE collisions increases',
        'Rate of reaction increases',
      ],
      accent: C.violet,
    ),
    const SizedBox(height: 12),
    const _CausalChain(
      factor: 'SIZE OF REACTANT ↓',
      steps: [
        'Total surface area exposed increases',
        'Frequency of collisions increases',
        'Frequency of EFFECTIVE collisions increases',
        'Rate of reaction increases',
      ],
      accent: C.primary,
    ),
    const SizedBox(height: 12),
    const _CausalChain(
      factor: 'TEMPERATURE ↑',
      steps: [
        'Kinetic energy of particles increases',
        'More particles reach energy ≥ Eₐ',
        'Frequency of EFFECTIVE collisions increases',
        'Rate of reaction increases',
      ],
      accent: C.red,
    ),
    const SizedBox(height: 12),
    const _CausalChain(
      factor: 'CATALYST PRESENT',
      steps: [
        'Provides an alternative pathway with lower Eₐ\'',
        'More particles can reach the new (lower) Eₐ\'',
        'Frequency of EFFECTIVE collisions increases',
        'Rate of reaction increases',
      ],
      accent: C.success,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 5 — Energy Profile Diagrams (7.4b)
// ─────────────────────────────────────────
class _Panel5 extends StatelessWidget {
  final VoidCallback onGoToQuiz;
  const _Panel5({required this.onGoToQuiz});

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Energy Profile Diagrams', Icons.show_chart_rounded),

    const _ContentCard(
      title: 'Visualising Energy Change',
      icon: Icons.timeline_rounded,
      body:
          'An energy profile diagram plots the energy content of '
          'reactants and products against the progress of the reaction. '
          'It shows the activation energy barrier and the overall heat '
          'change, ΔH.',
    ),
    const SizedBox(height: 20),

    const _EnergyProfileDiagram(isExothermic: true),
    const SizedBox(height: 20),
    const _EnergyProfileDiagram(isExothermic: false),
    const SizedBox(height: 20),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'A catalyst LOWERS the activation energy hump (Eₐ\' < Eₐ) but '
          'never changes the overall ΔH — the starting and ending energy '
          'levels stay exactly the same.',
      color: C.success,
    ),
    const SizedBox(height: 24),

    // Chapter complete
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [C.successDim, C.success.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: C.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: C.bg, size: 16),
              ),
              const SizedBox(width: 12),
              const Text(
                'Chapter 7 complete!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: C.successText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'You\'ve covered how rate of reaction is measured, the factors '
            'that affect it, real-world applications, and the collision '
            'theory that explains it all. Test your understanding with the quiz below.',
            style: TextStyle(
              fontSize: 15,
              color: C.successText,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),

    SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: onGoToQuiz,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: C.border, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: C.textMain,
        ),
        child: const Text(
          'Go to Quiz — Chapter 7',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    ),
  ]);
}

// ─────────────────────────────────────────
// DOT PAINTER
// ─────────────────────────────────────────
class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFCBD5E1).withOpacity(0.4)
      ..strokeWidth = 1.0;
    const s = 24.0;
    for (double x = 0; x < size.width; x += s) {
      for (double y = 0; y < size.height; y += s) {
        canvas.drawCircle(Offset(x, y), 1.5, p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
