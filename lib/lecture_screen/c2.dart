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
    home: const LectureChapter2Screen(),
  );
}

// ─────────────────────────────────────────
// MAIN LECTURE SCREEN — Chapter 2
// ─────────────────────────────────────────
class LectureChapter2Screen extends StatefulWidget {
  const LectureChapter2Screen({super.key});
  @override
  State<LectureChapter2Screen> createState() => _LectureChapter2ScreenState();
}

class _LectureChapter2ScreenState extends State<LectureChapter2Screen>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int _current = 0;

  static const int _total = 4;

  final List<_PanelMeta> _panels = const [
    _PanelMeta('States of Matter', Icons.blur_on_rounded, C.primary),
    _PanelMeta('Atomic Models', Icons.history_edu_rounded, C.amber),
    _PanelMeta('Atomic Structure', Icons.adjust_rounded, C.violet),
    _PanelMeta('Isotopes & Uses', Icons.science_rounded, C.success),
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
                tag: 'Chapter 2 · Matter & Atomic Structure',
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
                        _Panel4(
                          onGoToQuiz: () {
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (_) => const ActiveQuizScreen(topic: 'Matter and the Atomic Structure'),
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
                              chapterNumber: 2,
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

class _EqBox extends StatelessWidget {
  final String? label;
  final String equation;
  final String? subLabel;
  final String? subEq;

  const _EqBox({required this.equation, this.label, this.subLabel, this.subEq});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: C.eqBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.primary.withOpacity(0.3), width: 1.5),
    ),
    child: Column(
      children: [
        if (label != null) ...[_EqLabel(label!), const SizedBox(height: 8)],
        Text(
          equation,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: C.primary,
            height: 1.4,
          ),
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 16),
          Divider(
            color: C.primary.withOpacity(0.15),
            height: 1,
            thickness: 1.5,
          ),
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

// ─────────────────────────────────────────
// STATE OF MATTER CARD
// ─────────────────────────────────────────
class _StateCard extends StatelessWidget {
  final String state;
  final String emoji;
  final String arrangement;
  final String kineticEnergy;
  final String attraction;
  final Color accent;

  const _StateCard({
    required this.state,
    required this.emoji,
    required this.arrangement,
    required this.kineticEnergy,
    required this.attraction,
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
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          color: accent.withOpacity(0.08),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Text(
                state,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
        // Properties
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _stateProp(
                'Arrangement',
                arrangement,
                Icons.grid_on_rounded,
                accent,
              ),
              const SizedBox(height: 10),
              _stateProp(
                'Kinetic Energy',
                kineticEnergy,
                Icons.bolt_rounded,
                accent,
              ),
              const SizedBox(height: 10),
              _stateProp(
                'Attraction Force',
                attraction,
                Icons.link_rounded,
                accent,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _stateProp(String label, String value, IconData icon, Color accent) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: C.textMuted,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: C.textMain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────
// STATE CHANGE BADGE
// ─────────────────────────────────────────
class _StateChangeBadge extends StatelessWidget {
  final String from;
  final String to;
  final String process;
  final bool absorbed; // true = absorbs heat, false = releases heat

  const _StateChangeBadge({
    required this.from,
    required this.to,
    required this.process,
    required this.absorbed,
  });

  @override
  Widget build(BuildContext context) {
    final color = absorbed ? C.red : C.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$from → $to',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              process,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// SCIENTIST TIMELINE CARD
// ─────────────────────────────────────────
class _ScientistCard extends StatelessWidget {
  final String name;
  final String years;
  final String discovery;
  final String modelDesc;
  final Color accent;
  final bool isLast;

  const _ScientistCard({
    required this.name,
    required this.years,
    required this.discovery,
    required this.modelDesc,
    required this.accent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      children: [
        // Timeline spine
        Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.person_rounded, color: C.bg, size: 22),
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
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: isLast ? 0 : 20),
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: C.textMain,
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
                          years,
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
                    discovery,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: C.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    modelDesc,
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
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// SUBATOMIC PARTICLE ROW
// ─────────────────────────────────────────
class _ParticleRow extends StatelessWidget {
  final String particle;
  final String symbol;
  final String charge;
  final String mass;
  final Color accent;
  final bool isLast;

  const _ParticleRow({
    required this.particle,
    required this.symbol,
    required this.charge,
    required this.mass,
    required this.accent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Symbol badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.3)),
              ),
              alignment: Alignment.center,
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + charge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    particle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: C.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Charge: $charge',
                    style: const TextStyle(
                      fontSize: 13,
                      color: C.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Mass badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: C.border),
              ),
              child: Text(
                mass,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: C.textMuted,
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
// ATOM NOTATION WIDGET
// ─────────────────────────────────────────
class _AtomNotation extends StatelessWidget {
  const _AtomNotation();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: C.eqBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.violet.withOpacity(0.3), width: 1.5),
    ),
    child: Column(
      children: [
        const _EqLabel('STANDARD NOTATION'),
        const SizedBox(height: 16),
        // Visual notation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left superscript/subscript
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _notationBadge('A', 'Nucleon number', C.violet),
                const SizedBox(height: 4),
                _notationBadge('Z', 'Proton number', C.primary),
              ],
            ),
            const SizedBox(width: 12),
            // Element symbol
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: C.violet.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: C.violet.withOpacity(0.3), width: 2),
              ),
              alignment: Alignment.center,
              child: const Text(
                'X',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: C.violet,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'X = Element symbol\nA = Nucleon number (top left)\nZ = Proton number (bottom left)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: C.textMuted,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _notationBadge(String letter, String label, Color color) => Column(
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          color: C.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────
// ION COMPARISON TABLE
// ─────────────────────────────────────────
class _IonTable extends StatelessWidget {
  const _IonTable();

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
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: C.violet.withOpacity(0.08),
          child: Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  'Particle',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: C.textMuted,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Cl atom',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: C.violet,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Cl⁻ ion',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: C.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: C.border, height: 1),
        _ionRow('Protons', '17', '17', isOdd: false),
        _ionRow('Neutrons', '18', '18', isOdd: true),
        _ionRow('Electrons', '17', '18', isOdd: false, highlightLast: true),
      ],
    ),
  );

  Widget _ionRow(
    String label,
    String atom,
    String ion, {
    bool isOdd = false,
    bool highlightLast = false,
  }) => Container(
    color: isOdd ? C.surface.withOpacity(0.5) : C.card,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: C.textMain,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            atom,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: highlightLast ? C.violet : C.textMuted,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: highlightLast
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
                : EdgeInsets.zero,
            decoration: highlightLast
                ? BoxDecoration(
                    color: C.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Text(
              ion,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: highlightLast ? C.primary : C.textMuted,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// ISOTOPE CARD
// ─────────────────────────────────────────
class _IsotopeUseCard extends StatelessWidget {
  final String field;
  final String isotope;
  final String use;
  final Color accent;

  const _IsotopeUseCard({
    required this.field,
    required this.isotope,
    required this.use,
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
              padding: const EdgeInsets.all(14),
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
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          isotope,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: C.border),
                        ),
                        child: Text(
                          field,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: C.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    use,
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
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────
// PANEL 1 — States of Matter (2.1)
// ─────────────────────────────────────────
class _Panel1 extends StatelessWidget {
  const _Panel1();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('States of Matter', Icons.blur_on_rounded),

    const _ContentCard(
      title: 'What is Matter?',
      icon: Icons.info_outline_rounded,
      body:
          'Matter is anything that has mass and occupies space. '
          'It consists of tiny, discrete particles and can exist as '
          'elements (made of atoms or molecules) or compounds '
          '(made of molecules or ions).',
    ),
    const SizedBox(height: 20),

    // Three state cards
    const _StateCard(
      state: 'Solid',
      emoji: '🧊',
      arrangement: 'Closely packed in an orderly manner',
      kineticEnergy: 'Low',
      attraction: 'Strong',
      accent: C.primary,
    ),
    const SizedBox(height: 12),
    const _StateCard(
      state: 'Liquid',
      emoji: '💧',
      arrangement: 'Closely packed but not in an orderly manner',
      kineticEnergy: 'Higher than solid state',
      attraction: 'Strong, but less than solid state',
      accent: C.violet,
    ),
    const SizedBox(height: 12),
    const _StateCard(
      state: 'Gas',
      emoji: '💨',
      arrangement: 'Far apart',
      kineticEnergy: 'Very high',
      attraction: 'Weak',
      accent: C.amber,
    ),
    const SizedBox(height: 20),

    // State changes
    const Text(
      'Changes in State of Matter',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 8),
    const _InfoCard(
      icon: Icons.whatshot_rounded,
      text:
          'Heat absorbed → particles gain kinetic energy, move further apart.',
      color: C.red,
    ),
    const SizedBox(height: 12),

    const _StateChangeBadge(
      from: 'Solid',
      to: 'Liquid',
      process: 'Melting',
      absorbed: true,
    ),
    const SizedBox(height: 8),
    const _StateChangeBadge(
      from: 'Liquid',
      to: 'Gas',
      process: 'Boiling / Evaporation',
      absorbed: true,
    ),
    const SizedBox(height: 8),
    const _StateChangeBadge(
      from: 'Solid',
      to: 'Gas',
      process: 'Sublimation',
      absorbed: true,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.ac_unit_rounded,
      text:
          'Heat released → particles lose kinetic energy, move closer together.',
      color: C.primary,
    ),
    const SizedBox(height: 12),

    const _StateChangeBadge(
      from: 'Liquid',
      to: 'Solid',
      process: 'Freezing',
      absorbed: false,
    ),
    const SizedBox(height: 8),
    const _StateChangeBadge(
      from: 'Gas',
      to: 'Liquid',
      process: 'Condensation',
      absorbed: false,
    ),
    const SizedBox(height: 8),
    const _StateChangeBadge(
      from: 'Gas',
      to: 'Solid',
      process: 'Deposition',
      absorbed: false,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 2 — Development of Atomic Model (2.2)
// ─────────────────────────────────────────
class _Panel2 extends StatelessWidget {
  const _Panel2();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Atomic Models', Icons.history_edu_rounded),

    const _ContentCard(
      title: 'The Atom',
      icon: Icons.adjust_rounded,
      body:
          'An atom is the basic building block of matter. '
          'It is composed of three subatomic particles: protons, neutrons, and electrons. '
          'Scientists developed the atomic model over time through experiments and discoveries.',
    ),
    const SizedBox(height: 16),

    // Subatomic particles table
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: C.amber.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.grain_rounded, color: C.amber, size: 18),
                SizedBox(width: 10),
                Text(
                  'Subatomic Particles',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: C.amber,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: const [
                _ParticleRow(
                  particle: 'Electron',
                  symbol: 'e',
                  charge: '–1',
                  mass: '1/1840',
                  accent: C.primary,
                ),
                _ParticleRow(
                  particle: 'Proton',
                  symbol: 'p',
                  charge: '+1',
                  mass: '1',
                  accent: C.red,
                ),
                _ParticleRow(
                  particle: 'Neutron',
                  symbol: 'n',
                  charge: '0 (Neutral)',
                  mass: '1',
                  accent: C.textMuted,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 24),

    const Text(
      'Historical Development',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 16),

    const _ScientistCard(
      name: 'John Dalton',
      years: '1766 – 1844',
      discovery: '⚪  Solid sphere model',
      modelDesc:
          'Proposed matter is made of indestructible, indivisible spherical atoms. Elements of the same type have the same atoms.',
      accent: C.textMuted,
    ),
    const _ScientistCard(
      name: 'J.J. Thomson',
      years: '1856 – 1940',
      discovery: '🍬  Plum pudding model',
      modelDesc:
          'Discovered electrons. Proposed a positively-charged sphere with negatively-charged electrons embedded in it.',
      accent: C.primary,
    ),
    const _ScientistCard(
      name: 'Ernest Rutherford',
      years: '1871 – 1937',
      discovery: '☢️  Nuclear model',
      modelDesc:
          'Discovered the nucleus containing positively-charged protons, where almost all atomic mass is concentrated, with electrons moving outside it.',
      accent: C.red,
    ),
    const _ScientistCard(
      name: 'Niels Bohr',
      years: '1885 – 1962',
      discovery: '🪐  Shell / Bohr model',
      modelDesc:
          'Proposed that electrons move in fixed shells (energy levels) around the nucleus.',
      accent: C.violet,
    ),
    const _ScientistCard(
      name: 'James Chadwick',
      years: '1891 – 1974',
      discovery: '⚫  Neutron discovery',
      modelDesc:
          'Discovered neutral particles called neutrons in the nucleus, which contribute to almost half of the atom\'s mass.',
      accent: C.amber,
      isLast: true,
    ),

    const SizedBox(height: 16),
    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Each scientist\'s model built on the previous one. Today\'s modern model is based on quantum mechanics — electrons exist in probability clouds, not fixed paths.',
      color: C.amber,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 3 — Atomic Structure (2.3)
// ─────────────────────────────────────────
class _Panel3 extends StatelessWidget {
  const _Panel3();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Atomic Structure', Icons.adjust_rounded),

    const _ContentCard(
      title: 'Inside the Atom',
      icon: Icons.grain_rounded,
      body:
          'The atomic structure describes the specific number of protons and neutrons '
          'in the nucleus, and the arrangement of electrons in shells orbiting the nucleus.\n\n'
          'The chemical properties of an element depend on the number of valence electrons '
          '(electrons in the outermost shell).',
    ),
    const SizedBox(height: 16),

    // Formula box
    const _EqBox(
      label: 'KEY FORMULA',
      equation: 'Nucleon number = Protons + Neutrons',
      subLabel: 'ATOMS ARE NEUTRAL WHEN',
      subEq: 'Number of Protons = Number of Electrons',
    ),
    const SizedBox(height: 20),

    // Standard notation widget
    const _AtomNotation(),
    const SizedBox(height: 20),

    const _ContentCard(
      title: 'Atoms vs. Ions',
      icon: Icons.swap_horiz_rounded,
      body:
          'Atoms are electrically neutral — equal numbers of protons and electrons.\n\n'
          '• Cation (+): atom loses electrons → fewer electrons than protons\n'
          '• Anion (–): atom gains electrons → more electrons than protons\n\n'
          'The number of protons and neutrons never changes when forming an ion.',
    ),
    const SizedBox(height: 16),

    // Cl vs Cl⁻ comparison
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.violet.withOpacity(0.2)),
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
          const Text(
            'Chlorine Atom vs. Chloride Ion',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: C.textMain,
            ),
          ),
          const SizedBox(height: 14),
          const _IonTable(),
          const SizedBox(height: 12),
          const _InfoCard(
            icon: Icons.info_outline_rounded,
            text:
                'Cl⁻ gains 1 electron → 18 electrons total. Protons and neutrons stay the same.',
            color: C.violet,
          ),
        ],
      ),
    ),

    const SizedBox(height: 16),
    // Electron shells note
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Electron Shell Capacity',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: C.textMain,
            ),
          ),
          SizedBox(height: 10),
          _ShellRow(shell: '1st Shell', max: '2 electrons', accent: C.primary),
          SizedBox(height: 6),
          _ShellRow(shell: '2nd Shell', max: '8 electrons', accent: C.violet),
          SizedBox(height: 6),
          _ShellRow(shell: '3rd Shell', max: '8 electrons', accent: C.amber),
        ],
      ),
    ),
  ]);
}

class _ShellRow extends StatelessWidget {
  final String shell;
  final String max;
  final Color accent;
  const _ShellRow({
    required this.shell,
    required this.max,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
      ),
      const SizedBox(width: 10),
      Text(
        shell,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
      const Spacer(),
      Text(
        max,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: C.textMuted,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────
// PANEL 4 — Isotopes & Uses (2.4)
// ─────────────────────────────────────────
class _Panel4 extends StatelessWidget {
  final VoidCallback onGoToQuiz;
  const _Panel4({required this.onGoToQuiz});

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Isotopes & Uses', Icons.science_rounded),

    const _ContentCard(
      title: 'What are Isotopes?',
      icon: Icons.compare_arrows_rounded,
      body:
          'Isotopes are atoms of the same element that have the same number '
          'of protons but a different number of neutrons — hence different nucleon numbers.\n\n'
          'Most elements naturally exist as a mixture of isotopes. '
          'Their relative atomic mass is calculated as an average based on '
          'the natural abundance (percentage) of each isotope.',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'RELATIVE ATOMIC MASS FORMULA',
      equation: 'Ar = Σ(% isotope × mass of isotope) ÷ 100',
      subLabel: 'EXAMPLE — CHLORINE (Cl)',
      subEq: 'Ar = (75 × 35 + 25 × 37) ÷ 100 = 35.5',
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Isotopes have the same chemical properties (same protons = same electron arrangement) '
          'but different physical properties (different neutrons = different mass).',
      color: C.success,
    ),
    const SizedBox(height: 20),

    const Text(
      'Uses of Isotopes',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _IsotopeUseCard(
      field: 'Medicine',
      isotope: 'Cobalt-60',
      use:
          'Radiotherapy to kill cancer cells without surgery; sterilising surgical tools.',
      accent: C.red,
    ),
    const SizedBox(height: 8),
    const _IsotopeUseCard(
      field: 'Medicine',
      isotope: 'Iodine-131',
      use:
          'Treatment of thyroid disorders such as hyperthyroidism and thyroid cancer.',
      accent: C.red,
    ),
    const SizedBox(height: 8),
    const _IsotopeUseCard(
      field: 'Agriculture',
      isotope: 'Phosphorus-32',
      use: 'Study of plant metabolism and nutrient absorption.',
      accent: C.success,
    ),
    const SizedBox(height: 8),
    const _IsotopeUseCard(
      field: 'Nuclear',
      isotope: 'Uranium-235',
      use: 'Generating electricity through nuclear power generators.',
      accent: C.amber,
    ),
    const SizedBox(height: 8),
    const _IsotopeUseCard(
      field: 'Archaeology',
      isotope: 'Carbon-14',
      use:
          'Estimation of the age of artifacts or fossils (radiocarbon dating).',
      accent: C.violet,
    ),
    const SizedBox(height: 8),
    const _IsotopeUseCard(
      field: 'Archaeology',
      isotope: 'Lead-210',
      use: 'Determining the age of sand and earth layers up to 80 years.',
      accent: C.violet,
    ),
    const SizedBox(height: 8),
    const _IsotopeUseCard(
      field: 'Industry',
      isotope: 'Hydrogen-3',
      use: 'Used as a detector to study sewage and liquid wastes.',
      accent: C.primary,
    ),
    const SizedBox(height: 8),
    const _IsotopeUseCard(
      field: 'Engineering',
      isotope: 'Sodium-24',
      use: 'Detecting leakage in underground pipes.',
      accent: C.primary,
    ),
    const SizedBox(height: 24),

    // Chapter complete card
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
                'Chapter 2 complete!',
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
            'You have covered states of matter, the development of atomic models, '
            'atomic structure and notation, and the uses of isotopes. '
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
          'Go to Quiz — Chapter 2',
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
