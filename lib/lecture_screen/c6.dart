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
  static const brown = Color(0xFF92400E);
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
    home: const LectureChapter6Screen(),
  );
}

// ─────────────────────────────────────────
// MAIN LECTURE SCREEN — Chapter 6
// ─────────────────────────────────────────
class LectureChapter6Screen extends StatefulWidget {
  const LectureChapter6Screen({super.key});
  @override
  State<LectureChapter6Screen> createState() => _LectureChapter6ScreenState();
}

class _LectureChapter6ScreenState extends State<LectureChapter6Screen>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int _current = 0;

  static const int _total = 15;

  final List<_PanelMeta> _panels = const [
    _PanelMeta('Water\'s Role', Icons.water_drop_rounded, C.primary),
    _PanelMeta('pH Value', Icons.speed_rounded, C.violet),
    _PanelMeta('Acid/Alkali Strength', Icons.bolt_rounded, C.amber),
    _PanelMeta('Acid Reactions', Icons.science_rounded, C.red),
    _PanelMeta('Alkali Reactions', Icons.science_outlined, C.indigo),
    _PanelMeta('Concentration', Icons.opacity_rounded, C.teal),
    _PanelMeta('Standard Solution', Icons.colorize_rounded, C.pink),
    _PanelMeta('Neutralisation', Icons.balance_rounded, C.success),
    _PanelMeta('Salts & Crystals', Icons.diamond_outlined, C.primary),
    _PanelMeta('Soluble Salt Prep', Icons.invert_colors_rounded, C.amber),
    _PanelMeta('Insoluble Salt Prep', Icons.invert_colors_off_rounded, C.brown),
    _PanelMeta('Heat on Salts', Icons.local_fire_department_rounded, C.red),
    _PanelMeta('Gas Tests', Icons.air_rounded, C.indigo),
    _PanelMeta('Anion Tests', Icons.minimize_rounded, C.violet),
    _PanelMeta('Cation Tests', Icons.add_rounded, C.teal),
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
                tag: 'Chapter 6 · Acid, Base and Salt',
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
                        const _Panel5(),
                        const _Panel6(),
                        const _Panel7(),
                        const _Panel8(),
                        const _Panel9(),
                        const _Panel10(),
                        const _Panel11(),
                        const _Panel12(),
                        const _Panel13(),
                        const _Panel14(),
                        _Panel15(
                          onGoToQuiz: () {
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (_) => const ActiveQuizScreen(topic: 'Acid, Base and Salt'),
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
                              chapterNumber: 6,
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
// PROTIC ACID CARD
// ─────────────────────────────────────────
class _ProticCard extends StatelessWidget {
  final String type;
  final String hCount;
  final String example;
  final Color accent;

  const _ProticCard({
    required this.type,
    required this.hCount,
    required this.example,
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
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            hCount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                example,
                style: const TextStyle(
                  fontSize: 13,
                  color: C.textMuted,
                  fontWeight: FontWeight.w600,
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
// PH SCALE VISUAL
// ─────────────────────────────────────────
class _PhScaleVisual extends StatelessWidget {
  const _PhScaleVisual();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: const [
            _PhBand('0-3', 'Strong\nAcid', Color(0xFFEF4444)),
            _PhBand('4-6', 'Weak\nAcid', Color(0xFFF97316)),
            _PhBand('7', 'Neutral', Color(0xFF10B981)),
            _PhBand('8-10', 'Weak\nAlkali', Color(0xFF0EA5E9)),
            _PhBand('11-14', 'Strong\nAlkali', Color(0xFF8B5CF6)),
          ],
        ),
      ),
      const SizedBox(height: 10),
      const Text(
        'Lower pH = more H⁺ = more acidic   |   Higher pH = more OH⁻ = more alkaline',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: C.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _PhBand extends StatelessWidget {
  final String ph;
  final String label;
  final Color color;
  const _PhBand(this.ph, this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'pH $ph',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────
// STRENGTH COMPARISON (strong vs weak)
// ─────────────────────────────────────────
class _StrengthCard extends StatelessWidget {
  final String title;
  final String equation;
  final String desc;
  final Color accent;
  final bool isComplete;

  const _StrengthCard({
    required this.title,
    required this.equation,
    required this.desc,
    required this.accent,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: C.textMain.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                isComplete ? 'COMPLETE IONISATION' : 'PARTIAL IONISATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            equation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          desc,
          style: const TextStyle(
            fontSize: 13,
            color: C.textMuted,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// REACTION ROW (general formula + example)
// ─────────────────────────────────────────
class _ReactionRow extends StatelessWidget {
  final String label;
  final String formula;
  final String example;
  final Color accent;
  final bool isLast;

  const _ReactionRow({
    required this.label,
    required this.formula,
    required this.example,
    required this.accent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                formula,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: C.textMain,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'e.g. $example',
              style: const TextStyle(
                fontSize: 12,
                color: C.textMuted,
                fontWeight: FontWeight.w500,
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
// FORMULA CARD (fraction-style, reused pattern)
// ─────────────────────────────────────────
class _FormulaCard extends StatelessWidget {
  final String numberLabel;
  final String name;
  final String formula;
  final Color accent;

  const _FormulaCard({
    required this.numberLabel,
    required this.name,
    required this.formula,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            numberLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  color: C.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formula,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: accent,
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
// INDICATOR COLOUR TABLE
// ─────────────────────────────────────────
class _IndicatorTable extends StatelessWidget {
  const _IndicatorTable();

  @override
  Widget build(BuildContext context) => Container(
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
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          color: C.success.withOpacity(0.08),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Indicator',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: C.successText,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Acidic',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: C.red,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Neutral',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: C.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Alkaline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: C.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: C.border, height: 1),
        _indicatorRow(
          'Phenolphthalein',
          'Colourless',
          'Colourless',
          'Pink',
          isOdd: false,
        ),
        const Divider(color: C.border, height: 1),
        _indicatorRow('Methyl orange', 'Red', 'Orange', 'Yellow', isOdd: true),
      ],
    ),
  );

  Widget _indicatorRow(
    String name,
    String acidic,
    String neutral,
    String alkaline, {
    required bool isOdd,
  }) => Container(
    color: isOdd ? C.surface.withOpacity(0.5) : C.card,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: C.textMain,
            ),
          ),
        ),
        Expanded(
          child: Text(
            acidic,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: C.red,
            ),
          ),
        ),
        Expanded(
          child: Text(
            neutral,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: C.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            alkaline,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: C.primary,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// DAILY APPLICATION CARD
// ─────────────────────────────────────────
class _ApplicationCard extends StatelessWidget {
  final String emoji;
  final String field;
  final String description;
  final Color accent;

  const _ApplicationCard({
    required this.emoji,
    required this.field,
    required this.description,
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
              Text(
                field,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 3),
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
// CRYSTAL PROPERTY CHIP
// ─────────────────────────────────────────
class _CrystalPropertyChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CrystalPropertyChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: C.primaryDim,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: C.primary.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Icon(icon, color: C.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: C.primary,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// SALT USE TABLE ROW
// ─────────────────────────────────────────
class _SaltUseRow extends StatelessWidget {
  final String field;
  final String uses;
  final Color accent;
  final bool isLast;

  const _SaltUseRow({
    required this.field,
    required this.uses,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                field,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                uses,
                style: const TextStyle(
                  fontSize: 13,
                  color: C.textMain,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
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
// PREPARATION FLOW STEP
// ─────────────────────────────────────────
class _PrepStep extends StatelessWidget {
  final String number;
  final String text;
  final bool isLast;
  final Color accent;

  const _PrepStep({
    required this.number,
    required this.text,
    this.isLast = false,
    this.accent = C.amber,
  });

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: C.bg,
                ),
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  color: accent.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: isLast ? 0 : 20),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: C.textMain,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// SOLUBILITY TABLE
// ─────────────────────────────────────────
class _SolubilityRow extends StatelessWidget {
  final String saltType;
  final String rule;
  final bool isLast;

  const _SolubilityRow({
    required this.saltType,
    required this.rule,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              saltType,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: C.brown,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              rule,
              style: const TextStyle(
                fontSize: 13,
                color: C.textMuted,
                height: 1.4,
                fontWeight: FontWeight.w500,
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
// GAS TEST CARD
// ─────────────────────────────────────────
class _GasTestCard extends StatelessWidget {
  final String gas;
  final String formula;
  final String method;
  final String observation;
  final Color accent;

  const _GasTestCard({
    required this.gas,
    required this.formula,
    required this.method,
    required this.observation,
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
    clipBehavior: Clip.hardEdge,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 6, color: accent),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        gas,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                          formula,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Method: $method',
                    style: const TextStyle(
                      fontSize: 12,
                      color: C.textMain,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Observation: $observation',
                    style: const TextStyle(
                      fontSize: 12,
                      color: C.textMuted,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────
// QUALITATIVE TEST CARD (anion/cation)
// ─────────────────────────────────────────
class _QualTestCard extends StatelessWidget {
  final String ion;
  final String test;
  final String observation;
  final Color accent;

  const _QualTestCard({
    required this.ion,
    required this.test,
    required this.observation,
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
    padding: const EdgeInsets.all(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            ion,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                test,
                style: const TextStyle(
                  fontSize: 12,
                  color: C.textMain,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                observation,
                style: TextStyle(
                  fontSize: 12,
                  color: accent,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
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
// CATION RESULT ROW
// ─────────────────────────────────────────
class _CationResultRow extends StatelessWidget {
  final String result;
  final String cations;
  final Color accent;
  final bool isLast;

  const _CationResultRow({
    required this.result,
    required this.cations,
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
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result,
                    style: const TextStyle(
                      fontSize: 13,
                      color: C.textMain,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cations,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: accent,
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
// PANEL 1 — Role of Water (6.1)
// ─────────────────────────────────────────
class _Panel1 extends StatelessWidget {
  const _Panel1();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Water\'s Role', Icons.water_drop_rounded),

    const _ContentCard(
      title: 'No Water, No Acidity',
      icon: Icons.info_outline_rounded,
      body:
          'An acid is a substance that ionises in WATER to produce '
          'hydrogen ions (H⁺). An alkali is a base soluble in water that '
          'ionises to produce hydroxide ions (OH⁻).\n\n'
          'Without water, acids and alkalis stay as neutral molecules — '
          'they only show acidic/alkaline properties when dissolved.',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'ACID IONISES IN WATER',
      equation: 'HCl(aq)  →  H⁺(aq) + Cl⁻(aq)',
      subLabel: 'ALKALI IONISES IN WATER',
      subEq: 'NH₃(aq) + H₂O(l) ⇌ NH₄⁺(aq) + OH⁻(aq)',
      accent: C.primary,
    ),
    const SizedBox(height: 20),

    const Text(
      'Basicity of Acids',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 4),
    const Text(
      'How many H⁺ ions does one molecule release?',
      style: TextStyle(
        fontSize: 13,
        color: C.textMuted,
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 14),

    const _ProticCard(
      type: 'Monoprotic acid',
      hCount: '1H⁺',
      example: 'Hydrochloric acid, HCl',
      accent: C.primary,
    ),
    const SizedBox(height: 10),
    const _ProticCard(
      type: 'Diprotic acid',
      hCount: '2H⁺',
      example: 'Sulphuric acid, H₂SO₄',
      accent: C.violet,
    ),
    const SizedBox(height: 10),
    const _ProticCard(
      type: 'Triprotic acid',
      hCount: '3H⁺',
      example: 'Phosphoric acid, H₃PO₄',
      accent: C.red,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'H₃O⁺ (hydroxonium ion) forms when H⁺ attaches to a water molecule — this is the "true" form H⁺ takes in solution.',
      color: C.primary,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 2 — pH Value (6.2)
// ─────────────────────────────────────────
class _Panel2 extends StatelessWidget {
  const _Panel2();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('pH Value', Icons.speed_rounded),

    const _ContentCard(
      title: 'Measuring Acidity',
      icon: Icons.straighten_rounded,
      body:
          'pH measures the concentration of H⁺ ions in a solution, on a '
          'scale from 0 to 14.\n\n'
          '• pH < 7 → acidic\n'
          '• pH = 7 → neutral\n'
          '• pH > 7 → alkaline\n\n'
          'MORE H⁺ → LOWER pH (more acidic). MORE OH⁻ → HIGHER pH (more alkaline).',
    ),
    const SizedBox(height: 20),

    const _PhScaleVisual(),
    const SizedBox(height: 20),

    const _FormulaCard(
      numberLabel: '1',
      name: 'pH formula',
      formula: 'pH = −log [H⁺]',
      accent: C.violet,
    ),
    const SizedBox(height: 10),
    const _FormulaCard(
      numberLabel: '2',
      name: 'pOH formula',
      formula: 'pOH = −log [OH⁻]',
      accent: C.violet,
    ),
    const SizedBox(height: 10),
    const _FormulaCard(
      numberLabel: '3',
      name: 'Relationship',
      formula: 'pH + pOH = 14',
      accent: C.violet,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Each whole pH step represents a 10× change in H⁺ concentration — pH 4 has 10× more H⁺ than pH 5.',
      color: C.violet,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 3 — Strength of Acids/Alkalis (6.3)
// ─────────────────────────────────────────
class _Panel3 extends StatelessWidget {
  const _Panel3();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Acid & Alkali Strength', Icons.bolt_rounded),

    const _ContentCard(
      title: 'Strong vs Weak ≠ Concentrated vs Dilute',
      icon: Icons.compare_arrows_rounded,
      body:
          'Strength depends on the DEGREE OF IONISATION in water — not on '
          'concentration.\n\n'
          'A strong acid/alkali ionises COMPLETELY, producing a high '
          'concentration of H⁺ or OH⁻. A weak acid/alkali ionises only '
          'PARTIALLY, producing a low concentration of ions.',
    ),
    const SizedBox(height: 20),

    const _StrengthCard(
      title: 'Strong Acid — Hydrochloric acid',
      equation: 'HCl(aq)  →  H⁺(aq) + Cl⁻(aq)',
      desc:
          'Single arrow (→) means the reaction goes to completion — every HCl molecule ionises.',
      accent: C.red,
      isComplete: true,
    ),
    const SizedBox(height: 14),
    const _StrengthCard(
      title: 'Weak Acid — Ethanoic acid',
      equation: 'CH₃COOH(aq) ⇌ H⁺(aq) + CH₃COO⁻(aq)',
      desc:
          'Double arrow (⇌) means equilibrium — only SOME molecules ionise at any time.',
      accent: C.amber,
      isComplete: false,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Watch the arrow! → means strong (complete), ⇌ means weak (partial/reversible).',
      color: C.amber,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 4 — Acid Reactions (6.4a)
// ─────────────────────────────────────────
class _Panel4 extends StatelessWidget {
  const _Panel4();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Acid Reactions', Icons.science_rounded),

    const _ContentCard(
      title: 'What Acids React With',
      icon: Icons.science_outlined,
      body:
          'Acids react with bases, reactive metals, and metal carbonates — each producing a salt plus a different second product.',
    ),
    const SizedBox(height: 16),

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
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: const [
          SizedBox(height: 6),
          _ReactionRow(
            label: 'ACID + BASE',
            formula: 'Acid + Base → Salt + Water',
            example: 'HCl + NaOH → NaCl + H₂O',
            accent: C.red,
          ),
          _ReactionRow(
            label: 'ACID + REACTIVE METAL',
            formula: 'Acid + Metal → Salt + Hydrogen gas',
            example: 'H₂SO₄ + Zn → ZnSO₄ + H₂',
            accent: C.red,
          ),
          _ReactionRow(
            label: 'ACID + METAL CARBONATE',
            formula: 'Acid + Carbonate → Salt + Water + CO₂',
            example: 'HCl + CaCO₃ → CaCl₂ + H₂O + CO₂',
            accent: C.red,
            isLast: true,
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Notice: a SALT is always produced. The other product (water, H₂, or CO₂) tells you what the acid reacted with.',
      color: C.red,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 5 — Alkali Reactions (6.4b)
// ─────────────────────────────────────────
class _Panel5 extends StatelessWidget {
  const _Panel5();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Alkali Reactions', Icons.science_outlined),

    const _ContentCard(
      title: 'What Alkalis React With',
      icon: Icons.science_rounded,
      body:
          'Alkalis react with acids, ammonium salts, and metal ions — each producing a different result.',
    ),
    const SizedBox(height: 16),

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
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: const [
          SizedBox(height: 6),
          _ReactionRow(
            label: 'ALKALI + ACID',
            formula: 'Alkali + Acid → Salt + Water',
            example: 'NaOH + HNO₃ → NaNO₃ + H₂O',
            accent: C.indigo,
          ),
          _ReactionRow(
            label: 'ALKALI + AMMONIUM SALT',
            formula: 'Alkali + NH₄ salt → Salt + Water + NH₃ gas',
            example: 'NaOH + NH₄Cl → NaCl + H₂O + NH₃',
            accent: C.indigo,
          ),
          _ReactionRow(
            label: 'ALKALI + METAL ION',
            formula: 'Alkali + Metal ion → Insoluble hydroxide + Cation',
            example: 'NaOH + CuSO₄ → Cu(OH)₂ + Na₂SO₄',
            accent: C.indigo,
            isLast: true,
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Alkali + ammonium salt is a classic test for ammonium ions — the released NH₃ gas turns moist red litmus blue.',
      color: C.indigo,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 6 — Concentration (6.5)
// ─────────────────────────────────────────
class _Panel6 extends StatelessWidget {
  const _Panel6();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Concentration', Icons.opacity_rounded),

    const _ContentCard(
      title: 'How Much Solute, Per Volume',
      icon: Icons.science_outlined,
      body:
          'Concentration tells you how much solute is dissolved in '
          '1 dm³ of solution.\n\n'
          'It can be expressed as mass (g dm⁻³) or as molarity — number '
          'of moles (mol dm⁻³). These convert using molar mass.',
    ),
    const SizedBox(height: 20),

    const _FormulaCard(
      numberLabel: '1',
      name: 'Concentration by mass',
      formula: 'g dm⁻³ = Mass (g) ÷ Volume (dm³)',
      accent: C.teal,
    ),
    const SizedBox(height: 10),
    const _FormulaCard(
      numberLabel: '2',
      name: 'Molarity',
      formula: 'mol dm⁻³ = Moles ÷ Volume (dm³)',
      accent: C.teal,
    ),
    const SizedBox(height: 10),
    const _FormulaCard(
      numberLabel: '3',
      name: 'Moles from volume (cm³)',
      formula: 'n = MV ÷ 1000',
      accent: C.teal,
    ),
    const SizedBox(height: 10),
    const _FormulaCard(
      numberLabel: '4',
      name: 'Molarity from concentration',
      formula: 'Molarity = Concentration ÷ Molar mass',
      accent: C.teal,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Watch your units — formula 3 needs V in cm³ (hence ÷1000), but formulas 1 and 2 need V in dm³ directly.',
      color: C.teal,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 7 — Standard Solution (6.6)
// ─────────────────────────────────────────
class _Panel7 extends StatelessWidget {
  const _Panel7();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Standard Solution', Icons.colorize_rounded),

    const _ContentCard(
      title: 'A Solution of Known Concentration',
      icon: Icons.science_rounded,
      body:
          'A standard solution has a known, accurate concentration. It '
          'can be made from a solid solute, OR by diluting a concentrated '
          'stock solution.\n\n'
          'During dilution, water is added to change the concentration — '
          'but the TOTAL NUMBER OF MOLES of solute stays unchanged.',
    ),
    const SizedBox(height: 20),

    const _EqBox(
      label: 'DILUTION FORMULA',
      equation: 'M₁V₁ = M₂V₂',
      subLabel: 'WHERE',
      subEq:
          'M₁,V₁ = before dilution (stock)\nM₂,V₂ = after dilution (prepared)',
      accent: C.pink,
    ),
    const SizedBox(height: 16),

    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: C.pink.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.pink.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  'BEFORE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: C.pink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Concentrated\nstock solution',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: C.textMain,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: C.pink),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'ADD WATER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: C.pink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('💧', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: C.pink),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'AFTER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: C.pink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Diluted\nsolution',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: C.textMain,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Moles of solute NEVER change during dilution — only the volume (and therefore concentration) changes.',
      color: C.pink,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 8 — Neutralisation (6.7)
// ─────────────────────────────────────────
class _Panel8 extends StatelessWidget {
  const _Panel8();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Neutralisation', Icons.balance_rounded),

    const _ContentCard(
      title: 'Acid Meets Alkali',
      icon: Icons.science_rounded,
      body:
          'Neutralisation is the reaction between an acid and an alkali '
          'to produce ONLY salt and water. The acid loses its acidity, '
          'the alkali loses its alkalinity.\n\n'
          'The real reaction is just H⁺ combining with OH⁻ to form water.',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'IONIC EQUATION',
      equation: 'H⁺(aq) + OH⁻(aq)  →  H₂O(l)',
      subLabel: 'TITRATION CALCULATION',
      subEq: 'MₐVₐ / M_bV_b = a / b',
      accent: C.success,
    ),
    const SizedBox(height: 20),

    const Text(
      'Indicator Colour Changes',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),
    const _IndicatorTable(),
    const SizedBox(height: 20),

    const Text(
      'Applications in Daily Life',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _ApplicationCard(
      emoji: '💊',
      field: 'Medicine',
      description: 'Antacids contain Mg(OH)₂ to neutralise excess stomach HCl.',
      accent: C.success,
    ),
    const SizedBox(height: 8),
    const _ApplicationCard(
      emoji: '🦷',
      field: 'Dental Health',
      description: 'Toothpaste bases neutralise lactic acid from bacteria.',
      accent: C.success,
    ),
    const SizedBox(height: 8),
    const _ApplicationCard(
      emoji: '🌱',
      field: 'Agriculture',
      description: 'Slaked lime (alkaline) treats acidic soil.',
      accent: C.success,
    ),
    const SizedBox(height: 8),
    const _ApplicationCard(
      emoji: '🧴',
      field: 'Hair Health',
      description: 'Weak alkalis in shampoo neutralise acids on hair.',
      accent: C.success,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 9 — Salts, Crystals & Uses (6.8)
// ─────────────────────────────────────────
class _Panel9 extends StatelessWidget {
  const _Panel9();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Salts & Crystals', Icons.diamond_outlined),

    const _ContentCard(
      title: 'What is a Salt?',
      icon: Icons.grain_rounded,
      body:
          'A salt is an ionic compound formed when the H⁺ ion of an acid '
          'is replaced by a metal ion or an ammonium ion (NH₄⁺).\n\n'
          'All salts form crystals — specific geometrical shapes that come '
          'from the orderly, compact arrangement of particles in the lattice.',
    ),
    const SizedBox(height: 16),

    const Text(
      'Physical Properties of Salt Crystals',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 10),
    const _CrystalPropertyChip(
      icon: Icons.crop_square_rounded,
      text: 'Flat surface, straight sides, sharp vertices',
    ),
    const SizedBox(height: 8),
    const _CrystalPropertyChip(
      icon: Icons.category_rounded,
      text: 'Specific shape — cube, cuboid, rhombus, or prism',
    ),
    const SizedBox(height: 8),
    const _CrystalPropertyChip(
      icon: Icons.diversity_3_rounded,
      text: 'Different crystals → different geometrical shapes',
    ),
    const SizedBox(height: 8),
    const _CrystalPropertyChip(
      icon: Icons.architecture_rounded,
      text: 'Fixed angle between two adjacent surfaces',
    ),
    const SizedBox(height: 20),

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
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: const [
          SizedBox(height: 4),
          _SaltUseRow(
            field: 'Food Prep',
            uses: 'NaCl as flavouring; NaHCO₃ for raising dough.',
            accent: C.primary,
          ),
          _SaltUseRow(
            field: 'Preservation',
            uses:
                'Sodium benzoate preserves sauces; sodium nitrate preserves processed meat.',
            accent: C.primary,
          ),
          _SaltUseRow(
            field: 'Agriculture',
            uses: 'NH₄NO₃ as fertiliser; FeSO₄ in pesticides.',
            accent: C.primary,
          ),
          _SaltUseRow(
            field: 'Medicine',
            uses: 'Antiseptics; calcium sulphate for casting broken bones.',
            accent: C.primary,
            isLast: true,
          ),
        ],
      ),
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 10 — Soluble Salt Preparation (6.9a)
// ─────────────────────────────────────────
class _Panel10 extends StatelessWidget {
  const _Panel10();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Soluble Salt Preparation', Icons.invert_colors_rounded),

    const _ContentCard(
      title: 'Two Methods for Soluble Salts',
      icon: Icons.science_rounded,
      body:
          'How you prepare a salt depends on its solubility.\n\n'
          'Soluble salts use ONE of two methods, depending on what type '
          'of salt is needed.',
    ),
    const SizedBox(height: 20),

    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: C.amber.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.amber.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: C.amber,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'METHOD 1',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: C.bg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Titration (Neutralisation)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: C.amber,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Used for: Ammonium, Sodium, and Potassium salts (always soluble — can\'t precipitate them out).',
            style: TextStyle(
              fontSize: 13,
              color: C.textMuted,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 14),

    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: C.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: C.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'METHOD 2',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: C.bg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Acid + Solid Reactant',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: C.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Used for: All other soluble salts — react acid with a solid metal, metal oxide, or metal carbonate. Filter off any excess solid.',
            style: TextStyle(
              fontSize: 13,
              color: C.textMuted,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Ask yourself: is the salt Na/K/NH₄? If yes → titration. If no → react acid with a solid.',
      color: C.amber,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 11 — Insoluble Salt Preparation (6.9b)
// ─────────────────────────────────────────
class _Panel11 extends StatelessWidget {
  const _Panel11();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Insoluble Salt Preparation', Icons.invert_colors_off_rounded),

    const _ContentCard(
      title: 'Double Decomposition',
      icon: Icons.call_split_rounded,
      body:
          'Insoluble salts are made by DOUBLE DECOMPOSITION (precipitation) — '
          'mixing two soluble salt solutions so their ions swap partners, '
          'forming an insoluble salt that precipitates out.',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'EXAMPLE — BARIUM SULPHATE',
      equation: 'Ba²⁺(aq) + SO₄²⁻(aq)  →  BaSO₄(s)',
      accent: C.brown,
    ),
    const SizedBox(height: 20),

    Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Steps in Double Decomposition',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: C.textMain,
            ),
          ),
          SizedBox(height: 18),
          _PrepStep(
            number: '1',
            text:
                'Mix two soluble salt solutions containing the desired cation and anion.',
            accent: C.brown,
          ),
          _PrepStep(
            number: '2',
            text: 'A precipitate forms immediately as the insoluble salt.',
            accent: C.brown,
          ),
          _PrepStep(
            number: '3',
            text: 'Filter the mixture to separate the precipitate.',
            accent: C.brown,
          ),
          _PrepStep(
            number: '4',
            text: 'Wash the precipitate with distilled water, then dry.',
            isLast: true,
            accent: C.brown,
          ),
        ],
      ),
    ),
    const SizedBox(height: 20),

    const Text(
      'Solubility Rules',
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
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: const [
          SizedBox(height: 4),
          _SolubilityRow(saltType: 'Nitrate salts', rule: 'All soluble.'),
          _SolubilityRow(
            saltType: 'Sulphate salts',
            rule: 'All soluble, except PbSO₄, BaSO₄, CaSO₄.',
          ),
          _SolubilityRow(
            saltType: 'Chloride salts',
            rule: 'All soluble, except PbCl₂, AgCl, Hg₂Cl₂.',
          ),
          _SolubilityRow(
            saltType: 'Carbonate salts',
            rule: 'All insoluble, except Na₂CO₃, K₂CO₃, (NH₄)₂CO₃.',
          ),
          _SolubilityRow(
            saltType: 'NH₄, Na, K salts',
            rule: 'All soluble — no exceptions.',
            isLast: true,
          ),
        ],
      ),
    ),
    const SizedBox(height: 12),

    const _InfoCard(
      icon: Icons.info_outline_rounded,
      text:
          'PbCl₂ and PbI₂ are unusual — insoluble in cold water but dissolve in hot water, then re-crystallise on cooling.',
      color: C.brown,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 12 — Effect of Heat on Salts (6.10a)
// ─────────────────────────────────────────
class _Panel12 extends StatelessWidget {
  const _Panel12();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Effect of Heat on Salts', Icons.local_fire_department_rounded),

    const _ContentCard(
      title: 'Thermal Decomposition',
      icon: Icons.whatshot_rounded,
      body:
          'Heating solid salts breaks them down into a metal oxide plus a released gas. The exact gas depends on the type of salt.',
    ),
    const SizedBox(height: 20),

    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: C.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.red.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Carbonate Salts',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: C.red,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Decompose to form a metal oxide + CO₂ gas (turns limewater cloudy).',
            style: TextStyle(
              fontSize: 13,
              color: C.textMuted,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'EXCEPTION: Sodium and Potassium carbonates do NOT decompose on heating.',
            style: TextStyle(
              fontSize: 12,
              color: C.red,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 14),

    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: C.amber.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.amber.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Nitrate Salts',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: C.amber,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Decompose to form a metal oxide + brown NO₂ gas (turns blue litmus red) + O₂ gas.',
            style: TextStyle(
              fontSize: 13,
              color: C.textMuted,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Na and K are the two exceptions you must remember across this WHOLE chapter — their carbonates resist heat decomposition.',
      color: C.red,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 13 — Gas Tests (6.10b)
// ─────────────────────────────────────────
class _Panel13 extends StatelessWidget {
  const _Panel13();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Gas Tests', Icons.air_rounded),

    const _ContentCard(
      title: 'Identifying Gases',
      icon: Icons.search_rounded,
      body:
          'Each gas has a specific test with a distinctive observation — these are essential for identifying products in reactions.',
    ),
    const SizedBox(height: 16),

    const _GasTestCard(
      gas: 'Oxygen',
      formula: 'O₂',
      method: 'Glowing wooden splinter',
      observation: 'Splinter rekindles',
      accent: C.primary,
    ),
    const SizedBox(height: 8),
    const _GasTestCard(
      gas: 'Hydrogen',
      formula: 'H₂',
      method: 'Lighted wooden splinter',
      observation: '"Pop" sound produced',
      accent: C.violet,
    ),
    const SizedBox(height: 8),
    const _GasTestCard(
      gas: 'Carbon dioxide',
      formula: 'CO₂',
      method: 'Bubble into limewater',
      observation: 'Limewater turns cloudy',
      accent: C.textMuted,
    ),
    const SizedBox(height: 8),
    const _GasTestCard(
      gas: 'Ammonia',
      formula: 'NH₃',
      method: 'Moist red litmus paper',
      observation: 'Turns blue (pungent, alkaline)',
      accent: C.success,
    ),
    const SizedBox(height: 8),
    const _GasTestCard(
      gas: 'Chlorine',
      formula: 'Cl₂',
      method: 'Moist blue litmus paper',
      observation: 'Turns red, then bleached',
      accent: C.teal,
    ),
    const SizedBox(height: 8),
    const _GasTestCard(
      gas: 'Hydrogen chloride',
      formula: 'HCl',
      method: 'Glass rod + conc. ammonia',
      observation: 'White fumes form',
      accent: C.indigo,
    ),
    const SizedBox(height: 8),
    const _GasTestCard(
      gas: 'Sulphur dioxide',
      formula: 'SO₂',
      method: 'Bubble into acidified KMnO₄',
      observation: 'Purple solution decolourises',
      accent: C.pink,
    ),
    const SizedBox(height: 8),
    const _GasTestCard(
      gas: 'Nitrogen dioxide',
      formula: 'NO₂',
      method: 'Moist blue litmus paper',
      observation: 'Turns red (brown, acidic gas)',
      accent: C.amber,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Group by colour clue: NH₃ turns litmus BLUE (alkaline); Cl₂, HCl, NO₂ all relate to RED/bleached litmus (acidic).',
      color: C.indigo,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 14 — Anion Tests (6.11a)
// ─────────────────────────────────────────
class _Panel14 extends StatelessWidget {
  const _Panel14();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Anion Tests', Icons.minimize_rounded),

    const _ContentCard(
      title: 'Confirming Anions',
      icon: Icons.fact_check_rounded,
      body:
          'Qualitative analysis identifies the ions in an unknown salt. '
          'Anions are confirmed using specific dilute acids combined with '
          'reagents like silver nitrate or barium chloride.',
    ),
    const SizedBox(height: 16),

    const _QualTestCard(
      ion: 'CO₃²⁻',
      test: 'Add dilute acid.',
      observation: 'Effervescence — gas turns limewater cloudy (CO₂).',
      accent: C.violet,
    ),
    const SizedBox(height: 10),
    const _QualTestCard(
      ion: 'Cl⁻',
      test: 'Add dilute HNO₃, then AgNO₃(aq).',
      observation: 'White precipitate forms (AgCl).',
      accent: C.violet,
    ),
    const SizedBox(height: 10),
    const _QualTestCard(
      ion: 'SO₄²⁻',
      test: 'Add dilute HCl, then BaCl₂(aq).',
      observation: 'White precipitate forms (BaSO₄).',
      accent: C.violet,
    ),
    const SizedBox(height: 10),
    const _QualTestCard(
      ion: 'NO₃⁻',
      test: 'Add dilute H₂SO₄, FeSO₄(aq), then conc. H₂SO₄.',
      observation: 'A brown ring (complex compound) forms.',
      accent: C.violet,
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'CONFIRMATORY SULPHATE TEST',
      equation: 'Ba²⁺(aq) + SO₄²⁻(aq)  →  BaSO₄(s)',
      accent: C.violet,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Two different white precipitates (AgCl vs BaSO₄) — always note WHICH reagent was added to know which anion is confirmed.',
      color: C.violet,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 15 — Cation Tests (6.11b)
// ─────────────────────────────────────────
class _Panel15 extends StatelessWidget {
  final VoidCallback onGoToQuiz;
  const _Panel15({required this.onGoToQuiz});

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Cation Tests', Icons.add_rounded),

    const _ContentCard(
      title: 'Confirming Cations',
      icon: Icons.fact_check_rounded,
      body:
          'Cations are identified by the colour and solubility of '
          'precipitates formed with sodium hydroxide (NaOH) and aqueous '
          'ammonia (NH₃).',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'EXAMPLE PRECIPITATION',
      equation: 'Zn²⁺(aq) + 2OH⁻(aq)  →  Zn(OH)₂(s)',
      accent: C.teal,
    ),
    const SizedBox(height: 20),

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
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: const [
          SizedBox(height: 6),
          _CationResultRow(
            result: 'White precipitate, soluble in excess NaOH',
            cations: 'Zn²⁺, Al³⁺, Pb²⁺',
            accent: C.teal,
          ),
          _CationResultRow(
            result: 'White precipitate, insoluble in excess NaOH',
            cations: 'Mg²⁺, Ca²⁺',
            accent: C.teal,
          ),
          _CationResultRow(
            result: 'White precipitate, soluble in excess NH₃',
            cations: 'Zn²⁺',
            accent: C.teal,
          ),
          _CationResultRow(
            result: 'White precipitate, insoluble in excess NH₃',
            cations: 'Mg²⁺, Al³⁺, Pb²⁺',
            accent: C.teal,
          ),
          _CationResultRow(
            result:
                'Blue precipitate → dissolves in excess NH₃ (dark blue solution)',
            cations: 'Cu²⁺',
            accent: C.primary,
          ),
          _CationResultRow(
            result: 'Green precipitate, insoluble in excess NaOH and NH₃',
            cations: 'Fe²⁺',
            accent: C.success,
          ),
          _CationResultRow(
            result: 'Brown precipitate, insoluble in excess NaOH and NH₃',
            cations: 'Fe³⁺',
            accent: C.brown,
            isLast: true,
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Zn²⁺ is the trickiest — its precipitate dissolves in BOTH excess NaOH AND excess NH₃, unlike Al³⁺ or Pb²⁺.',
      color: C.teal,
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
                'Chapter 6 complete!',
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
            'You\'ve covered acids, alkalis, pH, concentration, neutralisation, '
            'salt preparation, the effect of heat, and qualitative analysis. '
            'This was a long chapter — test your understanding with the quiz below.',
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
          'Go to Quiz — Chapter 6',
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
