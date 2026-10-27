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
    home: const LectureChapter3Screen(),
  );
}

// ─────────────────────────────────────────
// MAIN LECTURE SCREEN — Chapter 3
// ─────────────────────────────────────────
class LectureChapter3Screen extends StatefulWidget {
  const LectureChapter3Screen({super.key});
  @override
  State<LectureChapter3Screen> createState() => _LectureChapter3ScreenState();
}

class _LectureChapter3ScreenState extends State<LectureChapter3Screen>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int _current = 0;

  static const int _total = 6;

  final List<_PanelMeta> _panels = const [
    _PanelMeta('Relative Mass', Icons.balance_rounded, C.primary),
    _PanelMeta('The Mole', Icons.blur_circular_rounded, C.violet),
    _PanelMeta('Mole Formulas', Icons.calculate_rounded, C.amber),
    _PanelMeta('Chemical Formula', Icons.text_fields_rounded, C.pink),
    _PanelMeta('Ions & Compounds', Icons.hub_rounded, C.success),
    _PanelMeta('Chemical Equations', Icons.functions_rounded, C.red),
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
                tag: 'Chapter 3 · Mole Concept & Equations',
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
                        _Panel6(
                          onGoToQuiz: () {
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (_) => const ActiveQuizScreen(topic: 'The Mole Concept, Chemical Formula and Equation'),
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
                              chapterNumber: 3,
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
// FORMULA VARIABLE CARD (n = mass/Mr etc.)
// ─────────────────────────────────────────
class _FormulaCard extends StatelessWidget {
  final String numberLabel;
  final String formulaTop;
  final String formulaBottom;
  final String topMeaning;
  final String bottomMeaning;
  final Color accent;

  const _FormulaCard({
    required this.numberLabel,
    required this.formulaTop,
    required this.formulaBottom,
    required this.topMeaning,
    required this.bottomMeaning,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: C.textMain.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            numberLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ),
        const SizedBox(width: 18),
        // Fraction display
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              formulaTop,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
            Container(
              width: 70,
              height: 1.5,
              color: accent.withOpacity(0.4),
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            Text(
              formulaBottom,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: C.textMain,
              ),
            ),
          ],
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'n = $topMeaning',
                style: const TextStyle(
                  fontSize: 13,
                  color: C.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '÷ $bottomMeaning',
                style: const TextStyle(
                  fontSize: 13,
                  color: C.textMuted2,
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
// MASS CALCULATION ROW (RAM/RMM list items)
// ─────────────────────────────────────────
class _CalcRow extends StatelessWidget {
  final String formula;
  final String name;
  final String calculation;
  final String result;
  final Color accent;
  final bool isLast;

  const _CalcRow({
    required this.formula,
    required this.name,
    required this.calculation,
    required this.result,
    required this.accent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withOpacity(0.25)),
              ),
              alignment: Alignment.center,
              child: Text(
                formula,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: C.textMain,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    calculation,
                    style: const TextStyle(
                      fontSize: 13,
                      color: C.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: C.successDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                result,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: C.successText,
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
// PARTICLE TYPE CARD (atomic/molecular/ionic)
// ─────────────────────────────────────────
class _ParticleTypeCard extends StatelessWidget {
  final String type;
  final String example;
  final String particleName;
  final Color accent;

  const _ParticleTypeCard({
    required this.type,
    required this.example,
    required this.particleName,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: C.border),
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
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'e.g. $example',
                          style: const TextStyle(
                            fontSize: 13,
                            color: C.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '6.02×10²³\n$particleName',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        height: 1.3,
                      ),
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
// ION CHIP (for cation/anion table)
// ─────────────────────────────────────────
class _IonChip extends StatelessWidget {
  final String name;
  final String formula;
  final Color accent;
  const _IonChip({
    required this.name,
    required this.formula,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: accent.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: accent.withOpacity(0.18)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formula,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: accent,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 11,
            color: C.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// CROSS-OVER METHOD DIAGRAM
// ─────────────────────────────────────────
class _CrossOverDiagram extends StatelessWidget {
  final String cation;
  final String cationCharge;
  final String anion;
  final String anionCharge;
  final String result;

  const _CrossOverDiagram({
    required this.cation,
    required this.cationCharge,
    required this.anion,
    required this.anionCharge,
    required this.result,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: C.violetDim,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.violet.withOpacity(0.25)),
    ),
    child: Column(
      children: [
        const _EqLabel('CROSS-OVER METHOD'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ionBox(cation, cationCharge, C.primary),
            const SizedBox(width: 8),
            const Text(
              '+',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: C.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            _ionBox(anion, anionCharge, C.red),
          ],
        ),
        const SizedBox(height: 8),
        const Icon(Icons.arrow_downward_rounded, color: C.violet, size: 22),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: C.violet.withOpacity(0.3), width: 1.5),
          ),
          child: Text(
            result,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: C.violet,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _ionBox(String ion, String charge, Color accent) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: accent.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Text(
          ion,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: accent,
          ),
        ),
        Text(
          charge,
          style: const TextStyle(
            fontSize: 11,
            color: C.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// STATE SYMBOL ROW
// ─────────────────────────────────────────
class _StateSymbolRow extends StatelessWidget {
  final String symbol;
  final String meaning;
  final Color accent;
  final bool isLast;

  const _StateSymbolRow({
    required this.symbol,
    required this.meaning,
    required this.accent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withOpacity(0.3)),
              ),
              alignment: Alignment.center,
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                meaning,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: C.textMain,
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
// BALANCING EQUATION VISUAL
// ─────────────────────────────────────────
class _BalanceVisual extends StatelessWidget {
  const _BalanceVisual();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: C.eqBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.red.withOpacity(0.3), width: 1.5),
    ),
    child: Column(
      children: [
        const _EqLabel('UNBALANCED'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: C.redDim,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.red.withOpacity(0.3)),
          ),
          child: const Text(
            'H₂ + O₂  →  H₂O',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: C.red,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '2 H atoms left, but only 2 H right ✓ — 2 O atoms left, only 1 O right ✗',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: C.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        const Icon(Icons.arrow_downward_rounded, color: C.success, size: 22),
        const SizedBox(height: 12),
        const _EqLabel('BALANCED'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: C.successDim,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.success.withOpacity(0.3)),
          ),
          child: const Text(
            '2H₂ + O₂  →  2H₂O',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: C.successText,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '4 H atoms both sides ✓ — 2 O atoms both sides ✓',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: C.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// PANEL 1 — Relative Atomic & Molecular Mass (3.1)
// ─────────────────────────────────────────
class _Panel1 extends StatelessWidget {
  const _Panel1();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Relative Mass', Icons.balance_rounded),

    const _ContentCard(
      title: 'Why "Relative" Mass?',
      icon: Icons.info_outline_rounded,
      body:
          'Atoms and molecules are far too small to be weighed directly. '
          'So chemists compare their mass to a standard: 1/12 the mass of '
          'one carbon-12 atom.\n\n'
          '• Relative Atomic Mass (RAM) — for elements\n'
          '• Relative Molecular Mass (RMM) — for molecules\n'
          '• Relative Formula Mass (RFM) — for ionic compounds',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'RELATIVE ATOMIC MASS',
      equation: 'RAM = Average mass of 1 atom ÷ (1/12 × mass of C-12 atom)',
      accent: C.primary,
    ),
    const SizedBox(height: 20),

    const Text(
      'Worked Examples',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 4),
    const Text(
      'Sum the RAM of every atom present in the formula.',
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
          _CalcRow(
            formula: 'O₂',
            name: 'Oxygen gas (RMM)',
            calculation: '2 × RAM(O) = 2 × 16',
            result: '32',
            accent: C.primary,
          ),
          _CalcRow(
            formula: 'H₂O',
            name: 'Water (RMM)',
            calculation: '2 × RAM(H) + RAM(O) = 2(1) + 16',
            result: '18',
            accent: C.violet,
          ),
          _CalcRow(
            formula: 'ZnCl₂',
            name: 'Zinc chloride (RFM)',
            calculation: 'RAM(Zn) + 2 × RAM(Cl) = 65 + 2(35.5)',
            result: '136',
            accent: C.amber,
            isLast: true,
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'RMM is used for molecular substances (covalent compounds). '
          'RFM is used for ionic compounds — since ionic compounds don\'t form true "molecules".',
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 2 — The Mole (3.2 intro)
// ─────────────────────────────────────────
class _Panel2 extends StatelessWidget {
  const _Panel2();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('The Mole', Icons.blur_circular_rounded),

    const _ContentCard(
      title: 'What is a Mole?',
      icon: Icons.scatter_plot_rounded,
      body:
          'The mole (mol) is the SI unit chemists use to measure the amount '
          'of a substance.\n\n'
          'One mole of any substance always contains the same number of '
          'particles: 6.02 × 10²³ — known as the Avogadro constant (Nₐ).',
    ),
    const SizedBox(height: 16),

    // Avogadro highlight
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [C.violetDim, C.violet.withOpacity(0.15)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.violet.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const _EqLabel('AVOGADRO CONSTANT'),
          const SizedBox(height: 10),
          const Text(
            'Nₐ = 6.02 × 10²³ mol⁻¹',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: C.violet,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'particles in exactly 1 mole of any substance',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: C.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 20),

    const Text(
      '1 Mole Contains...',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _ParticleTypeCard(
      type: 'Atomic substance',
      example: 'Copper, Cu',
      particleName: 'atoms',
      accent: C.primary,
    ),
    const SizedBox(height: 10),
    const _ParticleTypeCard(
      type: 'Molecular substance',
      example: 'Water, H₂O',
      particleName: 'molecules',
      accent: C.violet,
    ),
    const SizedBox(height: 10),
    const _ParticleTypeCard(
      type: 'Ionic substance',
      example: 'Sodium chloride, NaCl',
      particleName: 'formula units',
      accent: C.amber,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.swap_horiz_rounded,
      text:
          'The mole is the central "bridge" in chemistry — it connects number '
          'of particles, mass, and gas volume, letting you convert between them.',
      color: C.violet,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 3 — Mole Formulas (3.2 calculations)
// ─────────────────────────────────────────
class _Panel3 extends StatelessWidget {
  const _Panel3();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Mole Formulas', Icons.calculate_rounded),

    const _ContentCard(
      title: 'Three Ways to Find Moles',
      icon: Icons.functions_rounded,
      body:
          'The number of moles (n) can be calculated three different ways, '
          'depending on what information you are given.',
    ),
    const SizedBox(height: 20),

    const _FormulaCard(
      numberLabel: '1',
      formulaTop: 'particles',
      formulaBottom: 'Nₐ',
      topMeaning: 'Number of particles',
      bottomMeaning: 'Avogadro constant (6.02×10²³ mol⁻¹)',
      accent: C.primary,
    ),
    const SizedBox(height: 12),
    const _FormulaCard(
      numberLabel: '2',
      formulaTop: 'mass (g)',
      formulaBottom: 'Mr',
      topMeaning: 'Mass in grams',
      bottomMeaning: 'Molar mass (g mol⁻¹)',
      accent: C.violet,
    ),
    const SizedBox(height: 12),
    const _FormulaCard(
      numberLabel: '3',
      formulaTop: 'Vol. of gas',
      formulaBottom: 'Molar vol.',
      topMeaning: 'Volume of gas (dm³ or cm³)',
      bottomMeaning: 'Molar volume (22.4 / 24 dm³ mol⁻¹)',
      accent: C.amber,
    ),
    const SizedBox(height: 20),

    // Molar volume note
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Molar Volume of a Gas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: C.textMain,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.primaryDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'At STP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: C.primary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '22.4 dm³/mol',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: C.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.amberDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Room conditions',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: C.amber,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '24 dm³/mol',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: C.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Molar mass (g/mol) is numerically equal to RAM, RMM, or RFM — '
          'just with units of grams per mole attached.',
      color: C.success,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 4 — Chemical Formula (3.3)
// ─────────────────────────────────────────
class _Panel4 extends StatelessWidget {
  const _Panel4();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Chemical Formula', Icons.text_fields_rounded),

    const _ContentCard(
      title: 'What is a Chemical Formula?',
      icon: Icons.menu_book_rounded,
      body:
          'A chemical formula represents a substance using letters for atoms '
          'and subscript numbers for how many of each atom are present.',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'EMPIRICAL vs MOLECULAR FORMULA',
      equation: 'Molecular formula = (Empirical formula)ₙ',
      subLabel: 'EXAMPLE — GLUCOSE',
      subEq: 'Empirical: CH₂O   →   Molecular: C₆H₁₂O₆  (n = 6)',
      accent: C.pink,
    ),
    const SizedBox(height: 16),

    Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.pink.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.pink.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Empirical Formula',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: C.pink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Simplest whole-number ratio of atoms',
                  style: TextStyle(
                    fontSize: 12,
                    color: C.textMuted,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Molecular Formula',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: C.primary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Actual number of atoms in 1 molecule',
                  style: TextStyle(
                    fontSize: 12,
                    color: C.textMuted,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 5 — Ions & Compounds (3.3 continued)
// ─────────────────────────────────────────
class _Panel5 extends StatelessWidget {
  const _Panel5();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Ions & Compounds', Icons.hub_rounded),

    const _ContentCard(
      title: 'Building Ionic Formulae',
      icon: Icons.hub_outlined,
      body:
          'Ionic compound formulae are built by balancing — "crossing over" — '
          'the charges of the cation and anion so the overall compound is neutral.',
    ),
    const SizedBox(height: 16),

    // Cross-over example
    const _CrossOverDiagram(
      cation: 'Al',
      cationCharge: '3+',
      anion: 'O',
      anionCharge: '2−',
      result: 'Al₂O₃',
    ),
    const SizedBox(height: 8),
    const Text(
      'The charge of one ion becomes the subscript of the other.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: C.textMuted,
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 20),

    const Text(
      'Common Cations',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 10),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _IonChip(name: 'Sodium', formula: 'Na⁺', accent: C.primary),
        _IonChip(name: 'Potassium', formula: 'K⁺', accent: C.primary),
        _IonChip(name: 'Aluminium', formula: 'Al³⁺', accent: C.primary),
        _IonChip(name: 'Zinc', formula: 'Zn²⁺', accent: C.primary),
        _IonChip(name: 'Magnesium', formula: 'Mg²⁺', accent: C.primary),
        _IonChip(name: 'Iron(II)', formula: 'Fe²⁺', accent: C.primary),
        _IonChip(name: 'Iron(III)', formula: 'Fe³⁺', accent: C.primary),
        _IonChip(name: 'Copper(II)', formula: 'Cu²⁺', accent: C.primary),
        _IonChip(name: 'Calcium', formula: 'Ca²⁺', accent: C.primary),
        _IonChip(name: 'Lead(II)', formula: 'Pb²⁺', accent: C.primary),
        _IonChip(name: 'Ammonium', formula: 'NH₄⁺', accent: C.primary),
      ],
    ),
    const SizedBox(height: 20),

    const Text(
      'Common Anions',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 10),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _IonChip(name: 'Chloride', formula: 'Cl⁻', accent: C.red),
        _IonChip(name: 'Bromide', formula: 'Br⁻', accent: C.red),
        _IonChip(name: 'Iodide', formula: 'I⁻', accent: C.red),
        _IonChip(name: 'Hydroxide', formula: 'OH⁻', accent: C.red),
        _IonChip(name: 'Oxide', formula: 'O²⁻', accent: C.red),
        _IonChip(name: 'Carbonate', formula: 'CO₃²⁻', accent: C.red),
        _IonChip(name: 'Nitrate', formula: 'NO₃⁻', accent: C.red),
        _IonChip(name: 'Sulphate', formula: 'SO₄²⁻', accent: C.red),
        _IonChip(name: 'Phosphate', formula: 'PO₄³⁻', accent: C.red),
        _IonChip(name: 'Manganate(VII)', formula: 'MnO₄⁻', accent: C.red),
        _IonChip(name: 'Dichromate(VI)', formula: 'Cr₂O₇²⁻', accent: C.red),
      ],
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'If both charges are equal (e.g. Mg²⁺ and O²⁻), they cancel out — '
          'giving the simplest ratio MgO, not Mg₂O₂.',
      color: C.success,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 6 — Chemical Equations (3.4)
// ─────────────────────────────────────────
class _Panel6 extends StatelessWidget {
  final VoidCallback onGoToQuiz;
  const _Panel6({required this.onGoToQuiz});

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Chemical Equations', Icons.functions_rounded),

    const _ContentCard(
      title: 'What is a Chemical Equation?',
      icon: Icons.swap_horiz_rounded,
      body:
          'A chemical equation is shorthand for a chemical reaction — '
          'reactants on the left, products on the right, joined by an arrow '
          'meaning "produces".',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'GENERAL FORM',
      equation: 'aA + bB  →  cC + dD',
      subLabel: 'WHERE',
      subEq:
          'A, B = Reactants   |   C, D = Products\na, b, c, d = Stoichiometric coefficients (mole ratio)',
      accent: C.red,
    ),
    const SizedBox(height: 20),

    const _InfoCard(
      icon: Icons.balance_rounded,
      text:
          'Law of Conservation of Mass: the number of atoms of each element '
          'must be equal on both sides — this is why equations must be balanced.',
      color: C.red,
    ),
    const SizedBox(height: 20),

    const Text(
      'Balancing in Action',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),
    const _BalanceVisual(),
    const SizedBox(height: 20),

    // State symbols
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: const Text(
              'Physical State Symbols',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: C.textMain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: const [
                _StateSymbolRow(
                  symbol: '(s)',
                  meaning: 'Solid',
                  accent: C.textMuted,
                ),
                _StateSymbolRow(
                  symbol: '(l)',
                  meaning: 'Liquid',
                  accent: C.primary,
                ),
                _StateSymbolRow(symbol: '(g)', meaning: 'Gas', accent: C.amber),
                _StateSymbolRow(
                  symbol: '(aq)',
                  meaning: 'Aqueous solution (dissolved in water)',
                  accent: C.violet,
                ),
                _StateSymbolRow(
                  symbol: 'Δ',
                  meaning: 'Heating required for the reaction to occur',
                  accent: C.red,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
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
                'Chapter 3 complete!',
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
            'You\'ve covered relative mass, the mole concept, chemical formulae, '
            'ionic bonding, and balancing chemical equations. '
            'Test your understanding with the quiz below.',
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
          'Go to Quiz — Chapter 3',
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
