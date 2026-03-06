// =============================================================================
// twist_toast_particles.dart
// =============================================================================
// All built-in dismiss particle / burst effects.
//
// Each effect is a self-contained StatefulWidget that:
//   1. Animates itself with its own AnimationController
//   2. Calls onComplete() when the animation finishes
//
// The effects are rendered on a full-screen Overlay layer that sits above
// the toast card so particles can fly anywhere on screen.
// =============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'twist_toast_types.dart';

// =============================================================================
// PUBLIC: Full-screen particle overlay dispatcher
// =============================================================================

/// Full-screen transparent overlay that hosts the chosen dismiss effect.
/// Inserted into the Flutter Overlay above the toast card widget.
class TwistParticleOverlay extends StatelessWidget {
  final TwistDismissEffect effect;

  /// The toast accent colour — effects are tinted with this.
  final Color color;

  /// Screen-coordinate position of the user's tap.
  final Offset tapPosition;

  /// Must be called by the effect when it finishes, so the toast can exit.
  final VoidCallback onComplete;

  /// Used only when [effect] == [TwistDismissEffect.custom].
  final TwistDismissEffectBuilder? customBuilder;

  const TwistParticleOverlay({
    Key? key,
    required this.effect,
    required this.color,
    required this.tapPosition,
    required this.onComplete,
    this.customBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // None: skip immediately
    if (effect == TwistDismissEffect.none) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onComplete());
      return const SizedBox.shrink();
    }

    // Custom: hand off to developer-supplied builder
    if (effect == TwistDismissEffect.custom && customBuilder != null) {
      return Positioned.fill(
        child: IgnorePointer(
          child: customBuilder!(context, color, tapPosition, onComplete),
        ),
      );
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: _buildEffect(),
      ),
    );
  }

  Widget _buildEffect() {
    switch (effect) {
      case TwistDismissEffect.burst:
        return _BurstEffect(color: color, origin: tapPosition, onComplete: onComplete);
      case TwistDismissEffect.sparkle:
        return _SparkleEffect(color: color, origin: tapPosition, onComplete: onComplete);
      case TwistDismissEffect.confetti:
        return _ConfettiEffect(color: color, origin: tapPosition, onComplete: onComplete);
      case TwistDismissEffect.bubbles:
        return _BubblesEffect(color: color, origin: tapPosition, onComplete: onComplete);
      case TwistDismissEffect.firework:
        return _FireworkEffect(color: color, origin: tapPosition, onComplete: onComplete);
      case TwistDismissEffect.shatter:
        return _ShatterEffect(color: color, origin: tapPosition, onComplete: onComplete);
      case TwistDismissEffect.rippleBurst:
        return _RippleBurstEffect(color: color, origin: tapPosition, onComplete: onComplete);
      case TwistDismissEffect.hearts:
        return _HeartsEffect(color: color, origin: tapPosition, onComplete: onComplete);
      case TwistDismissEffect.snow:
        return _SnowEffect(color: color, origin: tapPosition, onComplete: onComplete);
      case TwistDismissEffect.lightning:
        return _LightningEffect(color: color, origin: tapPosition, onComplete: onComplete);
      case TwistDismissEffect.pixelate:
        return _PixelateEffect(color: color, origin: tapPosition, onComplete: onComplete);
      default:
        WidgetsBinding.instance.addPostFrameCallback((_) => onComplete());
        return const SizedBox.shrink();
    }
  }
}

// =============================================================================
// SHARED HELPERS
// =============================================================================

// Random number generator shared across all effects
final _rng = math.Random();

// Convenience: random double in a range
double _rand(double min, double max) => min + _rng.nextDouble() * (max - min);

// Convenience: random angle in [0, 2π]
double _randAngle() => _rng.nextDouble() * math.pi * 2;

// Convenience: lerp a colour toward white
Color _lighten(Color c, double t) => Color.lerp(c, Colors.white, t)!;

// =============================================================================
// EFFECT BASE — shared SingleTicker + listener pattern
// =============================================================================

// Internal particle data used by several effects
class _P {
  double x, y;           // current position
  final double vx, vy;   // velocity per unit (used for physics)
  final double size;
  final Color color;
  double rot;            // rotation (radians)
  final double rotV;     // rotation velocity

  _P({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.size, required this.color,
    this.rot = 0, this.rotV = 0,
  });
}

// =============================================================================
// 1. BURST — ring of dots explode outward
// =============================================================================

class _BurstEffect extends StatefulWidget {
  final Color color;
  final Offset origin;
  final VoidCallback onComplete;
  const _BurstEffect({required this.color, required this.origin, required this.onComplete});
  @override State<_BurstEffect> createState() => _BurstEffectState();
}

class _BurstEffectState extends State<_BurstEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_P> _pts;

  @override
  void initState() {
    super.initState();
    // 20 particles spread evenly in a circle with slight random jitter
    _pts = List.generate(20, (i) {
      final a = (i / 20) * math.pi * 2 + _rand(-0.15, 0.15);
      final spd = _rand(90, 180);
      return _P(
        x: widget.origin.dx, y: widget.origin.dy,
        vx: math.cos(a) * spd,
        vy: math.sin(a) * spd,
        size: _rand(5, 11),
        color: _lighten(widget.color, _rng.nextDouble() * 0.5),
      );
    });
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 750))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete(); })
      ..forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    return CustomPaint(
      painter: _SimplePainter(
            (canvas, size) {
          for (final p in _pts) {
            // Ease-out travel: fast start, slow end
            final dist = Curves.easeOut.transform(t);
            final x = p.x + p.vx * dist;
            final y = p.y + p.vy * dist;
            // Fade out in the last 40%
            final opacity = t < 0.6 ? 1.0 : 1.0 - (t - 0.6) / 0.4;
            // Shrink slightly as they travel
            final r = p.size * (1 - t * 0.35);
            canvas.drawCircle(
              Offset(x, y), r.clamp(0, 999),
              Paint()..color = p.color.withValues(alpha: opacity.clamp(0, 1)),
            );
          }
        },
      ),
    );
  }
}

// =============================================================================
// 2. SPARKLE — 4-pointed star sparkles radiate from centre
// =============================================================================

class _SparkleEffect extends StatefulWidget {
  final Color color;
  final Offset origin;
  final VoidCallback onComplete;
  const _SparkleEffect({required this.color, required this.origin, required this.onComplete});
  @override State<_SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<_SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_P> _pts;

  @override
  void initState() {
    super.initState();
    _pts = List.generate(26, (i) {
      final a = _randAngle();
      final spd = _rand(40, 130);
      return _P(
        x: widget.origin.dx, y: widget.origin.dy,
        vx: math.cos(a) * spd, vy: math.sin(a) * spd,
        size: _rand(4, 9),
        color: Color.lerp(widget.color, Colors.yellow, _rand(0, 0.55))!,
      );
    });
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 850))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete(); })
      ..forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    return CustomPaint(
      painter: _SimplePainter((canvas, _) {
        for (final p in _pts) {
          final eased = Curves.easeOut.transform(t);
          final x = p.x + p.vx * eased;
          final y = p.y + p.vy * eased;
          final opacity = (1 - t).clamp(0.0, 1.0);
          _drawStar(canvas, Offset(x, y), p.size * (1 - t * 0.4),
              p.color.withValues(alpha: opacity));
        }
      }),
    );
  }

  void _drawStar(Canvas canvas, Offset c, double r, Color color) {
    if (r <= 0) return;
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final radius = i.isEven ? r : r * 0.38;
      final angle = i * math.pi / 4 - math.pi / 2;
      final x = c.dx + radius * math.cos(angle);
      final y = c.dy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

// =============================================================================
// 3. CONFETTI — gravity-affected coloured squares scatter
// =============================================================================

class _ConfettiEffect extends StatefulWidget {
  final Color color;
  final Offset origin;
  final VoidCallback onComplete;
  const _ConfettiEffect({required this.color, required this.origin, required this.onComplete});
  @override State<_ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<_ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_P> _pts;
  late List<Color> _palette;

  @override
  void initState() {
    super.initState();
    _palette = [
      widget.color, Colors.pinkAccent, Colors.amberAccent,
      Colors.cyanAccent, Colors.greenAccent, Colors.purpleAccent,
      Colors.orangeAccent, Colors.lightBlueAccent,
    ];
    _pts = List.generate(32, (i) {
      final a = _randAngle();
      final spd = _rand(70, 160);
      return _P(
        x: widget.origin.dx, y: widget.origin.dy,
        vx: math.cos(a) * spd, vy: math.sin(a) * spd,
        size: _rand(5, 9),
        color: _palette[_rng.nextInt(_palette.length)],
        rot: _randAngle(), rotV: _rand(-10, 10),
      );
    });
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete(); })
      ..forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    return CustomPaint(
      painter: _SimplePainter((canvas, _) {
        for (final p in _pts) {
          final eased = Curves.easeOut.transform(t);
          final x = p.x + p.vx * eased;
          // Gravity adds downward acceleration on Y
          final y = p.y + p.vy * eased + 80 * t * t;
          final opacity = t < 0.65
              ? 1.0
              : (1.0 - (t - 0.65) / 0.35).clamp(0.0, 1.0);
          final rot = p.rot + p.rotV * t;

          final paint = Paint()..color = p.color.withValues(alpha: opacity);
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(rot);
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
            paint,
          );
          canvas.restore();
        }
      }),
    );
  }
}

// =============================================================================
// 4. BUBBLES — translucent bubbles float upward with glint
// =============================================================================

class _BubblesEffect extends StatefulWidget {
  final Color color;
  final Offset origin;
  final VoidCallback onComplete;
  const _BubblesEffect({required this.color, required this.origin, required this.onComplete});
  @override State<_BubblesEffect> createState() => _BubblesEffectState();
}

class _BubblesEffectState extends State<_BubblesEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_P> _pts;

  @override
  void initState() {
    super.initState();
    // Bubbles start near origin but spread horizontally before floating up
    _pts = List.generate(18, (i) {
      final xOff = _rand(-60, 60);
      final spd = _rand(60, 110);
      return _P(
        x: widget.origin.dx + xOff,
        y: widget.origin.dy,
        vx: _rand(-25, 25),
        vy: -spd,  // negative = upward
        size: _rand(10, 22),
        color: widget.color.withValues(alpha: 0.5),
      );
    });
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 950))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete(); })
      ..forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    return CustomPaint(
      painter: _SimplePainter((canvas, _) {
        for (final p in _pts) {
          final x = p.x + p.vx * t;
          // Slight sine wobble on X as they float up
          final wobble = math.sin(t * math.pi * 4 + p.size) * 8;
          final y = p.y + p.vy * t + wobble;
          final opacity = (1 - t).clamp(0.0, 1.0);
          final r = p.size * (1 + t * 0.25);

          // Bubble fill (translucent)
          canvas.drawCircle(
            Offset(x, y), r,
            Paint()..color = p.color.withValues(alpha: opacity * 0.28),
          );
          // Bubble border
          canvas.drawCircle(
            Offset(x, y), r,
            Paint()
              ..color = widget.color.withValues(alpha: opacity * 0.75)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6,
          );
          // Glint highlight
          canvas.drawCircle(
            Offset(x - r * 0.3, y - r * 0.3), r * 0.22,
            Paint()..color = Colors.white.withValues(alpha: opacity * 0.65),
          );
        }
      }),
    );
  }
}

// =============================================================================
// 5. FIREWORK — rocket rises then explodes with coloured trails
// =============================================================================

class _FireworkEffect extends StatefulWidget {
  final Color color;
  final Offset origin;
  final VoidCallback onComplete;
  const _FireworkEffect({required this.color, required this.origin, required this.onComplete});
  @override State<_FireworkEffect> createState() => _FireworkEffectState();
}

class _FireworkEffectState extends State<_FireworkEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_P> _pts;

  @override
  void initState() {
    super.initState();
    // Two shells: a tight inner ring (bright) + loose outer ring (coloured)
    final inner = List.generate(14, (i) {
      final a = (i / 14) * math.pi * 2;
      return _P(
        x: widget.origin.dx, y: widget.origin.dy,
        vx: math.cos(a) * 140, vy: math.sin(a) * 140,
        size: 5, color: _lighten(widget.color, 0.65),
      );
    });
    final outer = List.generate(22, (i) {
      final a = _randAngle();
      final spd = _rand(70, 180);
      return _P(
        x: widget.origin.dx, y: widget.origin.dy,
        vx: math.cos(a) * spd, vy: math.sin(a) * spd,
        size: _rand(3, 6),
        color: Color.lerp(widget.color, Colors.orangeAccent, _rand(0, 0.8))!,
      );
    });
    _pts = [...inner, ...outer];

    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 950))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete(); })
      ..forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    return CustomPaint(
      painter: _SimplePainter((canvas, _) {
        for (final p in _pts) {
          final eased = Curves.easeOut.transform(t);
          final x = p.x + p.vx * eased;
          // Slight gravity on Y
          final y = p.y + p.vy * eased + 30 * t * t;
          final opacity = t < 0.38 ? 1.0 : (1 - (t - 0.38) / 0.62).clamp(0, 1);

          // Trail line from origin toward current position
          final trailRatio = 0.65;
          final tx = p.x + p.vx * eased * trailRatio;
          final ty = p.y + p.vy * eased * trailRatio + 30 * t * t * trailRatio;
          canvas.drawLine(
            Offset(tx, ty), Offset(x, y),
            Paint()
              ..color = p.color.withValues(alpha: opacity * 0.38)
              ..strokeWidth = p.size * 0.55
              ..strokeCap = StrokeCap.round,
          );
          // Head dot
          canvas.drawCircle(
            Offset(x, y), (p.size * (1 - t * 0.5)).clamp(0, 999),
            Paint()..color = p.color.withValues(alpha: opacity.toDouble()),
          );
        }
      }),
    );
  }
}

// =============================================================================
// 6. SHATTER — card breaks into triangular shards
// =============================================================================

class _ShardData {
  final Offset center;
  final Offset target;
  final double size, rot, rotV;
  final Color color;
  const _ShardData({required this.center, required this.target,
    required this.size, required this.rot, required this.rotV, required this.color});
}

class _ShatterEffect extends StatefulWidget {
  final Color color;
  final Offset origin;
  final VoidCallback onComplete;
  const _ShatterEffect({required this.color, required this.origin, required this.onComplete});
  @override State<_ShatterEffect> createState() => _ShatterEffectState();
}

class _ShatterEffectState extends State<_ShatterEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_ShardData> _shards;

  @override
  void initState() {
    super.initState();
    _shards = List.generate(18, (_) {
      final a = _randAngle();
      final dist = _rand(30, 90);
      return _ShardData(
        center: widget.origin,
        target: Offset(math.cos(a) * dist, math.sin(a) * dist),
        size: _rand(12, 24),
        rot: _randAngle(),
        rotV: _rand(-8, 8),
        color: _lighten(widget.color, _rand(0, 0.45)).withValues(alpha: 0.88),
      );
    });
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 820))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete(); })
      ..forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    return CustomPaint(
      painter: _SimplePainter((canvas, _) {
        final eased = Curves.easeOut.transform(t);
        for (final s in _shards) {
          final pos = s.center + s.target * eased;
          final opacity = (1 - t).clamp(0.0, 1.0);
          final rot = s.rot + s.rotV * t;

          canvas.save();
          canvas.translate(pos.dx, pos.dy);
          canvas.rotate(rot);

          final h = s.size * 0.6;
          final w = s.size * 0.5;
          final path = Path()
            ..moveTo(0, -h)
            ..lineTo(w, h)
            ..lineTo(-w, h)
            ..close();
          canvas.drawPath(path, Paint()..color = s.color.withValues(alpha: opacity));
          canvas.restore();
        }
      }),
    );
  }
}

// =============================================================================
// 7. RIPPLE BURST — 3 staggered expanding ripple rings
// =============================================================================

class _RippleBurstEffect extends StatefulWidget {
  final Color color;
  final Offset origin;
  final VoidCallback onComplete;
  const _RippleBurstEffect({required this.color, required this.origin, required this.onComplete});
  @override State<_RippleBurstEffect> createState() => _RippleBurstEffectState();
}

class _RippleBurstEffectState extends State<_RippleBurstEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 750))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete(); })
      ..forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    return CustomPaint(
      painter: _SimplePainter((canvas, _) {
        // 3 rings with staggered delays: 0ms, 150ms, 300ms
        for (int i = 0; i < 3; i++) {
          final delay = i * 0.22;
          final p = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
          if (p <= 0) continue;
          final radius = Curves.easeOut.transform(p) * 140.0;
          final opacity = (1 - p).clamp(0.0, 1.0);

          canvas.drawCircle(
            widget.origin, radius,
            Paint()
              ..color = widget.color.withValues(alpha: opacity * 0.55)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5 * (1 - p * 0.6),
          );
        }
      }),
    );
  }
}

// =============================================================================
// 8. HEARTS — bezier heart shapes scatter outward
// =============================================================================

class _HeartsEffect extends StatefulWidget {
  final Color color;
  final Offset origin;
  final VoidCallback onComplete;
  const _HeartsEffect({required this.color, required this.origin, required this.onComplete});
  @override State<_HeartsEffect> createState() => _HeartsEffectState();
}

class _HeartsEffectState extends State<_HeartsEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_P> _pts;

  @override
  void initState() {
    super.initState();
    _pts = List.generate(16, (_) {
      final a = _randAngle();
      final spd = _rand(55, 115);
      return _P(
        x: widget.origin.dx, y: widget.origin.dy,
        vx: math.cos(a) * spd, vy: math.sin(a) * spd,
        size: _rand(9, 18),
        color: Color.lerp(widget.color, Colors.pinkAccent, _rand(0, 0.65))!,
        rot: _randAngle(),
      );
    });
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 950))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete(); })
      ..forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    return CustomPaint(
      painter: _SimplePainter((canvas, _) {
        for (final p in _pts) {
          final eased = Curves.easeOut.transform(t);
          final x = p.x + p.vx * eased;
          // Hearts float slightly upward regardless of angle
          final y = p.y + p.vy * eased - 15 * t;
          final opacity = (1 - t).clamp(0.0, 1.0);
          final s = p.size * (1 + t * 0.18);

          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(p.rot + t * 0.8);

          final path = _heartPath(s);
          canvas.drawPath(path, Paint()..color = p.color.withValues(alpha: opacity));
          canvas.restore();
        }
      }),
    );
  }

  Path _heartPath(double s) {
    // Classic heart using cubic bezier curves
    final path = Path();
    path.moveTo(0, s * 0.25);
    path.cubicTo(-s * 0.9, -s * 0.25, -s * 0.9, s * 0.75, 0, s * 1.1);
    path.cubicTo(s * 0.9, s * 0.75, s * 0.9, -s * 0.25, 0, s * 0.25);
    return path;
  }
}

// =============================================================================
// 9. SNOW — snowflake particles drift downward
// =============================================================================

class _SnowEffect extends StatefulWidget {
  final Color color;
  final Offset origin;
  final VoidCallback onComplete;
  const _SnowEffect({required this.color, required this.origin, required this.onComplete});
  @override State<_SnowEffect> createState() => _SnowEffectState();
}

class _SnowEffectState extends State<_SnowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_P> _pts;

  @override
  void initState() {
    super.initState();
    _pts = List.generate(28, (_) {
      return _P(
        // Spread flakes across the width of the card area
        x: widget.origin.dx + _rand(-100, 100),
        y: widget.origin.dy - _rand(0, 30), // start slightly above tap
        vx: _rand(-18, 18),
        vy: _rand(60, 140), // falls downward
        size: _rand(4, 10),
        color: Colors.white.withValues(alpha: 0.9),
        rot: _randAngle(),
        rotV: _rand(-3, 3),
      );
    });
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete(); })
      ..forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    return CustomPaint(
      painter: _SimplePainter((canvas, _) {
        for (final p in _pts) {
          // Gentle sine drift on X
          final drift = math.sin(t * math.pi * 3 + p.size) * 12;
          final x = p.x + p.vx * t + drift;
          final y = p.y + p.vy * t;
          final opacity = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3).clamp(0, 1);

          // Draw a 6-arm snowflake
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(p.rot + p.rotV * t);
          _drawSnowflake(canvas, p.size,
              Paint()
                ..color = p.color.withValues(alpha: opacity.toDouble())
                ..strokeWidth = 1.2
                ..strokeCap = StrokeCap.round);
          canvas.restore();
        }
      }),
    );
  }

  void _drawSnowflake(Canvas canvas, double r, Paint paint) {
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      canvas.drawLine(Offset.zero,
          Offset(math.cos(angle) * r, math.sin(angle) * r), paint);
    }
  }
}

// =============================================================================
// 10. LIGHTNING — electric fork-lightning bolts
// =============================================================================

class _LightningBolt {
  final List<Offset> points;
  final Color color;
  const _LightningBolt({required this.points, required this.color});
}

class _LightningEffect extends StatefulWidget {
  final Color color;
  final Offset origin;
  final VoidCallback onComplete;
  const _LightningEffect({required this.color, required this.origin, required this.onComplete});
  @override State<_LightningEffect> createState() => _LightningEffectState();
}

class _LightningEffectState extends State<_LightningEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_LightningBolt> _bolts;

  @override
  void initState() {
    super.initState();
    // Generate 5 jagged bolt paths
    _bolts = List.generate(5, (i) {
      final targetAngle = _randAngle();
      final length = _rand(60, 130);
      final points = _generateBolt(
        widget.origin,
        Offset(
          widget.origin.dx + math.cos(targetAngle) * length,
          widget.origin.dy + math.sin(targetAngle) * length,
        ),
      );
      return _LightningBolt(
        points: points,
        color: Color.lerp(widget.color, Colors.white, _rand(0.3, 0.8))!,
      );
    });

    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 550))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete(); })
      ..forward();
  }

  // Generates a jagged line from start to end with random perpendicular offsets
  List<Offset> _generateBolt(Offset start, Offset end) {
    final pts = <Offset>[start];
    final segments = 6;
    for (int i = 1; i < segments; i++) {
      final t = i / segments;
      final base = Offset.lerp(start, end, t)!;
      final perp = Offset(-(end - start).dy, (end - start).dx).normalize();
      final jitter = _rand(-20, 20);
      pts.add(base + perp * jitter);
    }
    pts.add(end);
    return pts;
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    // Flash on (0→0.3) then fade off (0.3→1.0)
    final opacity = t < 0.3 ? t / 0.3 : 1.0 - (t - 0.3) / 0.7;

    return CustomPaint(
      painter: _SimplePainter((canvas, _) {
        for (final bolt in _bolts) {
          // Glow (thick, very transparent)
          final glowPaint = Paint()
            ..color = bolt.color.withValues(alpha: (opacity * 0.3).clamp(0, 1))
            ..strokeWidth = 7
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke;

          // Core (thin, fully opaque)
          final corePaint = Paint()
            ..color = bolt.color.withValues(alpha: opacity.clamp(0, 1))
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke;

          final path = Path()..moveTo(bolt.points.first.dx, bolt.points.first.dy);
          for (int i = 1; i < bolt.points.length; i++) {
            path.lineTo(bolt.points[i].dx, bolt.points[i].dy);
          }
          canvas.drawPath(path, glowPaint);
          canvas.drawPath(path, corePaint);
        }
      }),
    );
  }
}

// =============================================================================
// 11. PIXELATE — 8-bit grid of coloured squares scatter
// =============================================================================

class _PixelData {
  final Offset start;
  final Offset velocity;
  final double size;
  final Color color;
  const _PixelData({required this.start, required this.velocity,
    required this.size, required this.color});
}

class _PixelateEffect extends StatefulWidget {
  final Color color;
  final Offset origin;
  final VoidCallback onComplete;
  const _PixelateEffect({required this.color, required this.origin, required this.onComplete});
  @override State<_PixelateEffect> createState() => _PixelateEffectState();
}

class _PixelateEffectState extends State<_PixelateEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_PixelData> _pixels;

  // 8-bit palette for the pixel effect
  static const List<Color> _palette8bit = [
    Color(0xFFFF004F), Color(0xFFFFB700), Color(0xFF00E5FF),
    Color(0xFF00FF41), Color(0xFFFF6EC7), Color(0xFFFFFFFF),
    Color(0xFF7B2FBE), Color(0xFFFFA500),
  ];

  @override
  void initState() {
    super.initState();
    // Arrange pixels in a loose grid pattern around the origin
    _pixels = [];
    for (int row = -3; row <= 3; row++) {
      for (int col = -5; col <= 5; col++) {
        final x = widget.origin.dx + col * 12.0 + _rand(-4, 4);
        final y = widget.origin.dy + row * 12.0 + _rand(-4, 4);
        final a = _randAngle();
        final spd = _rand(50, 130);
        _pixels.add(_PixelData(
          start: Offset(x, y),
          velocity: Offset(math.cos(a) * spd, math.sin(a) * spd),
          size: _rand(5, 10),
          color: _palette8bit[_rng.nextInt(_palette8bit.length)],
        ));
      }
    }

    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete(); })
      ..forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _c.value;
    return CustomPaint(
      painter: _SimplePainter((canvas, _) {
        final eased = Curves.easeOut.transform(t);
        for (final px in _pixels) {
          final x = px.start.dx + px.velocity.dx * eased;
          final y = px.start.dy + px.velocity.dy * eased + 40 * t * t;
          final opacity = t < 0.55 ? 1.0 : (1 - (t - 0.55) / 0.45).clamp(0, 1);

          canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: px.size, height: px.size),
            Paint()..color = px.color.withValues(alpha: opacity.toDouble()),
          );
        }
      }),
    );
  }
}

// =============================================================================
// SHARED: Simple painter that accepts a draw callback
// =============================================================================

/// Lightweight CustomPainter that accepts a draw function.
/// Avoids creating a new class per effect.
class _SimplePainter extends CustomPainter {
  final void Function(Canvas, Size) draw;
  const _SimplePainter(this.draw);

  @override
  void paint(Canvas canvas, Size size) => draw(canvas, size);

  @override
  bool shouldRepaint(_SimplePainter old) => true;
}

// =============================================================================
// OFFSET EXTENSION — used by lightning to normalize vectors
// =============================================================================
extension _OffsetNorm on Offset {
  Offset normalize() {
    final d = distance;
    return d == 0 ? Offset.zero : this / d;
  }
}