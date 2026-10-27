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
    home: const LectureChapter5Screen(),
  );
}

// ─────────────────────────────────────────
// MAIN LECTURE SCREEN — Chapter 5
// ─────────────────────────────────────────
class LectureChapter5Screen extends StatefulWidget {
  const LectureChapter5Screen({super.key});
  @override
  State<LectureChapter5Screen> createState() => _LectureChapter5ScreenState();
}

class _LectureChapter5ScreenState extends State<LectureChapter5Screen>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int _current = 0;

  static const int _total = 9;

  final List<_PanelMeta> _panels = const [
    _PanelMeta('Compound Basics', Icons.join_inner_rounded, C.primary),
    _PanelMeta('Ionic Bond', Icons.swap_horiz_rounded, C.amber),
    _PanelMeta('Covalent Bond', Icons.share_rounded, C.violet),
    _PanelMeta('Ionic vs Covalent', Icons.compare_arrows_rounded, C.pink),
    _PanelMeta('Hydrogen Bond', Icons.water_drop_rounded, C.indigo),
    _PanelMeta('Dative Bond', Icons.call_merge_rounded, C.teal),
    _PanelMeta('Metallic Bond', Icons.bolt_rounded, C.red),
    _PanelMeta('Compound Structures', Icons.hub_rounded, C.success),
    _PanelMeta('Uses in Daily Life', Icons.home_rounded, C.primary),
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
                tag: 'Chapter 5 · Chemical Bond',
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
                        _Panel9(
                          onGoToQuiz: () {
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (_) => const ActiveQuizScreen(topic: 'Chemical Bond'),
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
                              chapterNumber: 5,
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
// ELECTRON TRANSFER DIAGRAM (Ionic Bond)
// ─────────────────────────────────────────
class _ElectronTransferDiagram extends StatelessWidget {
  final String metal;
  final String metalIon;
  final String nonMetal;
  final String nonMetalIon;
  const _ElectronTransferDiagram({
    required this.metal,
    required this.metalIon,
    required this.nonMetal,
    required this.nonMetalIon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: C.amberDim,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.amber.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        const _EqLabel('ELECTRON TRANSFER'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _atomBox(metal, C.primary, false),
            Column(
              children: [
                Icon(
                  Icons.arrow_forward_rounded,
                  color: C.amber.withOpacity(0.7),
                  size: 20,
                ),
                const Text(
                  'e⁻',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: C.amber,
                  ),
                ),
              ],
            ),
            _atomBox(nonMetal, C.red, false),
          ],
        ),
        const SizedBox(height: 8),
        const Icon(Icons.arrow_downward_rounded, color: C.amber, size: 22),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _atomBox(metalIon, C.primary, true),
            const Icon(Icons.favorite_rounded, color: C.amber, size: 18),
            _atomBox(nonMetalIon, C.red, true),
          ],
        ),
      ],
    ),
  );

  Widget _atomBox(String label, Color accent, bool isIon) => Container(
    width: 90,
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: accent.withOpacity(isIon ? 0.5 : 0.25),
        width: isIon ? 2 : 1,
      ),
    ),
    alignment: Alignment.center,
    child: Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: accent,
      ),
    ),
  );
}

// ─────────────────────────────────────────
// COMPARISON TABLE (Ionic vs Covalent)
// ─────────────────────────────────────────
class _ComparisonRow extends StatelessWidget {
  final String feature;
  final String ionic;
  final String covalent;
  final bool isLast;

  const _ComparisonRow({
    required this.feature,
    required this.ionic,
    required this.covalent,
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
              feature,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: C.textMuted,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: C.amber.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ionic,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: C.amber,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: C.violet.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      covalent,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: C.violet,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      if (!isLast) const Divider(color: C.border, height: 1),
    ],
  );
}

// ─────────────────────────────────────────
// BOND TYPE STRENGTH BAR (single/double/triple covalent)
// ─────────────────────────────────────────
class _BondTypeCard extends StatelessWidget {
  final String type;
  final String pairs;
  final String example;
  final int lineCount;
  final Color accent;

  const _BondTypeCard({
    required this.type,
    required this.pairs,
    required this.example,
    required this.lineCount,
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
        // Visual bond lines
        Container(
          width: 56,
          height: 40,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              lineCount,
              (i) => Container(
                width: 36,
                height: 2.5,
                margin: const EdgeInsets.symmetric(vertical: 1.5),
                color: accent,
              ),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                pairs,
                style: const TextStyle(
                  fontSize: 12,
                  color: C.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            example,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// EVERYDAY EXAMPLE CARD (hydrogen bond daily life)
// ─────────────────────────────────────────
class _EverydayCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final Color accent;

  const _EverydayCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: accent.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: C.textMain.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: C.textMuted,
                  height: 1.5,
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
// DATIVE BOND VISUAL
// ─────────────────────────────────────────
class _DativeBondVisual extends StatelessWidget {
  const _DativeBondVisual();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: C.teal.withOpacity(0.06),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.teal.withOpacity(0.25)),
    ),
    child: Column(
      children: [
        const _EqLabel('EXAMPLE — AMMONIUM ION FORMATION'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.teal.withOpacity(0.4)),
              ),
              child: const Column(
                children: [
                  Text(
                    'NH₃',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: C.teal,
                    ),
                  ),
                  Text(
                    'lone pair on N',
                    style: TextStyle(
                      fontSize: 10,
                      color: C.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '+',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: C.textMuted,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.red.withOpacity(0.4)),
              ),
              child: const Column(
                children: [
                  Text(
                    'H⁺',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: C.red,
                    ),
                  ),
                  Text(
                    'empty shell',
                    style: TextStyle(
                      fontSize: 10,
                      color: C.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Icon(Icons.arrow_downward_rounded, color: C.teal, size: 22),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: C.teal.withOpacity(0.4), width: 1.5),
          ),
          child: const Text(
            'NH₄⁺',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: C.teal,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'N donates BOTH electrons in the shared pair — that\'s what makes it dative, not a normal covalent bond.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: C.textMuted,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// SEA OF ELECTRONS VISUAL (Metallic Bond)
// ─────────────────────────────────────────
class _SeaOfElectronsVisual extends StatelessWidget {
  const _SeaOfElectronsVisual();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: C.redDim,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.red.withOpacity(0.25)),
    ),
    child: Column(
      children: [
        const _EqLabel('SEA OF DELOCALISED ELECTRONS'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List.generate(9, (i) {
            return Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: C.red.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: C.red.withOpacity(0.4)),
              ),
              alignment: Alignment.center,
              child: const Text(
                '+',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: C.red,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        const Text(
          'e⁻  e⁻  e⁻  e⁻  e⁻  e⁻  e⁻  e⁻',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: C.red,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Positive metal ions sit in a "sea" of freely-moving delocalised electrons. '
          'Electrostatic attraction between them is the metallic bond.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: C.red,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// STRUCTURE COMPARISON CARD (simple vs giant molecule)
// ─────────────────────────────────────────
class _StructureCompareCard extends StatelessWidget {
  final String type;
  final String structure;
  final String bonding;
  final String meltingPoint;
  final String examples;
  final Color accent;

  const _StructureCompareCard({
    required this.type,
    required this.structure,
    required this.bonding,
    required this.meltingPoint,
    required this.examples,
    required this.accent,
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
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          color: accent.withOpacity(0.08),
          child: Text(
            type,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _structDetail('Structure', structure, accent),
              const SizedBox(height: 10),
              _structDetail('Bonding', bonding, accent),
              const SizedBox(height: 10),
              _structDetail('Melting/Boiling Point', meltingPoint, accent),
              const SizedBox(height: 10),
              _structDetail('Examples', examples, accent),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _structDetail(String label, String value, Color accent) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: accent,
          letterSpacing: 0.4,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          color: C.textMain,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────
// DAILY USE CARD (sector + ionic/covalent compound)
// ─────────────────────────────────────────
class _DailyUseCard extends StatelessWidget {
  final String sector;
  final IconData icon;
  final String ionicUse;
  final String covalentUse;
  final Color accent;

  const _DailyUseCard({
    required this.sector,
    required this.icon,
    required this.ionicUse,
    required this.covalentUse,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: accent.withOpacity(0.2)),
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              sector,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: C.amber.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IONIC',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: C.amber,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ionicUse,
                      style: const TextStyle(
                        fontSize: 12,
                        color: C.textMain,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: C.violet.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COVALENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: C.violet,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      covalentUse,
                      style: const TextStyle(
                        fontSize: 12,
                        color: C.textMain,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
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
  );
}

// ─────────────────────────────────────────
// PANEL 1 — Compound Basics (5.1)
// ─────────────────────────────────────────
class _Panel1 extends StatelessWidget {
  const _Panel1();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Basics of Compound Formation', Icons.join_inner_rounded),

    const _ContentCard(
      title: 'Why Atoms Bond',
      icon: Icons.info_outline_rounded,
      body:
          'Compounds form when two or more elements combine — either by '
          'transferring or sharing electrons — to achieve a stable octet '
          '(8 electrons) or duplet (2 electrons) arrangement.\n\n'
          'Noble gases are unreactive because they already have this '
          'stable arrangement. Every other element must form a chemical '
          'bond using its valence electrons to become stable.',
    ),
    const SizedBox(height: 20),

    Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.amber.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.amber.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.swap_horiz_rounded, color: C.amber, size: 22),
                SizedBox(height: 8),
                Text(
                  'Transfer',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: C.amber,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Forms ionic bonds',
                  style: TextStyle(
                    fontSize: 12,
                    color: C.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.violet.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.violet.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.share_rounded, color: C.violet, size: 22),
                SizedBox(height: 8),
                Text(
                  'Sharing',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: C.violet,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Forms covalent bonds',
                  style: TextStyle(
                    fontSize: 12,
                    color: C.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'The "goal" is always the same — a full outer shell. HOW atoms get '
          'there (transfer vs sharing) determines the bond type.',
      color: C.primary,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 2 — Ionic Bond (5.2)
// ─────────────────────────────────────────
class _Panel2 extends StatelessWidget {
  const _Panel2();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Ionic Bond', Icons.swap_horiz_rounded),

    const _ContentCard(
      title: 'Transfer of Electrons',
      icon: Icons.compare_arrows_rounded,
      body:
          'An ionic bond forms when electrons transfer from a metal atom '
          'to a non-metal atom. This produces two oppositely-charged ions '
          'that attract each other through strong electrostatic forces.\n\n'
          '• Metal donates electron(s) → becomes a cation (+)\n'
          '• Non-metal accepts electron(s) → becomes an anion (–)',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'SODIUM DONATES AN ELECTRON',
      equation: 'Na  →  Na⁺ + e⁻',
      subLabel: 'FLUORINE ACCEPTS AN ELECTRON',
      subEq: 'F + e⁻  →  F⁻',
      accent: C.amber,
    ),
    const SizedBox(height: 20),

    const _ElectronTransferDiagram(
      metal: 'Na',
      metalIon: 'Na⁺',
      nonMetal: 'F',
      nonMetalIon: 'F⁻',
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Both ions end up with a full outer shell (octet/duplet) — '
          'that\'s the driving force behind the transfer.',
      color: C.amber,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 3 — Covalent Bond (5.3)
// ─────────────────────────────────────────
class _Panel3 extends StatelessWidget {
  const _Panel3();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Covalent Bond', Icons.share_rounded),

    const _ContentCard(
      title: 'Sharing of Electrons',
      icon: Icons.handshake_outlined,
      body:
          'Covalent bonds form when non-metal atoms SHARE electrons to '
          'achieve a stable duplet or octet arrangement.\n\n'
          'The shared pairs can be visualised using a Lewis structure, '
          'which displays all the valence electrons involved.',
    ),
    const SizedBox(height: 20),

    const Text(
      'Types of Covalent Bonds',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _BondTypeCard(
      type: 'Single Bond',
      pairs: '1 shared electron pair',
      example: 'H–H',
      lineCount: 1,
      accent: C.primary,
    ),
    const SizedBox(height: 10),
    const _BondTypeCard(
      type: 'Double Bond',
      pairs: '2 shared electron pairs',
      example: 'O=O',
      lineCount: 2,
      accent: C.violet,
    ),
    const SizedBox(height: 10),
    const _BondTypeCard(
      type: 'Triple Bond',
      pairs: '3 shared electron pairs',
      example: 'N≡N',
      lineCount: 3,
      accent: C.red,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'More shared pairs = stronger and shorter bond. A triple bond is '
          'stronger than a double bond, which is stronger than a single bond.',
      color: C.violet,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 4 — Ionic vs Covalent (5.3 comparison table)
// ─────────────────────────────────────────
class _Panel4 extends StatelessWidget {
  const _Panel4();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Ionic vs Covalent', Icons.compare_arrows_rounded),

    const _ContentCard(
      title: 'Side by Side',
      icon: Icons.balance_rounded,
      body:
          'Both bond types involve valence electrons and both let atoms achieve a stable arrangement — but the mechanism and the particles formed are completely different.',
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
        children: [
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: C.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'IONIC BOND',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: C.amber,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: C.violet.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'COVALENT BOND',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: C.violet,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: C.border, height: 1),
          const _ComparisonRow(
            feature: 'ATOMS INVOLVED',
            ionic: 'Metal + Non-metal',
            covalent: 'Non-metal + Non-metal',
          ),
          const _ComparisonRow(
            feature: 'MECHANISM',
            ionic: 'Transfer of electrons',
            covalent: 'Sharing of electrons',
          ),
          const _ComparisonRow(
            feature: 'PARTICLES FORMED',
            ionic: 'Positive ion + Negative ion',
            covalent: 'Neutral molecules',
            isLast: true,
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.check_circle_outline_rounded,
      text:
          'Similarities: both involve ONLY valence electrons, and both result '
          'in atoms achieving a stable octet or duplet arrangement.',
      color: C.success,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 5 — Hydrogen Bond (5.4)
// ─────────────────────────────────────────
class _Panel5 extends StatelessWidget {
  const _Panel5();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Hydrogen Bond', Icons.water_drop_rounded),

    const _ContentCard(
      title: 'A Special Attraction Force',
      icon: Icons.link_rounded,
      body:
          'A hydrogen bond is the attraction force between a hydrogen atom '
          'bonded to a highly electronegative atom (N, O, or F) and another '
          'highly electronegative atom (N, O, or F) on a NEARBY molecule.\n\n'
          'Breaking hydrogen bonds — plus weak Van der Waals forces — needs '
          'extra heat energy, which raises boiling points. It also explains '
          'why covalent compounds like ethanol dissolve in water.',
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.thermostat_rounded,
      text:
          'This is why water (H₂O) has a surprisingly high boiling point for '
          'such a small molecule — hydrogen bonds hold the molecules together more strongly than Van der Waals forces alone.',
      color: C.indigo,
    ),
    const SizedBox(height: 20),

    const Text(
      'Hydrogen Bonds in Daily Life',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _EverydayCard(
      emoji: '💧',
      title: 'Wet Hair',
      description:
          'When hair is wet, protein molecules form hydrogen bonds with water '
          'molecules instead of with each other — causing strands to stick together.',
      accent: C.indigo,
    ),
    const SizedBox(height: 10),
    const _EverydayCard(
      emoji: '📖',
      title: 'Turning Book Pages',
      description:
          'A wet finger helps turn pages because water molecules on the finger '
          'form hydrogen bonds with the cellulose in the paper.',
      accent: C.indigo,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 6 — Dative Bond (5.5)
// ─────────────────────────────────────────
class _Panel6 extends StatelessWidget {
  const _Panel6();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Dative Bond', Icons.call_merge_rounded),

    const _ContentCard(
      title: 'A One-Sided Covalent Bond',
      icon: Icons.arrow_right_alt_rounded,
      body:
          'A dative (coordinate) bond is a special type of covalent bond '
          'where the shared electron pair comes from ONLY ONE atom.\n\n'
          'An atom with a lone pair not used in any other bond (like O in '
          'water, or N in ammonia) shares that pair with an ion that has '
          'an EMPTY shell (like H⁺) — both reach stability.',
    ),
    const SizedBox(height: 20),

    const _DativeBondVisual(),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'In a normal covalent bond, each atom contributes ONE electron to '
          'the shared pair. In a dative bond, one atom contributes BOTH.',
      color: C.teal,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 7 — Metallic Bond (5.6)
// ─────────────────────────────────────────
class _Panel7 extends StatelessWidget {
  const _Panel7();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Metallic Bond', Icons.bolt_rounded),

    const _ContentCard(
      title: 'The Sea of Electrons',
      icon: Icons.flash_on_rounded,
      body:
          'A metallic bond is the electrostatic attraction between a "sea" '
          'of delocalised electrons and the positively-charged metal ions '
          'packed closely together in a solid.\n\n'
          'Metal atoms easily donate their valence electrons, which become '
          'free to move throughout the entire structure.',
    ),
    const SizedBox(height: 20),

    const _SeaOfElectronsVisual(),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.electric_bolt_rounded,
      text:
          'This is exactly why metals conduct electricity — the free-moving '
          'electrons carry charge from the negative terminal to the positive terminal.',
      color: C.red,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 8 — Compound Structures (5.7a)
// ─────────────────────────────────────────
class _Panel8 extends StatelessWidget {
  const _Panel8();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Compound Structures', Icons.hub_rounded),

    const _ContentCard(
      title: 'Why Properties Differ',
      icon: Icons.architecture_rounded,
      body:
          'Ionic and covalent compounds have very different physical '
          'properties due to their distinct structures.\n\n'
          '• Ionic compounds: conduct electricity (molten/aqueous), '
          'soluble in water, HIGH melting/boiling points.\n'
          '• Covalent compounds: don\'t conduct electricity, soluble in '
          'organic solvents, LOW melting/boiling points (except giant molecules).',
    ),
    const SizedBox(height: 20),

    const Text(
      'Covalent Compound Structures',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _StructureCompareCard(
      type: 'Simple Molecule',
      structure: 'Small, simple structures — exists as solid, liquid, or gas.',
      bonding:
          'Strong covalent bonds WITHIN molecules, but weak Van der Waals forces BETWEEN molecules.',
      meltingPoint:
          'LOW — only a little heat is needed to overcome weak Van der Waals forces.',
      examples: 'Water (H₂O), Carbon dioxide (CO₂)',
      accent: C.primary,
    ),
    const SizedBox(height: 14),
    const _StructureCompareCard(
      type: 'Giant Molecule',
      structure: 'Very large structure — usually a solid.',
      bonding:
          'Strong covalent bonds ONLY — no Van der Waals forces because the structure is one giant network.',
      meltingPoint:
          'HIGH — a lot of heat is needed to break the strong covalent bonds.',
      examples: 'Silicon dioxide (SiO₂)',
      accent: C.success,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Same bond type (covalent) — but completely different melting points, '
          'because the SCALE of the structure changes what you need to break.',
      color: C.success,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 9 — Uses in Daily Life (5.7b)
// ─────────────────────────────────────────
class _Panel9 extends StatelessWidget {
  final VoidCallback onGoToQuiz;
  const _Panel9({required this.onGoToQuiz});

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Uses in Daily Life', Icons.home_rounded),

    const _ContentCard(
      title: 'Ionic & Covalent Compounds All Around Us',
      icon: Icons.public_rounded,
      body:
          'Both ionic and covalent compounds play important roles across '
          'agriculture, industry, medicine, and the home.',
    ),
    const SizedBox(height: 20),

    const _DailyUseCard(
      sector: 'Agriculture',
      icon: Icons.agriculture_rounded,
      ionicUse:
          'Ammonium nitrate (NH₄NO₃) and potassium chloride (KCl) in fertilisers.',
      covalentUse:
          'Bromoethane (C₂H₅Br) and chloropicrin (CCl₃NO₂) in pesticides.',
      accent: C.success,
    ),
    const SizedBox(height: 12),
    const _DailyUseCard(
      sector: 'Industry',
      icon: Icons.factory_rounded,
      ionicUse: 'Lithium iodide (LiI) used in batteries.',
      covalentUse: 'Paint — contains pigment and turpentine solvent.',
      accent: C.primary,
    ),
    const SizedBox(height: 12),
    const _DailyUseCard(
      sector: 'Medicine',
      icon: Icons.medical_services_rounded,
      ionicUse:
          'Sodium bicarbonate (NaHCO₃) in antacids — relieves gastric pain.',
      covalentUse: 'Paracetamol (C₈H₉NO₂) — treats fever and irritation.',
      accent: C.red,
    ),
    const SizedBox(height: 12),
    const _DailyUseCard(
      sector: 'Domestic Use',
      icon: Icons.home_rounded,
      ionicUse: 'Sodium chlorate(V) (NaClO₃) used in cleaning detergents.',
      covalentUse:
          'Glycerol (C₃H₅(OH)₃) used in moisturising skincare products.',
      accent: C.amber,
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
                'Chapter 5 complete!',
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
            'You\'ve covered ionic, covalent, hydrogen, dative, and metallic bonds, '
            'plus how compound structure determines physical properties and real-world uses. '
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
          'Go to Quiz — Chapter 5',
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
