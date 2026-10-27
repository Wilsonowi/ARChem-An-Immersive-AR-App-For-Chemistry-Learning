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
    home: const LectureChapter8Screen(),
  );
}

// ─────────────────────────────────────────
// MAIN LECTURE SCREEN — Chapter 8
// ─────────────────────────────────────────
class LectureChapter8Screen extends StatefulWidget {
  const LectureChapter8Screen({super.key});
  @override
  State<LectureChapter8Screen> createState() => _LectureChapter8ScreenState();
}

class _LectureChapter8ScreenState extends State<LectureChapter8Screen>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int _current = 0;

  static const int _total = 6;

  final List<_PanelMeta> _panels = const [
    _PanelMeta('Alloys', Icons.hardware_rounded, C.primary),
    _PanelMeta('Glass', Icons.water_drop_outlined, C.teal),
    _PanelMeta('Ceramic Properties', Icons.fireplace_rounded, C.amber),
    _PanelMeta('Ceramic Uses', Icons.medical_services_outlined, C.red),
    _PanelMeta('Composites I', Icons.layers_rounded, C.violet),
    _PanelMeta('Composites II', Icons.layers_outlined, C.indigo),
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
                tag: 'Chapter 8 · Manufactured Substances',
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
                            //   builder: (_) => const ActiveQuizScreen(topic: 'Manufactured Substances in Industry'),
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
                              chapterNumber: 8,
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

// ─────────────────────────────────────────
// ATOM ARRANGEMENT VISUAL (pure metal vs alloy)
// ─────────────────────────────────────────
class _AtomArrangementVisual extends StatelessWidget {
  final bool isAlloy;
  const _AtomArrangementVisual({required this.isAlloy});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: (isAlloy ? C.amber : C.primary).withOpacity(0.06),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: (isAlloy ? C.amber : C.primary).withOpacity(0.25),
      ),
    ),
    child: Column(
      children: [
        _EqLabel(
          isAlloy
              ? 'ALLOY — IRREGULAR ATOM SIZES'
              : 'PURE METAL — UNIFORM ATOM SIZES',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(20, (i) {
            final isForeign = isAlloy && (i == 5 || i == 11 || i == 16);
            return Container(
              width: isForeign ? 26 : 20,
              height: isForeign ? 26 : 20,
              decoration: BoxDecoration(
                color: isForeign
                    ? C.red.withOpacity(0.5)
                    : (isAlloy ? C.amber : C.primary).withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isForeign ? C.red : (isAlloy ? C.amber : C.primary),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        Text(
          isAlloy
              ? 'Foreign atoms of different sizes disrupt the orderly arrangement — layers can\'t slide. Result: harder, stronger.'
              : 'Same-size atoms stack in orderly layers — layers slide easily over each other. Result: ductile, malleable, but soft.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isAlloy ? C.amber : C.primary,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// ALLOY USE CARD
// ─────────────────────────────────────────
class _AlloyUseCard extends StatelessWidget {
  final String name;
  final String use;
  final Color accent;

  const _AlloyUseCard({
    required this.name,
    required this.use,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(14),
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
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.hardware_rounded, color: accent, size: 18),
        ),
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
              const SizedBox(height: 3),
              Text(
                use,
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
      ],
    ),
  );
}

// ─────────────────────────────────────────
// PROPERTY CHIP GROUP
// ─────────────────────────────────────────
class _PropertyChips extends StatelessWidget {
  final List<String> properties;
  final Color accent;
  const _PropertyChips({required this.properties, required this.accent});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: properties
        .map(
          (p) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Text(
              p,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
        )
        .toList(),
  );
}

// ─────────────────────────────────────────
// GLASS TYPE CARD
// ─────────────────────────────────────────
class _GlassTypeCard extends StatelessWidget {
  final String name;
  final String composition;
  final Color accent;

  const _GlassTypeCard({
    required this.name,
    required this.composition,
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
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    composition,
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
// BOND/RIGIDITY VISUAL (for ceramics)
// ─────────────────────────────────────────
class _RigidLatticeVisual extends StatelessWidget {
  const _RigidLatticeVisual();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: C.amber.withOpacity(0.06),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: C.amber.withOpacity(0.25)),
    ),
    child: Column(
      children: [
        const _EqLabel('RIGID IONIC/COVALENT LATTICE'),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(15, (i) {
            return Container(
              decoration: BoxDecoration(
                color: C.amber.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(color: C.amber),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        const Text(
          'Atoms are locked in a rigid lattice by strong covalent and ionic bonds. '
          'Force breaks bonds instead of sliding atoms — making ceramics brittle, '
          'but very resistant to compression.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: C.amber,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────
// CERAMIC USE CARD
// ─────────────────────────────────────────
class _CeramicUseCard extends StatelessWidget {
  final String field;
  final IconData icon;
  final String uses;
  final Color accent;

  const _CeramicUseCard({
    required this.field,
    required this.icon,
    required this.uses,
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
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: accent, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                uses,
                style: const TextStyle(
                  fontSize: 13,
                  color: C.textMuted,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
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
// COMPOSITE CARD (matrix + strengthening → result)
// ─────────────────────────────────────────
class _CompositeCard extends StatelessWidget {
  final String name;
  final String matrix;
  final String strengthening;
  final String result;
  final Color accent;

  const _CompositeCard({
    required this.name,
    required this.matrix,
    required this.strengthening,
    required this.result,
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
            name,
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MATRIX',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accent,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            matrix,
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
                  Icon(Icons.add_rounded, color: accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STRENGTHENING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accent,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            strengthening,
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
              const SizedBox(height: 10),
              Center(
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: accent,
                  size: 18,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: C.successDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: C.success.withOpacity(0.25)),
                ),
                child: Text(
                  result,
                  style: const TextStyle(
                    fontSize: 12,
                    color: C.successText,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
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
// PANEL 1 — Alloys (8.1)
// ─────────────────────────────────────────
class _Panel1 extends StatelessWidget {
  const _Panel1();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Alloys', Icons.hardware_rounded),

    const _ContentCard(
      title: 'What is an Alloy?',
      icon: Icons.info_outline_rounded,
      body:
          'An alloy is a mixture of two or more elements where the main '
          'element is a metal. Alloying prevents corrosion and alters a '
          'pure metal\'s properties — making it harder and stronger.',
    ),
    const SizedBox(height: 20),

    const _AtomArrangementVisual(isAlloy: false),
    const SizedBox(height: 14),
    const _AtomArrangementVisual(isAlloy: true),
    const SizedBox(height: 20),

    const Text(
      'Common Alloys & Their Uses',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _AlloyUseCard(
      name: 'Pewter',
      use: 'Used to make souvenirs.',
      accent: C.primary,
    ),
    const SizedBox(height: 8),
    const _AlloyUseCard(
      name: 'Duralumin',
      use: 'Used to make the body of an aeroplane.',
      accent: C.primary,
    ),
    const SizedBox(height: 8),
    const _AlloyUseCard(
      name: 'Bronze',
      use: 'Used to make medals and monuments.',
      accent: C.amber,
    ),
    const SizedBox(height: 8),
    const _AlloyUseCard(
      name: 'Brass',
      use: 'Used to make keys.',
      accent: C.amber,
    ),
    const SizedBox(height: 8),
    const _AlloyUseCard(
      name: 'Steel',
      use: 'Used to make the body of a car.',
      accent: C.textMuted,
    ),
    const SizedBox(height: 8),
    const _AlloyUseCard(
      name: 'Stainless steel',
      use: 'Used to make cutlery — resists corrosion.',
      accent: C.textMuted,
    ),
    const SizedBox(height: 8),
    const _AlloyUseCard(
      name: 'Superconductor',
      use:
          'Used in magnets for Maglev trains — zero electrical resistance at very low temperatures.',
      accent: C.violet,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 2 — Glass (8.2)
// ─────────────────────────────────────────
class _Panel2 extends StatelessWidget {
  const _Panel2();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Composition of Glass', Icons.water_drop_outlined),

    const _ContentCard(
      title: 'What is Glass?',
      icon: Icons.science_rounded,
      body:
          'Glass is a non-metallic material made when silica (silicon '
          'dioxide, SiO₂) is heated with other chemicals. Changing those '
          'added chemicals creates different types of glass — but all '
          'share the same basic physical properties.',
    ),
    const SizedBox(height: 20),

    const Text(
      'Basic Properties of Glass',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 10),
    const _PropertyChips(
      properties: [
        'Hard but brittle',
        'Electrical insulator',
        'Heat insulator',
        'Waterproof',
        'Chemically inert',
        'Transparent',
      ],
      accent: C.teal,
    ),
    const SizedBox(height: 20),

    const Text(
      'Types of Glass',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 12),

    const _GlassTypeCard(
      name: 'Fused Silica Glass',
      composition: 'Made purely from silica (SiO₂).',
      accent: C.primary,
    ),
    const SizedBox(height: 10),
    const _GlassTypeCard(
      name: 'Soda-Lime Glass',
      composition:
          'Silica (SiO₂) + soda (Na₂CO₃) + limestone (CaCO₃). The most common everyday glass.',
      accent: C.teal,
    ),
    const SizedBox(height: 10),
    const _GlassTypeCard(
      name: 'Borosilicate Glass',
      composition:
          'Silica + boron oxide (B₂O₃) + alumina (Al₂O₃). Used for heat-resistant labware.',
      accent: C.amber,
    ),
    const SizedBox(height: 10),
    const _GlassTypeCard(
      name: 'Lead Crystal Glass',
      composition:
          'Contains lead components — known for its brilliance and weight.',
      accent: C.violet,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'The base ingredient is ALWAYS silica — the "recipe" of additional chemicals is what changes the glass type.',
      color: C.teal,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 3 — Ceramic Properties (8.3a)
// ─────────────────────────────────────────
class _Panel3 extends StatelessWidget {
  const _Panel3();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Ceramic Properties', Icons.fireplace_rounded),

    const _ContentCard(
      title: 'What is a Ceramic?',
      icon: Icons.info_outline_rounded,
      body:
          'A ceramic is a solid made of inorganic, non-metallic substances '
          '(metal, non-metal, or metalloid compounds), shaped and hardened '
          'using very high heat.\n\n'
          'Strong covalent and ionic bonds hold the atoms in a rigid '
          'lattice — they melt only at very high temperatures.',
    ),
    const SizedBox(height: 20),

    const _RigidLatticeVisual(),
    const SizedBox(height: 20),

    const Text(
      'Basic Properties of Ceramics',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: C.textMain,
      ),
    ),
    const SizedBox(height: 10),
    const _PropertyChips(
      properties: [
        'High thermal resistance',
        'Hard & strong (compression)',
        'Brittle',
        'Chemically inert',
        'Heat & electrical insulator',
      ],
      accent: C.amber,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Ceramics resist COMPRESSION well (hard to crush) but are weak '
          'towards STRETCHING — the rigid bonds simply snap rather than flex.',
      color: C.amber,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 4 — Ceramic Uses (8.3b)
// ─────────────────────────────────────────
class _Panel4 extends StatelessWidget {
  const _Panel4();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Ceramic Uses', Icons.medical_services_outlined),

    const _ContentCard(
      title: 'Ceramics in the Real World',
      icon: Icons.public_rounded,
      body:
          'Because ceramics resist heat, compression, and chemical attack, they show up across medicine, transportation, and energy production.',
    ),
    const SizedBox(height: 20),

    const _CeramicUseCard(
      field: 'Medicine',
      icon: Icons.medical_services_rounded,
      uses:
          'Zirconia ceramic in dental implants. Alumina ceramic for knee bones. Superconducting ceramics in MRI machines.',
      accent: C.red,
    ),
    const SizedBox(height: 12),
    const _CeramicUseCard(
      field: 'Transportation',
      icon: Icons.flight_rounded,
      uses:
          'Engine components in jet planes — withstand extreme heat at high temperatures.',
      accent: C.primary,
    ),
    const SizedBox(height: 12),
    const _CeramicUseCard(
      field: 'Energy Production',
      icon: Icons.bolt_rounded,
      uses:
          'Electrical insulators in high-voltage areas such as power stations.',
      accent: C.amber,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Notice the pattern — every use leans on heat resistance, compression strength, or electrical insulation.',
      color: C.red,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 5 — Composites I (8.4a)
// ─────────────────────────────────────────
class _Panel5 extends StatelessWidget {
  const _Panel5();

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Composite Materials I', Icons.layers_rounded),

    const _ContentCard(
      title: 'Combining Two Substances',
      icon: Icons.merge_rounded,
      body:
          'A composite material combines two or more non-homogeneous '
          'substances: a MATRIX (which surrounds and binds) and a '
          'STRENGTHENING substance.\n\n'
          'The result usually has properties superior to — or completely '
          'different from — either original component alone.',
    ),
    const SizedBox(height: 20),

    const _CompositeCard(
      name: 'Reinforced Concrete',
      matrix: 'Concrete',
      strengthening: 'Steel bars / wire mesh',
      result:
          'Concrete alone withstands compression but breaks under stretching. Steel adds stretch-resistance. Used in bridges and dams.',
      accent: C.violet,
    ),
    const SizedBox(height: 16),

    const _CompositeCard(
      name: 'Fibreglass',
      matrix: 'Plastic',
      strengthening: 'Glass fibres',
      result:
          'Weak, soft, flammable plastic becomes strong, while keeping low heat and electrical conductivity.',
      accent: C.teal,
    ),
    const SizedBox(height: 16),

    const _InfoCard(
      icon: Icons.lightbulb_outline_rounded,
      text:
          'Always ask: what does the matrix do, what does the strengthening material add, and what NEW property emerges?',
      color: C.violet,
    ),
  ]);
}

// ─────────────────────────────────────────
// PANEL 6 — Composites II (8.4b)
// ─────────────────────────────────────────
class _Panel6 extends StatelessWidget {
  final VoidCallback onGoToQuiz;
  const _Panel6({required this.onGoToQuiz});

  @override
  Widget build(BuildContext context) => _panelScroll([
    _heading('Composite Materials II', Icons.layers_outlined),

    const _ContentCard(
      title: 'More Engineered Composites',
      icon: Icons.science_rounded,
      body:
          'Composites can also achieve highly specialised effects — from data transmission to UV protection to zero electrical resistance.',
    ),
    const SizedBox(height: 20),

    const _CompositeCard(
      name: 'Optical Fibre',
      matrix: 'Glass',
      strengthening: 'Glass / plastic coating',
      result:
          'Achieves high compression strength despite the original glass being brittle. Used to transmit data and information.',
      accent: C.indigo,
    ),
    const SizedBox(height: 16),

    const _CompositeCard(
      name: 'Photochromic Glass',
      matrix: 'Glass',
      strengthening: 'Silver chloride / silver halide',
      result:
          'Normal glass is transparent but doesn\'t absorb UV. This composite stays transparent to visible light but darkens to absorb UV rays.',
      accent: C.amber,
    ),
    const SizedBox(height: 16),

    const _CompositeCard(
      name: 'Superconductor (YBCO)',
      matrix: 'Yttrium, Barium, Copper, Oxygen',
      strengthening: '— (a unique combined compound)',
      result:
          'Conducts electrical current with ZERO resistance at very low temperatures — unlike any individual component.',
      accent: C.success,
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
                'Chapter 8 complete!',
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
            'You\'ve covered alloys, glass, ceramics, and composite materials — '
            'the engineered substances behind everyday manufacturing. '
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
          'Go to Quiz — Chapter 8',
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
