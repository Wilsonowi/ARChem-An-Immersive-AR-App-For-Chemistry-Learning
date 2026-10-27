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
  static const green = Color(0xFF10B981);
  static const greenDim = Color(0xFFECFDF5);
}

// ─────────────────────────────────────────
// ENTRY POINT (for standalone preview)
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
    home: const LectureChapter1Screen(),
  );
}

// ─────────────────────────────────────────
// MAIN LECTURE SCREEN — Chapter 1
// ─────────────────────────────────────────
class LectureChapter1Screen extends StatefulWidget {
  const LectureChapter1Screen({super.key});
  @override
  State<LectureChapter1Screen> createState() => _LectureChapter1ScreenState();
}

class _LectureChapter1ScreenState extends State<LectureChapter1Screen>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int _current = 0;

  static const int _total = 3;

  final List<_PanelMeta> _panels = const [
    _PanelMeta('Chemistry & Daily Life', Icons.science_rounded, C.primary),
    _PanelMeta('Scientific Investigation', Icons.search_rounded, C.violet),
    _PanelMeta(
      'Lab Safety & Apparatus',
      Icons.health_and_safety_rounded,
      C.success,
    ),
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
                tag: 'Chapter 1 · Introduction to Chemistry',
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
                        _Panel1(),
                        _Panel2(),
                        _Panel3(
                          onGoToQuiz: () {
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (_) => const ActiveQuizScreen(topic: 'Introduction to Chemistry'),
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
                              chapterNumber: 1,
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

// ─────────────────────────────────────────
// TABLE WIDGET
// ─────────────────────────────────────────
class _TableCard extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;
  final Color accent;

  const _TableCard({
    required this.title,
    required this.headers,
    required this.rows,
    this.accent = C.primary,
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
        // Title row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: accent.withOpacity(0.08),
          child: Row(
            children: [
              Icon(Icons.table_chart_rounded, color: accent, size: 18),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
        // Header row
        Container(
          color: C.surface,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: headers.map((h) {
              final isFirst = headers.indexOf(h) == 0;
              return Expanded(
                flex: isFirst ? 1 : 2,
                child: Text(
                  h,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: C.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(color: C.border, height: 1),
        // Data rows
        ...rows.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          return Column(
            children: [
              Container(
                color: i.isOdd ? C.surface.withOpacity(0.5) : C.card,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: row.asMap().entries.map((e) {
                    final isFirst = e.key == 0;
                    return Expanded(
                      flex: isFirst ? 1 : 2,
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isFirst
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isFirst ? C.textMain : C.textMuted,
                          height: 1.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (i < rows.length - 1)
                const Divider(color: C.border, height: 1),
            ],
          );
        }),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// NUMBERED STEP WIDGET
// ─────────────────────────────────────────
class _NumberedStep extends StatelessWidget {
  final String number;
  final String text;
  final bool isLast;
  final Color accent;

  const _NumberedStep({
    required this.number,
    required this.text,
    this.isLast = false,
    this.accent = C.primary,
  });

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 13,
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
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 24),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
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
// CAREER CHIP WIDGET
// ─────────────────────────────────────────
class _CareerSection extends StatelessWidget {
  final String field;
  final List<String> careers;
  final Color accent;

  const _CareerSection({
    required this.field,
    required this.careers,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: C.border),
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
              field,
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
          children: careers
              .map(
                (c) => Container(
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
                    c,
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
// PPE ROW WIDGET
// ─────────────────────────────────────────
class _PpeRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final String function;
  final bool isLast;

  const _PpeRow({
    required this.icon,
    required this.name,
    required this.function,
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: C.primaryDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: C.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: C.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    function,
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
          ],
        ),
      ),
      if (!isLast) const Divider(color: C.border, height: 1),
    ],
  );
}

// ─────────────────────────────────────────
// STORAGE RULE CHIP
// ─────────────────────────────────────────
class _StorageRule extends StatelessWidget {
  final String substance;
  final String rule;
  final Color accent;

  const _StorageRule({
    required this.substance,
    required this.rule,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: C.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                substance,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: accent,
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
      ],
    ),
  );
}

// ─────────────────────────────────────────
// PANEL 1 — Chemistry & Daily Life (1.1)
// ─────────────────────────────────────────
class _Panel1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Chemistry & Daily Life', Icons.science_rounded),

    const _ContentCard(
      title: 'What is Chemistry?',
      icon: Icons.menu_book_rounded,
      body:
          'Chemistry is a field of science originating from the Arabic word '
          '"al-kimiya". It studies the structures, properties, compositions, '
          'and interactions between matter.\n\n'
          'All substances around us are made up of chemicals. Mastering '
          'chemistry allows humans to understand matter, explain daily '
          'chemical reactions, and develop advanced technologies such as '
          'nanochemistry — the study of particles as tiny as 10⁻⁹ m.',
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Nanochemistry studies particles at a scale of 10⁻⁹ metres — '
          'that\'s one billionth of a metre, smaller than a human hair by 80,000×.',
    ),
    const SizedBox(height: 20),

    // Chemicals in Daily Life table
    const _TableCard(
      title: 'Commonly Used Chemicals in Daily Life',
      headers: ['Field', 'Examples of Chemicals'],
      rows: [
        [
          'Food',
          'Preservative, Colouring, Flavouring, Antioxidant, Stabiliser',
        ],
        ['Agriculture', 'Herbicide, Pesticide, Fungicide, Fertiliser, Hormone'],
        ['Industry', 'Paint, Polymer, Glass, Ceramic, Detergent, Alloy'],
        [
          'Medicine',
          'Antibiotic, Antiseptic, Vitamin, Chemotherapy, Analgesic',
        ],
      ],
    ),
    const SizedBox(height: 20),

    // Careers section
    const Text(
      'Chemistry Careers',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _CareerSection(
      field: 'Pharmaceutical & Medicine',
      careers: ['Doctor', 'Pharmacist'],
      accent: C.primary,
    ),
    const SizedBox(height: 10),
    const _CareerSection(
      field: 'Cosmetics',
      careers: ['Cosmetic Chemist', 'Cosmetic Consultant'],
      accent: Color(0xFFEC4899),
    ),
    const SizedBox(height: 10),
    const _CareerSection(
      field: 'Green Technology',
      careers: ['Green Technology Chemist', 'Engineer'],
      accent: C.success,
    ),
    const SizedBox(height: 10),
    const _CareerSection(
      field: 'Nanotechnology & Food Technology',
      careers: ['Nanotechnology Engineer', 'Food Scientist'],
      accent: C.amber,
    ),
    const SizedBox(height: 10),
    const _CareerSection(
      field: 'Biotechnology',
      careers: ['Biotechnology Researcher', 'Biomedical Engineer'],
      accent: C.violet,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 2 — Scientific Investigation (1.2)
// ─────────────────────────────────────────
class _Panel2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Scientific Investigation', Icons.search_rounded),

    const _ContentCard(
      title: 'What is a Scientific Investigation?',
      icon: Icons.biotech_rounded,
      body:
          'A scientific investigation is a systematic method used by scientists '
          'to solve problems related to science.\n\n'
          'It follows a specific sequence of steps — from observing a phenomenon '
          'to conducting a controlled experiment — allowing researchers to make '
          'data-driven conclusions about a hypothesis.',
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.info_outline_rounded,
      text:
          'A hypothesis is a general, testable statement about the relationship '
          'between a manipulated variable and a responding variable.',
      color: C.violet,
    ),
    const SizedBox(height: 20),

    // Steps container
    Container(
      padding: const EdgeInsets.all(20),
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
            'Steps in a Scientific Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: C.textMain,
            ),
          ),
          SizedBox(height: 20),
          _NumberedStep(
            number: '1',
            text:
                'Making observations — using senses to gather information about an object or phenomenon.',
            accent: C.violet,
          ),
          _NumberedStep(
            number: '2',
            text:
                'Making an inference — using data and past experience to explain observations.',
            accent: C.violet,
          ),
          _NumberedStep(
            number: '3',
            text:
                'Identifying the problem — asking questions based on the inference.',
            accent: C.violet,
          ),
          _NumberedStep(
            number: '4',
            text:
                'Making a hypothesis — stating a testable relationship between variables.',
            accent: C.violet,
          ),
          _NumberedStep(
            number: '5',
            text:
                'Identifying the variables — manipulated, responding, and fixed variables.',
            accent: C.violet,
          ),
          _NumberedStep(
            number: '6',
            text:
                'Controlling the variables — change one variable, keep all others fixed.',
            accent: C.violet,
          ),
          _NumberedStep(
            number: '7',
            text:
                'Planning an experiment — determining materials, apparatus, procedure, and analysis.',
            accent: C.violet,
          ),
          _NumberedStep(
            number: '8',
            text:
                'Collecting data — recording observations or measurements systematically.',
            accent: C.violet,
          ),
          _NumberedStep(
            number: '9',
            text:
                'Interpreting data — organising and analysing data through graphs or calculations.',
            accent: C.violet,
          ),
          _NumberedStep(
            number: '10',
            text:
                'Making a conclusion — state whether the hypothesis is accepted or rejected.',
            accent: C.violet,
          ),
          _NumberedStep(
            number: '11',
            text:
                'Preparing a report — communicating findings and experiment details.',
            isLast: true,
            accent: C.violet,
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),

    // Variables explanation
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.violet.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.violet.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _variableRow(
            '🔧',
            'Manipulated variable',
            'The variable you deliberately change.',
            C.violet,
          ),
          const SizedBox(height: 12),
          _variableRow(
            '📊',
            'Responding variable',
            'The variable you observe or measure as a result.',
            C.primary,
          ),
          const SizedBox(height: 12),
          _variableRow(
            '📌',
            'Fixed variable',
            'Variables kept constant throughout the experiment.',
            C.success,
          ),
        ],
      ),
    ),
  ]);

  Widget _variableRow(String emoji, String name, String desc, Color accent) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: C.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────
// PANEL 3 — Lab Safety & Apparatus (1.3)
// ─────────────────────────────────────────
class _Panel3 extends StatelessWidget {
  final VoidCallback onGoToQuiz;
  const _Panel3({required this.onGoToQuiz});

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Lab Safety & Apparatus', Icons.health_and_safety_rounded),

    const _ContentCard(
      title: 'Why Lab Safety Matters',
      icon: Icons.warning_amber_rounded,
      body:
          'Chemicals pose different risks — toxicity, flammability, corrosiveness. '
          'Every chemical must be handled using proper protective equipment, '
          'stored correctly, and disposed of according to standard environmental '
          'procedures to prevent accidents and pollution.',
    ),
    const SizedBox(height: 20),

    // PPE Table
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
            decoration: const BoxDecoration(
              color: C.successDim,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: C.success, size: 18),
                SizedBox(width: 10),
                Text(
                  'Personal Protective Equipment (PPE)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: C.successText,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: const [
                _PpeRow(
                  icon: Icons.remove_red_eye_outlined,
                  name: 'Safety Goggles',
                  function:
                      'Prevents dust or splashes of chemicals from getting into the eyes.',
                ),
                _PpeRow(
                  icon: Icons.dry_cleaning_outlined,
                  name: 'Laboratory Coat',
                  function:
                      'Protects body and clothing against chemical spills — acids, alkalis, and organic solvents.',
                ),
                _PpeRow(
                  icon: Icons.back_hand_outlined,
                  name: 'Gloves',
                  function:
                      'Protects hands from injuries, chemicals, or infections when handling substances.',
                ),
                _PpeRow(
                  icon: Icons.masks_outlined,
                  name: 'Face Mask',
                  function:
                      'Protects respiratory organs from chemicals in powder or fume form.',
                ),
                _PpeRow(
                  icon: Icons.do_not_step_outlined,
                  name: 'Laboratory Shoes',
                  function:
                      'Protects feet from injuries caused by chemical spills or sharp objects.',
                ),
                _PpeRow(
                  icon: Icons.air_outlined,
                  name: 'Fume Chamber',
                  function:
                      'Used for experiments releasing toxic vapours, causing combustions, or producing pungent smells.',
                ),
                _PpeRow(
                  icon: Icons.shower_outlined,
                  name: 'Safety Shower',
                  function:
                      'Washes the body in a chemical accident; also extinguishes fire on clothing.',
                ),
                _PpeRow(
                  icon: Icons.water_drop_outlined,
                  name: 'Eyewash',
                  function: 'Washes and cleans the eye when accidents occur.',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 20),

    // Storage
    const Text(
      'Storage of Chemicals',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _StorageRule(
      substance: 'Reactive substances (Li, Na, K)',
      rule: 'Stored in paraffin oil to prevent reaction with moisture in air.',
      accent: C.primary,
    ),
    const SizedBox(height: 8),
    const _StorageRule(
      substance: 'Hydrocarbons & organic solvents',
      rule:
          'Stored in shady areas far from sunlight and heat due to flammability.',
      accent: C.amber,
    ),
    const SizedBox(height: 8),
    const _StorageRule(
      substance: 'Light-sensitive substances (HNO₃, H₂O₂, liquid Br₂)',
      rule: 'Stored in dark bottles to prevent decomposition by light.',
      accent: C.violet,
    ),
    const SizedBox(height: 8),
    const _StorageRule(
      substance: 'Corrosive substances (pH < 5 and pH > 9)',
      rule: 'Stored in special, locked storage cabinets.',
      accent: Color(0xFFEF4444),
    ),
    const SizedBox(height: 8),
    const _StorageRule(
      substance: 'Heavy metals & toxic substances',
      rule: 'Kept in special labelled containers in a locked, heat-free room.',
      accent: C.textMuted,
    ),
    const SizedBox(height: 20),

    // Emergency spill procedure
    Container(
      padding: const EdgeInsets.all(20),
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
            '🚨  Emergency Spill Procedure',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: C.textMain,
            ),
          ),
          SizedBox(height: 20),
          _NumberedStep(
            number: '1',
            text: 'Inform your teacher or laboratory assistant immediately.',
            accent: Color(0xFFEF4444),
          ),
          _NumberedStep(
            number: '2',
            text: 'Prohibit other students from entering the accident site.',
            accent: Color(0xFFEF4444),
          ),
          _NumberedStep(
            number: '3',
            text: 'Stop the spill from spreading by using sand to border it.',
            accent: Color(0xFFEF4444),
          ),
          _NumberedStep(
            number: '4',
            text: 'Clean the chemical spill carefully.',
            accent: Color(0xFFEF4444),
          ),
          _NumberedStep(
            number: '5',
            text: 'Dispose of the chemical following the correct procedures.',
            isLast: true,
            accent: Color(0xFFEF4444),
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
                'Chapter 1 complete!',
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
            'You have covered the fundamentals of chemistry, '
            'the scientific method, and laboratory safety. '
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

    // Go to Quiz button
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
          'Go to Quiz — Chapter 1',
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
