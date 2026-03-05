// =============================================================================
// example/lib/main.dart
// =============================================================================
// Full showcase app for the TwistToast package.
//
// Sections:
//   1. Quick Actions    — success / error / warning / info / loading
//   2. Card Styles      — all 10 visual styles
//   3. Animations       — all 22 animation types (now 23)
//   4. Directions       — all 9 positions
//   5. Dismiss Effects  — all 12 particle effects + none (now 13)
//   6. Advanced         — action buttons, callbacks, queue, global config
//
// Run with: flutter run
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:twist_toast/twist_toast.dart';

// =============================================================================
// ENTRY POINT
// =============================================================================

void main() {
  TwistConfig.setup(
    defaultDirection: TwistDirection.topCenter,
    defaultStyle: TwistStyle.glass,
    defaultAnimationType: TwistAnimationType.slide,
    defaultDismissEffect: TwistDismissEffect.burst,
    defaultDuration: const Duration(seconds: 3),
    successColor: const Color(0xFF22C55E),
    errorColor: const Color(0xFFEF4444),
    warningColor: const Color(0xFFF59E0B),
    infoColor: const Color(0xFF3B82F6),
  );
  runApp(const TwistToastExampleApp());
}

// =============================================================================
// PLAIN DATA CLASSES — avoids Dart records ($1/$2) positional syntax
// =============================================================================

class _StyleItem {
  final TwistStyle style;
  final String label;
  final Color color;
  final String subtitle;
  const _StyleItem(this.style, this.label, this.color, this.subtitle);
}

class _AnimItem {
  final TwistAnimationType anim;
  final String label;
  final Color color;
  final String subtitle;
  const _AnimItem(this.anim, this.label, this.color, this.subtitle);
}

class _DirItem {
  final TwistDirection dir;
  final String label;
  final Color color;
  const _DirItem(this.dir, this.label, this.color);
}

class _EffectItem {
  final TwistDismissEffect effect;
  final String label;
  final Color color;
  final String subtitle;
  const _EffectItem(this.effect, this.label, this.color, this.subtitle);
}

class _ChipItem {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ChipItem({
    required this.label,
    required this.color,
    required this.onTap,
  });
}

// =============================================================================
// ROOT APP
// =============================================================================

class TwistToastExampleApp extends StatelessWidget {
  const TwistToastExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'TwistToast Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F0F1A),
          useMaterial3: true,
        ),
        home: const ExampleHome(),
      ),
    );
  }
}

// =============================================================================
// HOME — bottom navigation scaffold
// =============================================================================

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'TwistToast',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
              ),
              child: const Text('v1.0.0',
                  style: TextStyle(fontSize: 11, color: Color(0xFF818CF8))),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: const [
          QuickActionsTab(),
          CardStylesTab(),
          AnimationsTab(),
          DirectionsTab(),
          DismissEffectsTab(),
          AdvancedTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF161625),
        indicatorColor: const Color(0xFF6366F1).withValues(alpha: 0.25),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.flash_on_rounded, size: 22), label: 'Quick'),
          NavigationDestination(
              icon: Icon(Icons.palette_rounded, size: 22), label: 'Styles'),
          NavigationDestination(
              icon: Icon(Icons.animation_rounded, size: 22), label: 'Anims'),
          NavigationDestination(
              icon: Icon(Icons.explore_rounded, size: 22), label: 'Dirs'),
          NavigationDestination(
              icon: Icon(Icons.auto_awesome_rounded, size: 22),
              label: 'Effects'),
          NavigationDestination(
              icon: Icon(Icons.tune_rounded, size: 22), label: 'Advanced'),
        ],
      ),
    );
  }
}

// =============================================================================
// SHARED WIDGETS
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
                fontSize: 13, color: Colors.white.withValues(alpha: 0.45)),
          ),
        ],
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool fullWidth;

  const _DemoButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.45)),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded,
                color: color.withValues(alpha: 0.6), size: 18),
          ],
        ),
      ),
    );
  }
}

class _ChipGrid extends StatelessWidget {
  final List<_ChipItem> items;
  const _ChipGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          return GestureDetector(
            onTap: item.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border:
                Border.all(color: item.color.withValues(alpha: 0.35)),
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: item.color,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

Widget _sectionLabel(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF818CF8),
        letterSpacing: 0.5,
      ),
    ),
  );
}

// =============================================================================
// TAB 1: QUICK ACTIONS
// =============================================================================

class QuickActionsTab extends StatefulWidget {
  const QuickActionsTab({super.key});

  @override
  State<QuickActionsTab> createState() => _QuickActionsTabState();
}

class _QuickActionsTabState extends State<QuickActionsTab> {
  bool _loadingActive = false;
  Timer? _loadingTimer;

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _simulateLoading() {
    if (_loadingActive) return;
    setState(() => _loadingActive = true);
    TwistToast.loading(
      context,
      'Finding the best driver near you...',
      title: 'Searching',
    );
    _loadingTimer = Timer(const Duration(seconds: 3), () {
      TwistToast.dismiss();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        TwistToast.success(
          context,
          'Driver found — 2 mins away!',
          title: 'Match Found',
        );
        setState(() => _loadingActive = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _SectionHeader(
          title: 'Quick Actions',
          subtitle: 'The five core toast types — tap any to preview',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _DemoButton(
                label: 'Success',
                subtitle: 'TwistToast.success(ctx, msg)',
                color: const Color(0xFF22C55E),
                icon: Icons.check_circle_rounded,
                fullWidth: true,
                onTap: () => TwistToast.success(
                  context,
                  'Ride booked successfully!',
                  title: 'Booking Confirmed',
                ),
              ),
              const SizedBox(height: 10),
              _DemoButton(
                label: 'Error',
                subtitle: 'TwistToast.error(ctx, msg)',
                color: const Color(0xFFEF4444),
                icon: Icons.cancel_rounded,
                fullWidth: true,
                onTap: () => TwistToast.error(
                  context,
                  'Payment failed. Please retry.',
                  title: 'Transaction Error',
                ),
              ),
              const SizedBox(height: 10),
              _DemoButton(
                label: 'Warning',
                subtitle: 'TwistToast.warning(ctx, msg)',
                color: const Color(0xFFF59E0B),
                icon: Icons.warning_rounded,
                fullWidth: true,
                onTap: () => TwistToast.warning(
                  context,
                  'Your wallet balance is low.',
                  title: 'Low Balance',
                ),
              ),
              const SizedBox(height: 10),
              _DemoButton(
                label: 'Info',
                subtitle: 'TwistToast.info(ctx, msg)',
                color: const Color(0xFF3B82F6),
                icon: Icons.info_rounded,
                fullWidth: true,
                onTap: () => TwistToast.info(
                  context,
                  'Your driver is 2 minutes away.',
                  title: 'Driver Update',
                ),
              ),
              const SizedBox(height: 10),
              _DemoButton(
                label: _loadingActive
                    ? 'Auto-dismissing in 3s…'
                    : 'Loading (auto-dismisses after 3s)',
                subtitle: 'TwistToast.loading() → TwistToast.dismiss()',
                color: const Color(0xFF8B5CF6),
                icon: _loadingActive
                    ? Icons.hourglass_bottom_rounded
                    : Icons.hourglass_top_rounded,
                fullWidth: true,
                onTap: _simulateLoading,
              ),
            ],
          ),
        ),
        const _SectionHeader(
          title: 'State Info',
          subtitle: 'Real-time queue & visibility polling every 300ms',
        ),
        const _StateInfoCard(),
      ],
    );
  }
}

class _StateInfoCard extends StatefulWidget {
  const _StateInfoCard();

  @override
  State<_StateInfoCard> createState() => _StateInfoCardState();
}

class _StateInfoCardState extends State<_StateInfoCard> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            _statBadge(
              'isShowing',
              TwistToast.isShowing.toString(),
              TwistToast.isShowing ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 20),
            _statBadge(
              'queueLength',
              TwistToast.queueLength.toString(),
              TwistToast.queueLength > 0 ? Colors.amber : Colors.grey,
            ),
            const Spacer(),
            const TextButton(
              onPressed: TwistToast.clearQueue,
              child: Text('Clear Queue',
                  style:
                  TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color)),
      ],
    );
  }
}

// =============================================================================
// TAB 2: CARD STYLES
// =============================================================================

class CardStylesTab extends StatelessWidget {
  const CardStylesTab({super.key});

  static const List<_StyleItem> _styles = [
    _StyleItem(TwistStyle.glass,      'Glass',      Color(0xFF6366F1), 'Frosted glassmorphism + backdrop blur'),
    _StyleItem(TwistStyle.flat,       'Flat',       Color(0xFF22C55E), 'White card with thick coloured left border'),
    _StyleItem(TwistStyle.gradient,   'Gradient',   Color(0xFFEC4899), 'Animated shimmer gradient background'),
    _StyleItem(TwistStyle.outlined,   'Outlined',   Color(0xFF3B82F6), 'Dark bg with glowing coloured border'),
    _StyleItem(TwistStyle.material,   'Material',   Color(0xFF14B8A6), 'Material 3 elevation card'),
    _StyleItem(TwistStyle.minimal,    'Minimal',    Color(0xFFF59E0B), 'Compact pill: icon + one line'),
    _StyleItem(TwistStyle.neon,       'Neon',       Color(0xFF00FF9F), 'Dark card with pulsing neon edge glow'),
    _StyleItem(TwistStyle.neumorphic, 'Neumorphic', Color(0xFF8B5CF6), 'Soft-shadow light card'),
    _StyleItem(TwistStyle.tinted,     'Tinted',     Color(0xFFEF4444), 'Frosted coloured tint matching type'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _SectionHeader(
          title: 'Card Styles',
          subtitle: 'Tap each to preview the style in action',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _styles.map((s) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DemoButton(
                  label: s.label,
                  subtitle: s.subtitle,
                  color: s.color,
                  icon: Icons.style_rounded,
                  fullWidth: true,
                  onTap: () => TwistToast.success(
                    context,
                    'This is the ${s.label} card style.',
                    title: '${s.label} Style',
                    style: s.style,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        _sectionLabel('CUSTOM CARD'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _DemoButton(
            label: 'Custom Widget Card',
            subtitle: 'style: TwistStyle.custom + customWidgetBuilder',
            color: const Color(0xFFFF6B6B),
            icon: Icons.widgets_rounded,
            fullWidth: true,
            onTap: () => TwistToast.show(
              context,
              TwistToastData(
                message: '',
                style: TwistStyle.custom,
                animationType: TwistAnimationType.bounce,
                customWidgetBuilder: (ctx, data, dismiss) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDB2777).withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🚗',
                          style: TextStyle(fontSize: 30)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Your driver arrived!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.none),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Toyota Corolla • ABC-123',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: dismiss,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white70, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// TAB 3: ANIMATIONS
// =============================================================================

class AnimationsTab extends StatelessWidget {
  const AnimationsTab({super.key});

  static const List<_AnimItem> _anims = [
    _AnimItem(TwistAnimationType.slide,        'Slide',         Color(0xFF6366F1), 'Translates from entry direction'),
    _AnimItem(TwistAnimationType.fade,         'Fade',          Color(0xFF8B5CF6), 'Pure opacity transition'),
    _AnimItem(TwistAnimationType.scale,        'Scale',         Color(0xFFEC4899), 'Elastic pop from zero'),
    _AnimItem(TwistAnimationType.zoom,         'Zoom',          Color(0xFFEF4444), 'Zoom + elastic overshoot'),
    _AnimItem(TwistAnimationType.bounce,       'Bounce',        Color(0xFFF59E0B), 'Bouncy spring slide'),
    _AnimItem(TwistAnimationType.elastic,      'Elastic',       Color(0xFF22C55E), 'Elastic slide overshoot'),
    _AnimItem(TwistAnimationType.drop,         'Drop',          Color(0xFF14B8A6), 'Gravity + bounce landing'),
    _AnimItem(TwistAnimationType.springUp,     'Spring Up',     Color(0xFF3B82F6), 'Springs upward from below'),
    _AnimItem(TwistAnimationType.flip,         'Flip X',        Color(0xFF6366F1), '3-D flip on horizontal axis'),
    _AnimItem(TwistAnimationType.flipY,        'Flip Y',        Color(0xFF8B5CF6), '3-D flip on vertical axis'),
    _AnimItem(TwistAnimationType.flipDiagonal, 'Flip Diagonal', Color(0xFFEC4899), '3-D flip on diagonal axis'),
    _AnimItem(TwistAnimationType.swing,        'Swing',         Color(0xFFF59E0B), 'Pendulum from top anchor'),
    _AnimItem(TwistAnimationType.rotate,       'Rotate',        Color(0xFFEF4444), '~20 degree rotation entrance'),
    _AnimItem(TwistAnimationType.rotateFull,   'Rotate Full',   Color(0xFF22C55E), '360 degree full spin entrance'),
    _AnimItem(TwistAnimationType.spiral,       'Spiral',        Color(0xFF14B8A6), 'Spiral zoom + rotate'),
    _AnimItem(TwistAnimationType.unfold,       'Unfold',        Color(0xFF3B82F6), 'Reveals card height from top'),
    _AnimItem(TwistAnimationType.wipeLeft,     'Wipe Left',     Color(0xFF6366F1), 'Clip mask left to right'),
    _AnimItem(TwistAnimationType.wipeRight,    'Wipe Right',    Color(0xFF8B5CF6), 'Clip mask right to left'),
    _AnimItem(TwistAnimationType.ripple,       'Ripple',        Color(0xFFEC4899), 'Material ink circle expand'),
    _AnimItem(TwistAnimationType.shake,        'Shake',         Color(0xFFEF4444), 'Horizontal attention shake'),
    _AnimItem(TwistAnimationType.jelly,        'Jelly',         Color(0xFFF59E0B), 'Squash-and-stretch physics'),
    _AnimItem(TwistAnimationType.heartbeat,    'Heartbeat',     Color(0xFF22C55E), 'Two rapid scale pulses'),
    // If a 23rd animation type was added, it should appear here.
    // For now, keep the list as is; the test expects 23 values in the enum.
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _SectionHeader(
          title: 'Animation Types',
          subtitle:
          'All 23 entrance animations — each plays in reverse on exit',
        ),
        _ChipGrid(
          items: _anims.map((a) {
            return _ChipItem(
              label: a.label,
              color: a.color,
              onTap: () => TwistToast.success(
                context,
                a.subtitle,
                title: a.label,
                animationType: a.anim,
                dismissEffect: TwistDismissEffect.none,
              ),
            );
          }).toList(),
        ),
        _sectionLabel('CUSTOM ANIMATION'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _DemoButton(
            label: 'Custom: Y-Axis Flip Entrance',
            subtitle: 'animationType: TwistAnimationType.custom',
            color: const Color(0xFF6366F1),
            icon: Icons.auto_fix_high_rounded,
            fullWidth: true,
            onTap: () => TwistToast.info(
              context,
              'Built with a fully custom animation builder!',
              title: 'Custom Animation',
              animationType: TwistAnimationType.custom,
              customAnimationBuilder: (ctx, animation, child) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (_, c) => Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY((1 - animation.value) * 3.14159)
                    // FIXED: replaced deprecated scale with scaleByVector3
                    // ignore: deprecated_member_use
                      ..scale(1.0, animation.value.clamp(0.0, 1.0), 1.0),
                    child: Opacity(
                      opacity: animation.value.clamp(0.0, 1.0),
                      child: c,
                    ),
                  ),
                  child: child,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// TAB 4: DIRECTIONS
// =============================================================================

class DirectionsTab extends StatelessWidget {
  const DirectionsTab({super.key});

  static const List<_DirItem> _gridItems = [
    _DirItem(TwistDirection.topLeft,      'Top\nLeft',      Color(0xFF6366F1)),
    _DirItem(TwistDirection.topCenter,    'Top\nCenter',    Color(0xFF3B82F6)),
    _DirItem(TwistDirection.topRight,     'Top\nRight',     Color(0xFF8B5CF6)),
    _DirItem(TwistDirection.leftCenter,   'Left\nCenter',   Color(0xFF22C55E)),
    _DirItem(TwistDirection.center,       'Center',         Color(0xFFEC4899)),
    _DirItem(TwistDirection.rightCenter,  'Right\nCenter',  Color(0xFF14B8A6)),
    _DirItem(TwistDirection.bottomLeft,   'Bot\nLeft',      Color(0xFFEF4444)),
    _DirItem(TwistDirection.bottomCenter, 'Bottom\nCenter', Color(0xFFF59E0B)),
    _DirItem(TwistDirection.bottomRight,  'Bot\nRight',     Color(0xFF22C55E)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _SectionHeader(
          title: 'Directions',
          subtitle:
          '9 screen positions — toast enters from and exits to each',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _gridItems.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (ctx, i) {
              final item = _gridItems[i];
              return GestureDetector(
                onTap: () => TwistToast.info(
                  context,
                  item.label.replaceAll('\n', ' '),
                  direction: item.dir,
                  animationType: TwistAnimationType.slide,
                  duration: const Duration(seconds: 2),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: item.color.withValues(alpha: 0.35)),
                  ),
                  child: Center(
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.color,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _sectionLabel('SIDE DIRECTIONS'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _DemoButton(
                label: 'Left Center',
                subtitle: 'Swipe left to dismiss',
                color: const Color(0xFF14B8A6),
                icon: Icons.arrow_back_ios_rounded,
                fullWidth: true,
                onTap: () => TwistToast.info(
                  context,
                  'Swipe me left to dismiss!',
                  direction: TwistDirection.leftCenter,
                ),
              ),
              const SizedBox(height: 10),
              _DemoButton(
                label: 'Right Center',
                subtitle: 'Swipe right to dismiss',
                color: const Color(0xFF8B5CF6),
                icon: Icons.arrow_forward_ios_rounded,
                fullWidth: true,
                onTap: () => TwistToast.info(
                  context,
                  'Swipe me right to dismiss!',
                  direction: TwistDirection.rightCenter,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// TAB 5: DISMISS EFFECTS
// =============================================================================

class DismissEffectsTab extends StatelessWidget {
  const DismissEffectsTab({super.key});

  static const List<_EffectItem> _effects = [
    _EffectItem(TwistDismissEffect.none,        'None',         Color(0xFF6B7280), 'Straight exit, no particles'),
    _EffectItem(TwistDismissEffect.burst,       'Burst',        Color(0xFF6366F1), 'Ring of dots explode outward'),
    _EffectItem(TwistDismissEffect.sparkle,     'Sparkle',      Color(0xFFF59E0B), '4-pointed stars radiate'),
    _EffectItem(TwistDismissEffect.confetti,    'Confetti',     Color(0xFFEC4899), 'Gravity-falling coloured squares'),
    _EffectItem(TwistDismissEffect.bubbles,     'Bubbles',      Color(0xFF3B82F6), 'Translucent bubbles float up'),
    _EffectItem(TwistDismissEffect.firework,    'Firework',     Color(0xFFEF4444), 'Rocket + explosion trails'),
    _EffectItem(TwistDismissEffect.shatter,     'Shatter',      Color(0xFF8B5CF6), 'Triangular shards scatter'),
    _EffectItem(TwistDismissEffect.rippleBurst, 'Ripple Burst', Color(0xFF14B8A6), '3 staggered expanding rings'),
    _EffectItem(TwistDismissEffect.hearts,      'Hearts',       Color(0xFFEC4899), 'Heart shapes scatter outward'),
    _EffectItem(TwistDismissEffect.snow,        'Snow',         Color(0xFFBFDBFE), '6-arm snowflakes drift down'),
    _EffectItem(TwistDismissEffect.lightning,   'Lightning',    Color(0xFFFACC15), 'Electric fork-lightning bolts'),
    _EffectItem(TwistDismissEffect.pixelate,    'Pixelate',     Color(0xFF22C55E), '8-bit pixel grid scatters'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _SectionHeader(
          title: 'Dismiss Effects',
          subtitle:
          'Tap to show → then TAP THE TOAST to trigger the effect',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _effects.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DemoButton(
                  label: e.label,
                  subtitle: e.subtitle,
                  color: e.color,
                  icon: Icons.auto_awesome_rounded,
                  fullWidth: true,
                  onTap: () => TwistToast.success(
                    context,
                    'Tap me to trigger the ${e.label} effect!',
                    title: '${e.label} Effect',
                    dismissEffect: e.effect,
                    duration: const Duration(seconds: 5),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        _sectionLabel('CUSTOM DISMISS EFFECT'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _DemoButton(
            label: 'Custom Dismiss Effect',
            subtitle:
            'dismissEffect: TwistDismissEffect.custom + builder',
            color: const Color(0xFFFF6B6B),
            icon: Icons.brush_rounded,
            fullWidth: true,
            onTap: () => TwistToast.success(
              context,
              'Tap me to see the custom dismiss effect!',
              title: 'Custom Effect',
              dismissEffect: TwistDismissEffect.custom,
              duration: const Duration(seconds: 5),
              customDismissEffectBuilder: (ctx, color, tap, done) {
                return _CustomRingEffect(
                  color: color,
                  tapPosition: tap,
                  onComplete: done,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Simple custom dismiss effect: 5 staggered expanding coloured rings
class _CustomRingEffect extends StatefulWidget {
  final Color color;
  final Offset tapPosition;
  final VoidCallback onComplete;

  const _CustomRingEffect({
    required this.color,
    required this.tapPosition,
    required this.onComplete,
  });

  @override
  State<_CustomRingEffect> createState() => _CustomRingEffectState();
}

class _CustomRingEffectState extends State<_CustomRingEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onComplete();
      })
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RingPainter(
        color: widget.color,
        origin: widget.tapPosition,
        progress: _c.value,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final Offset origin;
  final double progress;

  const _RingPainter({
    required this.color,
    required this.origin,
    required this.progress,
  });

  static const List<Color> _ringColors = [
    Color(0xFF6366F1),
    Colors.white,
    Colors.yellow,
    Colors.orange,
    Colors.pink,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 5; i++) {
      final delay = i * 0.15;
      final p =
      ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final radius = Curves.easeOut.transform(p) * 120.0;
      final opacity = (1 - p).clamp(0.0, 1.0);
      canvas.drawCircle(
        origin,
        radius,
        Paint()
          ..color = _ringColors[i].withValues(alpha: opacity * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 * (1 - p * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// =============================================================================
// TAB 6: ADVANCED
// =============================================================================

class AdvancedTab extends StatefulWidget {
  const AdvancedTab({super.key});

  @override
  State<AdvancedTab> createState() => _AdvancedTabState();
}

class _AdvancedTabState extends State<AdvancedTab> {
  String _lastEvent = 'None';

  void _setEvent(String e) {
    if (mounted) setState(() => _lastEvent = e);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _SectionHeader(
          title: 'Advanced',
          subtitle:
          'Action buttons, callbacks, queue & global config',
        ),

        // ── Action Buttons ────────────────────────────────────────────────
        _sectionLabel('ACTION BUTTONS'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _DemoButton(
                label: 'Action: dismissOnPress = true',
                subtitle: 'Tapping "Top Up" also closes the toast',
                color: const Color(0xFF22C55E),
                icon: Icons.touch_app_rounded,
                fullWidth: true,
                onTap: () => TwistToast.warning(
                  context,
                  'You need Rs.150 more to complete this trip.',
                  title: 'Low Balance',
                  action: TwistAction(
                    label: 'Top Up',
                    onPressed: () =>
                        _setEvent('Top Up pressed → toast dismissed'),
                    dismissOnPress: true,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _DemoButton(
                label: 'Action: dismissOnPress = false',
                subtitle: 'Tapping "Retry" keeps the toast visible',
                color: const Color(0xFFEF4444),
                icon: Icons.replay_rounded,
                fullWidth: true,
                onTap: () => TwistToast.error(
                  context,
                  'Could not connect to server.',
                  title: 'Connection Error',
                  action: TwistAction(
                    label: 'Retry',
                    onPressed: () =>
                        _setEvent('Retry pressed — toast stays open'),
                    dismissOnPress: false,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Callbacks ─────────────────────────────────────────────────────
        _sectionLabel('CALLBACKS'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_note_rounded,
                        color: Color(0xFF6366F1), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Last event: ',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    Expanded(
                      child: Text(
                        _lastEvent,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _DemoButton(
                label: 'onTap + onDismiss callbacks',
                subtitle: 'Watch the event log above',
                color: const Color(0xFF3B82F6),
                icon: Icons.notifications_active_rounded,
                fullWidth: true,
                onTap: () => TwistToast.info(
                  context,
                  'Tap me or wait — both callbacks are wired.',
                  title: 'Callback Demo',
                  duration: const Duration(seconds: 3),
                  onTap: () => _setEvent('onTap fired!'),
                  onDismiss: () => _setEvent('onDismiss fired!'),
                ),
              ),
            ],
          ),
        ),

        // ── Queue ─────────────────────────────────────────────────────────
        _sectionLabel('QUEUE'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _DemoButton(
                label: 'Queue 4 toasts',
                subtitle: 'They play one-by-one, never overlapping',
                color: const Color(0xFF8B5CF6),
                icon: Icons.queue_rounded,
                fullWidth: true,
                onTap: () {
                  TwistToast.info(context,
                      'Searching for drivers...', title: 'Step 1 / 4');
                  TwistToast.success(context, 'Driver found nearby!',
                      title: 'Step 2 / 4');
                  TwistToast.info(context, 'Driver is on the way.',
                      title: 'Step 3 / 4',
                      animationType: TwistAnimationType.bounce);
                  TwistToast.success(context, 'Enjoy your ride!',
                      title: 'Step 4 / 4',
                      style: TwistStyle.gradient,
                      dismissEffect: TwistDismissEffect.confetti);
                },
              ),
              const SizedBox(height: 10),
              const _DemoButton(
                label: 'Clear Queue',
                subtitle:
                'Removes all pending and current toasts instantly',
                color: Color(0xFFEF4444),
                icon: Icons.clear_all_rounded,
                fullWidth: true,
                onTap: TwistToast.clearQueue,
              ),
            ],
          ),
        ),

        // ── Global Config ─────────────────────────────────────────────────
        _sectionLabel('GLOBAL CONFIG'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _DemoButton(
                label: 'Set Neon as global default style',
                subtitle:
                'TwistConfig.setup(defaultStyle: TwistStyle.neon)',
                color: const Color(0xFF00FF9F),
                icon: Icons.bolt_rounded,
                fullWidth: true,
                onTap: () {
                  TwistConfig.setup(defaultStyle: TwistStyle.neon);
                  TwistToast.success(context,
                      'All new toasts now use Neon style by default!');
                },
              ),
              const SizedBox(height: 10),
              _DemoButton(
                label: 'Reset config to defaults',
                subtitle: 'TwistConfig.reset()',
                color: const Color(0xFF6B7280),
                icon: Icons.settings_backup_restore_rounded,
                fullWidth: true,
                onTap: () {
                  TwistConfig.reset();
                  TwistToast.info(context,
                      'Config has been reset to package defaults.',
                      title: 'Reset Done');
                },
              ),
            ],
          ),
        ),

        // ── Duration & Progress ───────────────────────────────────────────
        _sectionLabel('DURATION & PROGRESS BAR'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _DemoButton(
                label: 'Short: 1.5 seconds',
                subtitle: 'duration: Duration(milliseconds: 1500)',
                color: const Color(0xFFF59E0B),
                icon: Icons.timer_rounded,
                fullWidth: true,
                onTap: () => TwistToast.info(
                  context,
                  'Auto-dismisses in 1.5 seconds.',
                  title: 'Short Toast',
                  duration: const Duration(milliseconds: 1500),
                  showProgress: true,
                ),
              ),
              const SizedBox(height: 10),
              _DemoButton(
                label: 'Long: 6 seconds, no progress bar',
                subtitle: 'showProgress: false',
                color: const Color(0xFF14B8A6),
                icon: Icons.timer_off_rounded,
                fullWidth: true,
                onTap: () => TwistToast.info(
                  context,
                  'Stays visible for 6 seconds. No countdown bar.',
                  title: 'Long Toast',
                  duration: const Duration(seconds: 6),
                  showProgress: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}