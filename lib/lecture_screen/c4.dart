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
    home: const LectureChapter4Screen(),
  );
}

// ─────────────────────────────────────────
// MAIN LECTURE SCREEN — Chapter 4
// ─────────────────────────────────────────
class LectureChapter4Screen extends StatefulWidget {
  const LectureChapter4Screen({super.key});
  @override
  State<LectureChapter4Screen> createState() => _LectureChapter4ScreenState();
}

class _LectureChapter4ScreenState extends State<LectureChapter4Screen>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int _current = 0;

  static const int _total = 8;

  final List<_PanelMeta> _panels = const [
    _PanelMeta('History', Icons.history_edu_rounded, C.primary),
    _PanelMeta('Arrangement', Icons.grid_view_rounded, C.violet),
    _PanelMeta('Group 18', Icons.air_rounded, C.indigo),
    _PanelMeta('Group 1', Icons.flash_on_rounded, C.amber),
    _PanelMeta('Group 17', Icons.science_rounded, C.red),
    _PanelMeta('Period 3', Icons.linear_scale_rounded, C.teal),
    _PanelMeta('Transition Metals', Icons.hexagon_rounded, C.pink),
    _PanelMeta('Catalysts & Industry', Icons.factory_rounded, C.success),
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
                tag: 'Chapter 4 · Periodic Table',
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
                        _Panel8(
                          onGoToQuiz: () {
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (_) => const ActiveQuizScreen(topic: 'The Periodic Table of Elements'),
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
                              chapterNumber: 4,
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
// SCIENTIST TIMELINE CARD (reused pattern from Ch2)
// ─────────────────────────────────────────
class _ScientistCard extends StatelessWidget {
  final String name;
  final String years;
  final String contribution;
  final String desc;
  final Color accent;
  final bool isLast;

  const _ScientistCard({
    required this.name,
    required this.years,
    required this.contribution,
    required this.desc,
    required this.accent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                    contribution,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
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
// DATA TABLE (generic, used in 4.2, 4.3, 4.4, 4.5)
// ─────────────────────────────────────────
class _DataTable extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;
  final Color accent;
  final IconData icon;

  const _DataTable({
    required this.title,
    required this.headers,
    required this.rows,
    required this.accent,
    this.icon = Icons.table_chart_rounded,
  });

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          color: accent.withOpacity(0.08),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: 10),
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
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 48 - 32,
            ),
            child: Column(
              children: [
                Container(
                  color: C.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Row(
                    children: headers
                        .map(
                          (h) => SizedBox(
                            width: 110,
                            child: Text(
                              h,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: C.textMuted,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Divider(color: C.border, height: 1),
                ...rows.asMap().entries.map((entry) {
                  final i = entry.key;
                  final row = entry.value;
                  return Column(
                    children: [
                      Container(
                        color: i.isOdd ? C.surface.withOpacity(0.5) : C.card,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Row(
                          children: row
                              .asMap()
                              .entries
                              .map(
                                (e) => SizedBox(
                                  width: 110,
                                  child: Text(
                                    e.value,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: e.key == 0
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: e.key == 0 ? accent : C.textMain,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      if (i < rows.length - 1)
                        const Divider(color: C.border, height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// ELEMENT BADGE ROW (proton#, arrangement, group, period)
// ─────────────────────────────────────────
class _ElementPositionRow extends StatelessWidget {
  final String symbol;
  final String name;
  final String arrangement;
  final String group;
  final String period;
  final Color accent;
  final bool isLast;

  const _ElementPositionRow({
    required this.symbol,
    required this.name,
    required this.arrangement,
    required this.group,
    required this.period,
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
                  fontSize: 16,
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
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: C.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    arrangement,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: C.primaryDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'G$group',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: C.primary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: C.violetDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'P$period',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: C.violet,
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
// ELEMENT USE CARD
// ─────────────────────────────────────────
class _ElementUseCard extends StatelessWidget {
  final String element;
  final String use;
  final Color accent;

  const _ElementUseCard({
    required this.element,
    required this.use,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: C.border),
    ),
    padding: const EdgeInsets.all(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            element,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            use,
            style: const TextStyle(
              fontSize: 13,
              color: C.textMuted,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// GRADIENT TREND BAR (for "increases down group" visuals)
// ─────────────────────────────────────────
class _TrendBar extends StatelessWidget {
  final String label;
  final String direction; // e.g. "Increases ↓" or "Decreases →"
  final Color accent;

  const _TrendBar({
    required this.label,
    required this.direction,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [accent.withOpacity(0.04), accent.withOpacity(0.16)],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: accent.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: C.textMain,
            ),
          ),
        ),
        Text(
          direction,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// REACTION CARD (equation + description)
// ─────────────────────────────────────────
class _ReactionCard extends StatelessWidget {
  final String equation;
  final String description;
  final Color accent;

  const _ReactionCard({
    required this.equation,
    required this.description,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: accent.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          equation,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: accent,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
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
// OXIDE NATURE CHIP ROW (for Period 3)
// ─────────────────────────────────────────
class _OxideGroup extends StatelessWidget {
  final String nature;
  final List<String> oxides;
  final Color accent;

  const _OxideGroup({
    required this.nature,
    required this.oxides,
    required this.accent,
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
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Text(
              nature,
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
          children: oxides
              .map(
                (o) => Container(
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
                    o,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
// TRANSITION METAL CARD
// ─────────────────────────────────────────
class _TransitionMetalCard extends StatelessWidget {
  final String name;
  final String symbol;
  final String oxidationNumbers;
  final String complexIon;
  final String colourInfo;
  final Color accent;

  const _TransitionMetalCard({
    required this.name,
    required this.symbol,
    required this.oxidationNumbers,
    required this.complexIon,
    required this.colourInfo,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: accent.withOpacity(0.25)),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: C.textMain,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _metalDetailRow('Oxidation numbers', oxidationNumbers, accent),
        const SizedBox(height: 8),
        _metalDetailRow('Complex ion', complexIon, accent),
        const SizedBox(height: 8),
        _metalDetailRow('Colour', colourInfo, accent),
      ],
    ),
  );

  Widget _metalDetailRow(String label, String value, Color accent) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 110,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: C.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: accent,
            height: 1.4,
          ),
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────
// CATALYST PROCESS CARD
// ─────────────────────────────────────────
class _CatalystCard extends StatelessWidget {
  final String catalyst;
  final String process;
  final String product;
  final Color accent;

  const _CatalystCard({
    required this.catalyst,
    required this.process,
    required this.product,
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
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.science_rounded, color: accent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          catalyst,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Catalyst in: $process',
                          style: const TextStyle(
                            fontSize: 13,
                            color: C.textMain,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Produces: $product',
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
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────
// PANEL 1 — History (4.1)
// ─────────────────────────────────────────
class _Panel1 extends StatelessWidget {
  const _Panel1();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('History of the Periodic Table', Icons.history_edu_rounded),

    const _ContentCard(
      title: 'A System Built Over Time',
      icon: Icons.timeline_rounded,
      body:
          'The Periodic Table classifies known chemical elements according '
          'to certain characteristics. It was developed gradually through '
          'the contributions of many scientists.\n\n'
          'The modern Periodic Table arranges elements in ascending order '
          'of proton number (1 to 118), with similar elements placed in '
          'the same vertical column.',
    ),
    const SizedBox(height: 20),

    const _ScientistCard(
      name: 'Antoine Lavoisier',
      years: '1743 – 1794',
      contribution: '4 categories',
      desc:
          'Classified elements into gases, non-metals, metals, and metal oxides — though inaccurate as he included light and heat as "elements".',
      accent: C.textMuted,
    ),
    const _ScientistCard(
      name: 'Johann W. Döbereiner',
      years: '1780 – 1849',
      contribution: 'Triads',
      desc:
          'Grouped elements with similar properties into sets of three, noting the relationship between atomic mass and properties.',
      accent: C.primary,
    ),
    const _ScientistCard(
      name: 'John Newlands',
      years: '1837 – 1898',
      contribution: 'Law of Octaves',
      desc:
          'Arranged elements by increasing atomic mass — found properties recurred every eighth element.',
      accent: C.amber,
    ),
    const _ScientistCard(
      name: 'Lothar Meyer',
      years: '1830 – 1895',
      contribution: 'Atomic volume curve',
      desc:
          'Plotted atomic volume against atomic mass; elements at equivalent curve positions shared similar properties.',
      accent: C.violet,
    ),
    const _ScientistCard(
      name: 'Dmitri Mendeleev',
      years: '1834 – 1907',
      contribution: 'Predictive table',
      desc:
          'Arranged elements by atomic mass into columns of similar properties, leaving gaps that successfully predicted undiscovered elements.',
      accent: C.red,
    ),
    const _ScientistCard(
      name: 'Henry Moseley',
      years: '1887 – 1915',
      contribution: 'Proton number order',
      desc:
          'Linked X-ray spectrums to proton numbers — leading to the modern arrangement by increasing proton number.',
      accent: C.success,
      isLast: true,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 2 — Arrangement (4.2)
// ─────────────────────────────────────────
class _Panel2 extends StatelessWidget {
  const _Panel2();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('The Arrangement', Icons.grid_view_rounded),

    const _ContentCard(
      title: 'Groups & Periods',
      icon: Icons.apps_rounded,
      body:
          'The modern Periodic Table organises elements into vertical '
          'Groups (1–18) and horizontal Periods (1–7).\n\n'
          'An element\'s Group is set by its number of valence electrons. '
          'Its Period is set by the number of shells filled with electrons.',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'FINDING THE GROUP',
      equation: 'Group = Valence electrons   (if 1 or 2)',
      subLabel: 'IF VALENCE ELECTRONS = 3 TO 8',
      subEq: 'Group = Valence electrons + 10',
      accent: C.violet,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: C.violet.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: const Text(
              'Proton Number → Position',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: C.violet,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: const [
                _ElementPositionRow(
                  symbol: 'Li',
                  name: 'Lithium (Z=3)',
                  arrangement: '2.1',
                  group: '1',
                  period: '2',
                  accent: C.primary,
                ),
                _ElementPositionRow(
                  symbol: 'Ca',
                  name: 'Calcium (Z=20)',
                  arrangement: '2.8.8.2',
                  group: '2',
                  period: '4',
                  accent: C.primary,
                ),
                _ElementPositionRow(
                  symbol: 'Al',
                  name: 'Aluminium (Z=13)',
                  arrangement: '2.8.3',
                  group: '13',
                  period: '3',
                  accent: C.amber,
                ),
                _ElementPositionRow(
                  symbol: 'Si',
                  name: 'Silicon (Z=14)',
                  arrangement: '2.8.4',
                  group: '14',
                  period: '3',
                  accent: C.amber,
                ),
                _ElementPositionRow(
                  symbol: 'N',
                  name: 'Nitrogen (Z=7)',
                  arrangement: '2.5',
                  group: '15',
                  period: '2',
                  accent: C.red,
                ),
                _ElementPositionRow(
                  symbol: 'O',
                  name: 'Oxygen (Z=8)',
                  arrangement: '2.6',
                  group: '16',
                  period: '2',
                  accent: C.red,
                ),
                _ElementPositionRow(
                  symbol: 'Br',
                  name: 'Bromine (Z=35)',
                  arrangement: '2.8.18.7',
                  group: '17',
                  period: '4',
                  accent: C.violet,
                ),
                _ElementPositionRow(
                  symbol: 'Kr',
                  name: 'Krypton (Z=36)',
                  arrangement: '2.8.18.8',
                  group: '18',
                  period: '4',
                  accent: C.violet,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Count the dots in the electron arrangement (e.g. 2.8.3) — the LAST '
          'number is the valence electron count, and the count of numbers is the period.',
      color: C.violet,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 3 — Group 18 (4.3)
// ─────────────────────────────────────────
class _Panel3 extends StatelessWidget {
  const _Panel3();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Group 18 — Noble Gases', Icons.air_rounded),

    const _ContentCard(
      title: 'Why So Unreactive?',
      icon: Icons.shield_outlined,
      body:
          'Group 18 elements — Helium, Neon, Argon, Krypton, Xenon — are '
          'known as noble (inert) gases. They are chemically unreactive '
          'because they already have a stable electron arrangement: '
          'duplet for Helium, octet for the rest.\n\n'
          'They do not donate, accept, or share electrons.',
    ),
    const SizedBox(height: 16),

    const _TrendBar(
      label: 'Going down the group',
      direction: 'Atomic radius ↑',
      accent: C.indigo,
    ),
    const SizedBox(height: 8),
    const _TrendBar(
      label: 'Going down the group',
      direction: 'Melting / Boiling point ↑',
      accent: C.indigo,
    ),
    const SizedBox(height: 8),
    const _TrendBar(
      label: 'Going down the group',
      direction: 'Density ↑',
      accent: C.indigo,
    ),
    const SizedBox(height: 20),

    _DataTable(
      title: 'Physical Properties — Group 18',
      headers: const [
        'Element',
        'Radius (nm)',
        'M.P. (°C)',
        'B.P. (°C)',
        'Density',
      ],
      rows: const [
        ['Helium', '0.050', '–270', '–269', '0.00017'],
        ['Neon', '0.070', '–248', '–246', '0.00080'],
        ['Argon', '0.094', '–189', '–186', '0.00170'],
        ['Krypton', '0.109', '–156', '–152', '0.00350'],
        ['Xenon', '0.130', '–122', '–108', '0.00550'],
      ],
      accent: C.indigo,
      icon: Icons.air_rounded,
    ),
    const SizedBox(height: 20),

    const Text(
      'Uses in Daily Life',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 10),
    const _ElementUseCard(
      element: 'Helium',
      use: 'Filling weather balloons and oxygen tanks for divers.',
      accent: C.indigo,
    ),
    const SizedBox(height: 8),
    const _ElementUseCard(
      element: 'Neon',
      use: 'Advertising board lights (glowing signs).',
      accent: C.indigo,
    ),
    const SizedBox(height: 8),
    const _ElementUseCard(
      element: 'Argon',
      use:
          'Filling electric bulbs and providing an inert atmosphere for welding.',
      accent: C.indigo,
    ),
    const SizedBox(height: 8),
    const _ElementUseCard(
      element: 'Krypton',
      use: 'Camera flashes and lasers for retina treatment.',
      accent: C.indigo,
    ),
    const SizedBox(height: 8),
    const _ElementUseCard(
      element: 'Xenon',
      use: 'Lighthouse lamps and anaesthesia.',
      accent: C.indigo,
    ),
    const SizedBox(height: 8),
    const _ElementUseCard(
      element: 'Radon',
      use: 'Used to treat cancer.',
      accent: C.indigo,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 4 — Group 1 (4.4)
// ─────────────────────────────────────────
class _Panel4 extends StatelessWidget {
  const _Panel4();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Group 1 — Alkali Metals', Icons.flash_on_rounded),

    const _ContentCard(
      title: 'Soft, Shiny & Reactive',
      icon: Icons.bolt_rounded,
      body:
          'Group 1 elements — Lithium, Sodium, Potassium — are soft metals '
          'with shiny surfaces, low densities, and low melting/boiling points.\n\n'
          'They are highly reactive because they readily donate their single '
          'valence electron to achieve a stable electron arrangement.',
    ),
    const SizedBox(height: 16),

    const _TrendBar(
      label: 'Going down the group',
      direction: 'Atomic size ↑',
      accent: C.amber,
    ),
    const SizedBox(height: 8),
    const _TrendBar(
      label: 'Going down the group',
      direction: 'Reactivity ↑',
      accent: C.amber,
    ),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: C.amberDim,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Why? A bigger atom means the valence electron sits further from the nucleus — '
        'weaker attraction makes it easier to donate.',
        style: TextStyle(
          fontSize: 12,
          color: C.successText,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    ),
    const SizedBox(height: 20),

    _DataTable(
      title: 'Physical Properties — Group 1',
      headers: const ['Element', 'Radius (nm)', 'M.P. (°C)', 'B.P. (°C)'],
      rows: const [
        ['Lithium', '0.133', '186', '1342'],
        ['Sodium', '0.186', '98', '880'],
        ['Potassium', '0.203', '64', '760'],
      ],
      accent: C.amber,
      icon: Icons.flash_on_rounded,
    ),
    const SizedBox(height: 20),

    const Text(
      'Chemical Reactions',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _ReactionCard(
      equation: '2Na(s) + Cl₂(g)  →  2NaCl(s)',
      description:
          'With Chlorine — burns to form a white solid metal chloride.',
      accent: C.amber,
    ),
    const SizedBox(height: 10),
    const _ReactionCard(
      equation: '4Li(s) + O₂(g)  →  2Li₂O(s)',
      description: 'With Oxygen — burns to form a solid metal oxide.',
      accent: C.amber,
    ),
    const SizedBox(height: 10),
    const _ReactionCard(
      equation: 'Li₂O(s) + H₂O(l)  →  2LiOH(aq)',
      description:
          'Metal oxide + Water — dissolves to form an alkaline solution.',
      accent: C.amber,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.water_drop_outlined,
      text:
          'With water, alkali metals react vigorously to produce an alkaline '
          'metal hydroxide solution PLUS hydrogen gas.',
      color: C.amber,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 5 — Group 17 (4.5)
// ─────────────────────────────────────────
class _Panel5 extends StatelessWidget {
  const _Panel5();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Group 17 — Halogens', Icons.science_rounded),

    const _ContentCard(
      title: 'Reactive Non-Metals',
      icon: Icons.bubble_chart_rounded,
      body:
          'Group 17 elements — Fluorine, Chlorine, Bromine, Iodine — are '
          'known as halogens. They exist as diatomic molecules (e.g. Cl₂) '
          'and are reactive non-metals.\n\n'
          'With 7 valence electrons, halogens react by accepting ONE '
          'electron to form a –1 ion.',
    ),
    const SizedBox(height: 16),

    const _EqBox(
      label: 'GENERAL ION-FORMING REACTION',
      equation: 'X + e⁻  →  X⁻',
      subLabel: 'EXAMPLE — IODINE WITH ALKALI',
      subEq: 'I₂(s) + 2NaOH(aq) → NaI(aq) + NaOI(aq) + H₂O(l)',
      accent: C.red,
    ),
    const SizedBox(height: 16),

    const _TrendBar(
      label: 'Going down the group',
      direction: 'Atomic size ↑',
      accent: C.red,
    ),
    const SizedBox(height: 8),
    const _TrendBar(
      label: 'Going down the group',
      direction: 'Reactivity ↓',
      accent: C.red,
    ),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: C.redDim,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Why? A bigger atom means weaker nuclear attraction on the valence '
        'shell — harder to attract an extra electron.',
        style: TextStyle(
          fontSize: 12,
          color: C.red,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    ),
    const SizedBox(height: 20),

    _DataTable(
      title: 'Physical Properties — Group 17',
      headers: const ['Element', 'State', 'M.P. (°C)', 'B.P. (°C)', 'Density'],
      rows: const [
        ['Chlorine', 'Gas (greenish-yellow)', '–101', '–34', '0.00300'],
        ['Bromine', 'Liquid (reddish-brown)', '–7', '59', '3.11900'],
        ['Iodine', 'Solid (purplish-black)', '114', '184', '4.95000'],
      ],
      accent: C.red,
      icon: Icons.science_rounded,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Notice the physical state trend: Cl is a gas, Br is a liquid, I is a '
          'solid — boiling and melting points increase down the group.',
      color: C.red,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 6 — Period 3 (4.6)
// ─────────────────────────────────────────
class _Panel6 extends StatelessWidget {
  const _Panel6();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Period 3 Elements', Icons.linear_scale_rounded),

    const _ContentCard(
      title: 'Sodium to Argon',
      icon: Icons.straighten_rounded,
      body:
          'Period 3 runs from Sodium (Na) to Argon (Ar) — all these elements '
          'have exactly three electron-filled shells.\n\n'
          'Moving left to right across the period: atomic radius decreases, '
          'electronegativity increases, and the physical state shifts from '
          'solid to gas.',
    ),
    const SizedBox(height: 16),

    const _TrendBar(
      label: 'Across Period 3 (left → right)',
      direction: 'Atomic radius ↓',
      accent: C.teal,
    ),
    const SizedBox(height: 8),
    const _TrendBar(
      label: 'Across Period 3 (left → right)',
      direction: 'Electronegativity ↑',
      accent: C.teal,
    ),
    const SizedBox(height: 20),

    const Text(
      'Oxide Character Trend',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 4),
    const Text(
      'Basic  →  Amphoteric  →  Acidic',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: C.teal,
      ),
    ),
    const SizedBox(height: 14),

    const _OxideGroup(
      nature: 'Basic Oxides',
      oxides: ['Na₂O', 'MgO'],
      accent: C.primary,
    ),
    const SizedBox(height: 10),
    const _OxideGroup(
      nature: 'Amphoteric Oxides',
      oxides: ['Al₂O₃'],
      accent: C.amber,
    ),
    const SizedBox(height: 10),
    const _OxideGroup(
      nature: 'Acidic Oxides',
      oxides: ['SiO₂', 'P₄O₁₀', 'SO₂', 'Cl₂O₇'],
      accent: C.red,
    ),
    const SizedBox(height: 20),

    const _ContentCard(
      title: 'Silicon — A Semi-Metal',
      icon: Icons.memory_rounded,
      body:
          'Silicon acts as a semiconductor — a weak electrical conductor at '
          'room temperature, but a good conductor at high temperatures.\n\n'
          'This property makes it essential for manufacturing electronic '
          'microchips used in computers and mobile phones.',
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 7 — Transition Elements (4.7a)
// ─────────────────────────────────────────
class _Panel7 extends StatelessWidget {
  const _Panel7();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Transition Elements', Icons.hexagon_rounded),

    const _ContentCard(
      title: 'Metals With Special Powers',
      icon: Icons.auto_awesome_rounded,
      body:
          'Transition elements are metals found in Groups 3 to 12 '
          '(e.g. Chromium, Manganese, Iron, Copper).\n\n'
          'Besides typical metallic properties, they show 4 special '
          'characteristics:',
    ),
    const SizedBox(height: 12),

    Row(
      children: [
        Expanded(child: _featureChip('⚡', 'Act as catalysts', C.pink)),
        const SizedBox(width: 8),
        Expanded(child: _featureChip('🎨', 'Form coloured ions', C.pink)),
      ],
    ),
    const SizedBox(height: 8),
    Row(
      children: [
        Expanded(child: _featureChip('🔢', 'Multiple oxidation #s', C.pink)),
        const SizedBox(width: 8),
        Expanded(child: _featureChip('🔗', 'Form complex ions', C.pink)),
      ],
    ),
    const SizedBox(height: 20),

    const Text(
      'Special Characteristics by Element',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _TransitionMetalCard(
      name: 'Chromium',
      symbol: 'Cr',
      oxidationNumbers: '+3, +6',
      complexIon: '—',
      colourInfo: 'Green (Cr³⁺), Orange (Cr₂O₇²⁻)',
      accent: C.success,
    ),
    const SizedBox(height: 10),
    const _TransitionMetalCard(
      name: 'Manganese',
      symbol: 'Mn',
      oxidationNumbers: '+2, +4, +7',
      complexIon: '—',
      colourInfo: 'Pink (Mn²⁺), Purple (MnO₄⁻)',
      accent: C.pink,
    ),
    const SizedBox(height: 10),
    const _TransitionMetalCard(
      name: 'Iron',
      symbol: 'Fe',
      oxidationNumbers: '+2, +3',
      complexIon: '[Fe(CN)₆]³⁻, [Fe(CN)₆]⁴⁻, [Fe(H₂O)₆]²⁺',
      colourInfo: 'Green (Fe²⁺), Brown (Fe³⁺)',
      accent: C.red,
    ),
    const SizedBox(height: 10),
    const _TransitionMetalCard(
      name: 'Copper',
      symbol: 'Cu',
      oxidationNumbers: '+1, +2',
      complexIon: '[Cu(NH₃)₄]²⁺',
      colourInfo: 'Blue (Cu²⁺)',
      accent: C.primary,
    ),
  ]);

  Widget _featureChip(String emoji, String label, Color accent) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      color: accent.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: accent.withOpacity(0.2)),
    ),
    child: Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: accent,
            height: 1.3,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// PANEL 8 — Catalysts & Industry (4.7b)
// ─────────────────────────────────────────
class _Panel8 extends StatelessWidget {
  final VoidCallback onGoToQuiz;
  const _Panel8({required this.onGoToQuiz});

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Catalysts in Industry', Icons.factory_rounded),

    const _ContentCard(
      title: 'Speeding Up Industrial Reactions',
      icon: Icons.speed_rounded,
      body:
          'One of the most useful properties of transition metals is their '
          'ability to act as catalysts — speeding up industrial chemical '
          'reactions without being consumed.',
    ),
    const SizedBox(height: 16),

    const _CatalystCard(
      catalyst: 'Iron (Fe)',
      process: 'Haber Process',
      product: 'Ammonia (NH₃)',
      accent: C.success,
    ),
    const SizedBox(height: 10),
    const _CatalystCard(
      catalyst: 'Platinum (Pt)',
      process: 'Ostwald Process',
      product: 'Nitric acid (HNO₃)',
      accent: C.primary,
    ),
    const SizedBox(height: 10),
    const _CatalystCard(
      catalyst: 'Vanadium(V) oxide (V₂O₅)',
      process: 'Contact Process',
      product: 'Sulphuric acid (H₂SO₄)',
      accent: C.amber,
    ),
    const SizedBox(height: 10),
    const _CatalystCard(
      catalyst: 'Nickel (Ni) / Platinum (Pt)',
      process: 'Hydrogenation of vegetable oils',
      product: 'Margarine',
      accent: C.violet,
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
                'Chapter 4 complete!',
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
            'You\'ve covered the history of the Periodic Table, its arrangement, '
            'Groups 18/1/17, Period 3, and transition elements with their '
            'industrial catalytic roles. Test your understanding with the quiz below.',
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
          'Go to Quiz — Chapter 4',
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
