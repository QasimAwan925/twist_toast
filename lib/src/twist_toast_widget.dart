// =============================================================================
// twist_toast_widget.dart
// =============================================================================
// The main toast widget. Responsibilities:
//   • Positioning (9 directions, keyboard-aware, safe-area-aware)
//   • All 22 entrance / exit animations
//   • All 10 card styles
//   • Dismiss particle overlay trigger
//   • Progress bar, pulsing icon, loading spinner
//   • Action button, swipe-to-dismiss, tap-to-dismiss
// =============================================================================

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'twist_toast_types.dart';
import 'twist_toast_config.dart';
import 'twist_toast_particles.dart';

// =============================================================================
// PUBLIC WIDGET
// =============================================================================

class TwistToastWidget extends StatefulWidget {
  final TwistToastData data;

  /// Original caller context — used for MediaQuery (keyboard, safe area).
  final BuildContext callerContext;

  /// Called after the exit animation finishes.
  final VoidCallback onDismiss;

  // FIX: use super parameter for key
  const TwistToastWidget({
    super.key,
    required this.data,
    required this.callerContext,
    required this.onDismiss,
  });

  @override
  State<TwistToastWidget> createState() => _TwistToastWidgetState();
}

class _TwistToastWidgetState extends State<TwistToastWidget>
    with TickerProviderStateMixin {

  // ── Main entrance / exit controller ───────────────────────────────────────
  late AnimationController _main;

  // ── Supporting loop controllers ────────────────────────────────────────────
  late AnimationController _shimmerCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _loadingCtrl;
  late AnimationController _neonCtrl;
  late AnimationController _shakeCtrl;

  // ── Derived entrance animations ────────────────────────────────────────────
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _scaleY;
  late Animation<double> _rotVal;
  late Animation<double> _flipX;
  late Animation<double> _flipY;
  late Animation<Offset> _slideAnim;
  late Animation<double> _shimmer;
  late Animation<double> _pulse;
  late Animation<double> _neonGlow;
  late Animation<double> _shakeVal;
  late Animation<double> _jellyScaleX;
  late Animation<double> _jellyScaleY;

  // ── Dismiss state ──────────────────────────────────────────────────────────
  Timer? _autoTimer;
  bool _dismissStarted = false;
  Offset _lastTapGlobal = Offset.zero;
  OverlayEntry? _particleEntry;

  // ============================================================================
  // INIT
  // ============================================================================

  @override
  void initState() {
    super.initState();

    final dur = widget.data.animationDuration;

    _main = AnimationController(vsync: this, duration: dur);

    _shimmerCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1900),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _loadingCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    )..repeat();

    _neonCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shakeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );

    _shimmer = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _neonGlow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _neonCtrl, curve: Curves.easeInOut),
    );

    _buildEntryAnimations();

    _main.forward();

    final at = widget.data.animationType;
    if (at == TwistAnimationType.shake ||
        at == TwistAnimationType.jelly ||
        at == TwistAnimationType.heartbeat) {
      _main.addStatusListener((s) {
        if (s == AnimationStatus.completed) { _shakeCtrl.forward(); }
      });
    }

    if (widget.data.type != TwistType.loading) {
      _autoTimer = Timer(
        widget.data.duration,
            () => _triggerDismiss(manual: false),
      );
    }
  }

  // ============================================================================
  // BUILD ENTRANCE ANIMATIONS
  // ============================================================================

  void _buildEntryAnimations() {
    final at = widget.data.animationType;
    final dir = widget.data.direction;

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _main,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scale = Tween<double>(begin: _scaleBegin(at), end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: _scaleCurve(at)),
    );

    _scaleY = Tween<double>(
      begin: at == TwistAnimationType.unfold ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _main, curve: Curves.easeOutBack));

    double rotBegin = 0.0;
    if (at == TwistAnimationType.rotate)     { rotBegin = -0.35; }
    if (at == TwistAnimationType.rotateFull) { rotBegin = -math.pi * 2; }
    if (at == TwistAnimationType.spiral)     { rotBegin = -math.pi * 1.5; }
    _rotVal = Tween<double>(begin: rotBegin, end: 0.0).animate(
      CurvedAnimation(parent: _main, curve: Curves.easeOutBack),
    );

    if (at == TwistAnimationType.swing) {
      _rotVal = Tween<double>(begin: -0.55, end: 0.0).animate(
        CurvedAnimation(parent: _main, curve: Curves.elasticOut),
      );
    }

    _flipX = Tween<double>(
      begin: at == TwistAnimationType.flip ? math.pi : 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _main, curve: Curves.easeOutCubic));

    _flipY = Tween<double>(
      begin: (at == TwistAnimationType.flipY ||
          at == TwistAnimationType.flipDiagonal)
          ? math.pi
          : 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _main, curve: Curves.easeOutCubic));

    _slideAnim = Tween<Offset>(
      begin: _slideBegin(at, dir),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _main, curve: _slideCurve(at)));

    _shakeVal = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _jellyScaleX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.75), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.75, end: 1.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _jellyScaleY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.75), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.75, end: 1.25), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.9), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  double _scaleBegin(TwistAnimationType at) {
    switch (at) {
      case TwistAnimationType.scale:       return 0.0;
      case TwistAnimationType.zoom:        return 0.05;
      case TwistAnimationType.spiral:      return 0.05;
      case TwistAnimationType.elastic:     return 0.35;
      case TwistAnimationType.flip:
      case TwistAnimationType.flipY:
      case TwistAnimationType.flipDiagonal: return 0.85;
      case TwistAnimationType.ripple:      return 0.0;
      case TwistAnimationType.drop:        return 0.75;
      case TwistAnimationType.springUp:    return 0.8;
      case TwistAnimationType.rotateFull:  return 0.2;
      case TwistAnimationType.heartbeat:   return 0.85;
      default:                             return 0.92;
    }
  }

  Curve _scaleCurve(TwistAnimationType at) {
    switch (at) {
      case TwistAnimationType.scale:
      case TwistAnimationType.zoom:
      case TwistAnimationType.ripple:     return Curves.elasticOut;
      case TwistAnimationType.elastic:    return Curves.elasticOut;
      case TwistAnimationType.bounce:
      case TwistAnimationType.drop:       return Curves.bounceOut;
      case TwistAnimationType.springUp:   return Curves.elasticOut;
      case TwistAnimationType.jelly:      return Curves.elasticOut;
      case TwistAnimationType.heartbeat:  return _HeartbeatCurve();
      default:                            return Curves.easeOutBack;
    }
  }

  Offset _slideBegin(TwistAnimationType at, TwistDirection dir) {
    if (at == TwistAnimationType.fade ||
        at == TwistAnimationType.scale ||
        at == TwistAnimationType.zoom ||
        at == TwistAnimationType.flip ||
        at == TwistAnimationType.flipY ||
        at == TwistAnimationType.flipDiagonal ||
        at == TwistAnimationType.rotate ||
        at == TwistAnimationType.rotateFull ||
        at == TwistAnimationType.spiral ||
        at == TwistAnimationType.swing ||
        at == TwistAnimationType.ripple ||
        at == TwistAnimationType.unfold ||
        at == TwistAnimationType.shake ||
        at == TwistAnimationType.jelly ||
        at == TwistAnimationType.heartbeat ||
        at == TwistAnimationType.wipeLeft ||
        at == TwistAnimationType.wipeRight ||
        at == TwistAnimationType.custom) {
      return Offset.zero;
    }

    switch (dir) {
      case TwistDirection.topCenter:     return const Offset(0.0, -1.7);
      case TwistDirection.topLeft:       return const Offset(-1.5, -1.2);
      case TwistDirection.topRight:      return const Offset(1.5, -1.2);
      case TwistDirection.bottomCenter:  return const Offset(0.0, 1.7);
      case TwistDirection.bottomLeft:    return const Offset(-1.5, 1.2);
      case TwistDirection.bottomRight:   return const Offset(1.5, 1.2);
      case TwistDirection.leftCenter:    return const Offset(-1.7, 0.0);
      case TwistDirection.rightCenter:   return const Offset(1.7, 0.0);
      case TwistDirection.center:        return Offset.zero;
    }
  }

  Curve _slideCurve(TwistAnimationType at) {
    switch (at) {
      case TwistAnimationType.bounce:   return Curves.bounceOut;
      case TwistAnimationType.elastic:  return Curves.elasticOut;
      case TwistAnimationType.drop:     return Curves.bounceOut;
      case TwistAnimationType.springUp: return Curves.elasticOut;
      default:                          return Curves.easeOutCubic;
    }
  }

  // ============================================================================
  // DISMISS LOGIC
  // ============================================================================

  void _triggerDismiss({required bool manual}) {
    if (_dismissStarted || !mounted) return;
    _dismissStarted = true;
    _autoTimer?.cancel();

    if (manual &&
        widget.data.dismissEffect != TwistDismissEffect.none &&
        mounted) {
      _showParticleEffect();
    } else {
      _playExitAnimation();
    }
  }

  void _showParticleEffect() {
    if (!mounted) return;

    final origin = _lastTapGlobal == Offset.zero
        ? _approxCardCentre()
        : _lastTapGlobal;

    final overlay = Overlay.of(context,rootOverlay: true);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => TwistParticleOverlay(
        effect: widget.data.dismissEffect,
        color: _typeTheme.color,
        tapPosition: origin,
        customBuilder: widget.data.customDismissEffectBuilder,
        onComplete: () {
          try { entry.remove(); } catch (_) {}
          _particleEntry = null;
          if (mounted) { _playExitAnimation(); }
        },
      ),
    );

    _particleEntry = entry;
    overlay.insert(entry);
  }

  Offset _approxCardCentre() {
    try {
      final mq = MediaQuery.of(widget.callerContext);
      return Offset(mq.size.width / 2, mq.padding.top + 80);
    } catch (_) {
      return const Offset(200, 120);
    }
  }

  void _playExitAnimation() {
    if (!mounted) return;
    _main.reverse().then((_) {
      if (mounted) { widget.onDismiss(); }
    });
  }

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void dispose() {
    _autoTimer?.cancel();
    try { _particleEntry?.remove(); } catch (_) {}
    _main.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    _loadingCtrl.dispose();
    _neonCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  // ============================================================================
  // TYPE THEME
  // ============================================================================

  _TypeTheme get _typeTheme {
    final cfg = TwistConfig.instance;
    switch (widget.data.type) {
      case TwistType.success:
        return _TypeTheme(cfg.successColor ?? const Color(0xFF22C55E),
            Icons.check_circle_rounded, 'Success',
            [const Color(0xFF16A34A), const Color(0xFF22C55E)]);
      case TwistType.error:
        return _TypeTheme(cfg.errorColor ?? const Color(0xFFEF4444),
            Icons.cancel_rounded, 'Error',
            [const Color(0xFFDC2626), const Color(0xFFEF4444)]);
      case TwistType.warning:
        return _TypeTheme(cfg.warningColor ?? const Color(0xFFF59E0B),
            Icons.warning_rounded, 'Warning',
            [const Color(0xFFD97706), const Color(0xFFF59E0B)]);
      case TwistType.info:
        return _TypeTheme(cfg.infoColor ?? const Color(0xFF3B82F6),
            Icons.info_rounded, 'Info',
            [const Color(0xFF2563EB), const Color(0xFF3B82F6)]);
      case TwistType.loading:
        return _TypeTheme(cfg.loadingColor ?? const Color(0xFF8B5CF6),
            Icons.hourglass_top_rounded, 'Loading',
            [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)]);
      case TwistType.custom:
        final c = widget.data.customColor ?? const Color(0xFF8B5CF6);
        return _TypeTheme(c, Icons.stars_rounded, 'Notification',
            widget.data.customGradient ?? [c.withValues(alpha: 0.75), c]);
    }
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    // Read safe area and keyboard insets from the CALLER context so we get
    // the real device values — the overlay context does not have a Scaffold
    // and therefore does not account for system UI padding on its own.
    final mq = MediaQuery.of(widget.callerContext);
    final safeTop    = mq.padding.top;       // status bar height
    final safeBottom = mq.padding.bottom;    // nav bar / home indicator
    final keyboard   = mq.viewInsets.bottom; // soft keyboard
    final screenH    = mq.size.height;

    final cfg = TwistConfig.instance;
    final hp  = cfg.horizontalPadding;
    const cornerOpp = 80.0;
    const gap        = 8.0; // breathing room between toast and system UI

    final data = widget.data;

    Widget card;
    if (data.style == TwistStyle.custom && data.customWidgetBuilder != null) {
      card = data.customWidgetBuilder!(
          context, data, () => _triggerDismiss(manual: true));
    } else {
      card = _buildCard(_typeTheme, cfg);
    }

    final animated = _wrapWithAnimation(card, data);

    final isTopAnchor = data.direction == TwistDirection.topCenter ||
        data.direction == TwistDirection.topLeft  ||
        data.direction == TwistDirection.topRight ||
        data.direction == TwistDirection.center;
    final isLeftAnchor  = data.direction == TwistDirection.leftCenter;
    final isRightAnchor = data.direction == TwistDirection.rightCenter;

    // ── Compute Positioned offsets ─────────────────────────────────────────
    // All values are measured from the SCREEN edge (not the safe-area edge),
    // so we add the system padding ourselves.
    double? top;
    double? bottom;
    double? left;
    double? right;

    // Usable vertical centre (between status bar and nav bar)
    final usableCentreY = safeTop + (screenH - safeTop - safeBottom) / 2 - 44;

    switch (data.direction) {
      case TwistDirection.topCenter:
        top   = safeTop + gap;
        left  = hp;
        right = hp;
        break;
      case TwistDirection.topLeft:
        top   = safeTop + gap;
        left  = hp;
        right = cornerOpp;
        break;
      case TwistDirection.topRight:
        top   = safeTop + gap;
        left  = cornerOpp;
        right = hp;
        break;
      case TwistDirection.bottomCenter:
      // safeBottom already accounts for the nav bar height.
      // Adding keyboard handles the soft keyboard case.
        bottom = safeBottom + keyboard + gap;
        left   = hp;
        right  = hp;
        break;
      case TwistDirection.bottomLeft:
        bottom = safeBottom + keyboard + gap;
        left   = hp;
        right  = cornerOpp;
        break;
      case TwistDirection.bottomRight:
        bottom = safeBottom + keyboard + gap;
        left   = cornerOpp;
        right  = hp;
        break;
      case TwistDirection.leftCenter:
        top   = usableCentreY;
        left  = hp;
        right = cornerOpp;
        break;
      case TwistDirection.rightCenter:
        top   = usableCentreY;
        left  = cornerOpp;
        right = hp;
        break;
      case TwistDirection.center:
        top   = usableCentreY;
        left  = hp;
        right = hp;
        break;
    }

    return Positioned(
      top:    top,
      bottom: bottom,
      left:   left,
      right:  right,
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: const TextStyle(decoration: TextDecoration.none),
          child: GestureDetector(
            onTapDown: (d) => _lastTapGlobal = d.globalPosition,
            onTap: () {
              data.onTap?.call();
              _triggerDismiss(manual: true);
            },
            onVerticalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (isTopAnchor && v < -80) { _triggerDismiss(manual: true); }
              if (!isTopAnchor && !isLeftAnchor && !isRightAnchor && v > 80) { _triggerDismiss(manual: true); }
            },
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (isLeftAnchor  && v < -80) { _triggerDismiss(manual: true); }
              if (isRightAnchor && v >  80) { _triggerDismiss(manual: true); }
              if (v.abs() > 220)            { _triggerDismiss(manual: true); }
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: data.maxWidth ?? cfg.maxWidth,
              ),
              child: animated,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // ANIMATION WRAPPER
  // ============================================================================

  Widget _wrapWithAnimation(Widget child, TwistToastData data) {
    final at = data.animationType;

    if (at == TwistAnimationType.custom && data.customAnimationBuilder != null) {
      return data.customAnimationBuilder!(context, _main, child);
    }

    if (at == TwistAnimationType.fade) {
      return FadeTransition(opacity: _fade, child: child);
    }

    if (at == TwistAnimationType.unfold) {
      return FadeTransition(
        opacity: _fade,
        child: AnimatedBuilder(
          animation: _scaleY,
          builder: (_, c) => Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.identity()..scaleByDouble(1.0, _scaleY.value, 1.0, 1.0),
            child: c,
          ),
          child: child,
        ),
      );
    }

    if (at == TwistAnimationType.wipeLeft || at == TwistAnimationType.wipeRight) {
      return AnimatedBuilder(
        animation: _main,
        builder: (_, c) {
          final p = Curves.easeOutCubic.transform(_main.value);
          return ClipRect(
            clipper: _WipeClipper(
              progress: p,
              fromLeft: at == TwistAnimationType.wipeLeft,
            ),
            child: Opacity(opacity: _fade.value, child: c),
          );
        },
        child: child,
      );
    }

    if (at == TwistAnimationType.flip) {
      return FadeTransition(
        opacity: _fade,
        child: AnimatedBuilder(
          animation: _flipX,
          builder: (_, c) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_flipX.value),
            child: c,
          ),
          child: child,
        ),
      );
    }

    if (at == TwistAnimationType.flipY) {
      return FadeTransition(
        opacity: _fade,
        child: AnimatedBuilder(
          animation: _flipY,
          builder: (_, c) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipY.value),
            child: c,
          ),
          child: child,
        ),
      );
    }

    if (at == TwistAnimationType.flipDiagonal) {
      return FadeTransition(
        opacity: _fade,
        child: AnimatedBuilder(
          animation: _flipY,
          builder: (_, c) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_flipY.value * 0.5)
              ..rotateY(_flipY.value),
            child: c,
          ),
          child: child,
        ),
      );
    }

    if (at == TwistAnimationType.swing) {
      return FadeTransition(
        opacity: _fade,
        child: AnimatedBuilder(
          animation: _rotVal,
          builder: (_, c) => Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.rotationZ(_rotVal.value),
            child: c,
          ),
          child: child,
        ),
      );
    }

    if (at == TwistAnimationType.rotate) {
      return FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedBuilder(
            animation: _rotVal,
            builder: (_, c) => Transform.rotate(angle: _rotVal.value, child: c),
            child: child,
          ),
        ),
      );
    }

    if (at == TwistAnimationType.rotateFull) {
      return FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedBuilder(
            animation: _rotVal,
            builder: (_, c) => Transform.rotate(angle: _rotVal.value, child: c),
            child: child,
          ),
        ),
      );
    }

    if (at == TwistAnimationType.spiral) {
      return FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedBuilder(
            animation: _rotVal,
            builder: (_, c) => Transform.rotate(angle: _rotVal.value, child: c),
            child: child,
          ),
        ),
      );
    }

    if (at == TwistAnimationType.shake) {
      return FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slideAnim,
          child: AnimatedBuilder(
            animation: _shakeVal,
            builder: (_, c) => Transform.translate(
              offset: Offset(_shakeVal.value, 0),
              child: c,
            ),
            child: child,
          ),
        ),
      );
    }

    if (at == TwistAnimationType.jelly) {
      return FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedBuilder(
            animation: _shakeCtrl,
            builder: (_, c) => Transform(
              alignment: Alignment.center,
              // FIX: replaced deprecated .scale with explicit Matrix4 scaleByDouble calls
              transform: Matrix4.identity()
                ..scaleByDouble(_jellyScaleX.value, _jellyScaleY.value, 1.0, 1.0),
              child: c,
            ),
            child: child,
          ),
        ),
      );
    }

    if (at == TwistAnimationType.heartbeat) {
      return FadeTransition(
        opacity: _fade,
        child: ScaleTransition(scale: _scale, child: child),
      );
    }

    // Default: slide + scale + fade
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slideAnim,
        child: ScaleTransition(scale: _scale, child: child),
      ),
    );
  }

  // ============================================================================
  // CARD STYLE SELECTOR
  // ============================================================================

  Widget _buildCard(_TypeTheme theme, TwistConfig cfg) {
    final br = widget.data.borderRadius ??
        BorderRadius.circular(cfg.defaultBorderRadius);
    switch (widget.data.style) {
      case TwistStyle.glass:       return _glassCard(theme, cfg, br);
      case TwistStyle.flat:        return _flatCard(theme, cfg, br);
      case TwistStyle.gradient:    return _gradientCard(theme, cfg, br);
      case TwistStyle.outlined:    return _outlinedCard(theme, cfg, br);
      case TwistStyle.material:    return _materialCard(theme, cfg, br);
      case TwistStyle.minimal:     return _minimalCard(theme, cfg, br);
      case TwistStyle.neon:        return _neonCard(theme, cfg, br);
      case TwistStyle.neumorphic:  return _neumorphicCard(theme, cfg, br);
      case TwistStyle.tinted:      return _tintedCard(theme, cfg, br);
      case TwistStyle.custom:      return _glassCard(theme, cfg, br);
    }
  }

  // ── 1. GLASS ──────────────────────────────────────────────────────────────
  Widget _glassCard(_TypeTheme t, TwistConfig cfg, BorderRadius br) {
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.88),
            borderRadius: br,
            border: Border.all(color: t.color.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(color: t.color.withValues(alpha: 0.22), blurRadius: 28,
                  spreadRadius: 1, offset: const Offset(0, 4)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 20,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: _content(t, cfg, _V.glass, br),
        ),
      ),
    );
  }

  // ── 2. FLAT ───────────────────────────────────────────────────────────────
  Widget _flatCard(_TypeTheme t, TwistConfig cfg, BorderRadius br) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: br,
        border: Border(left: BorderSide(color: t.color, width: 4.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.09), blurRadius: 18,
              offset: const Offset(0, 4)),
          BoxShadow(color: t.color.withValues(alpha: 0.08), blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      child: _content(t, cfg, _V.flat, br),
    );
  }

  // ── 3. GRADIENT ───────────────────────────────────────────────────────────
  Widget _gradientCard(_TypeTheme t, TwistConfig cfg, BorderRadius br) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: br,
          gradient: LinearGradient(
            begin: Alignment(_shimmer.value - 1, -0.4),
            end: Alignment(_shimmer.value, 0.4),
            colors: [
              ...t.gradients,
              t.color.withValues(alpha: 0.55),
              ...t.gradients.reversed,
            ],
          ),
          boxShadow: [
            BoxShadow(color: t.color.withValues(alpha: 0.4), blurRadius: 30,
                spreadRadius: 2, offset: const Offset(0, 6)),
          ],
        ),
        child: child,
      ),
      child: _content(t, cfg, _V.gradient, br),
    );
  }

  // ── 4. OUTLINED ───────────────────────────────────────────────────────────
  Widget _outlinedCard(_TypeTheme t, TwistConfig cfg, BorderRadius br) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: br,
        border: Border.all(color: t.color, width: 1.5),
        boxShadow: [
          BoxShadow(color: t.color.withValues(alpha: 0.18), blurRadius: 18,
              offset: const Offset(0, 4)),
        ],
      ),
      child: _content(t, cfg, _V.outlined, br),
    );
  }

  // ── 5. MATERIAL ───────────────────────────────────────────────────────────
  Widget _materialCard(_TypeTheme t, TwistConfig cfg, BorderRadius br) {
    return Material(
      elevation: 10,
      borderRadius: br,
      shadowColor: t.color.withValues(alpha: 0.3),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: br,
          border: Border.all(color: t.color.withValues(alpha: 0.14)),
        ),
        child: _content(t, cfg, _V.material, br),
      ),
    );
  }

  // ── 6. MINIMAL ────────────────────────────────────────────────────────────
  Widget _minimalCard(_TypeTheme t, TwistConfig cfg, BorderRadius br) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: t.color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: t.color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: t.color.withValues(alpha: 0.15), blurRadius: 14,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(t.icon, color: t.color, size: 17),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.data.message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.color,
                decoration: TextDecoration.none,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _triggerDismiss(manual: true),
            child: Icon(Icons.close_rounded,
                color: t.color.withValues(alpha: 0.6), size: 14),
          ),
        ],
      ),
    );
  }

  // ── 7. NEON ───────────────────────────────────────────────────────────────
  Widget _neonCard(_TypeTheme t, TwistConfig cfg, BorderRadius br) {
    return AnimatedBuilder(
      animation: _neonGlow,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF050510),
          borderRadius: br,
          border: Border.all(color: t.color.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: t.color.withValues(alpha: 0.35 * _neonGlow.value),
                blurRadius: 8, spreadRadius: 1),
            BoxShadow(
                color: t.color.withValues(alpha: 0.28 * _neonGlow.value),
                blurRadius: 26, spreadRadius: 4),
            BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: child,
      ),
      child: _content(t, cfg, _V.neon, br),
    );
  }

  // ── 8. NEUMORPHIC ─────────────────────────────────────────────────────────
  Widget _neumorphicCard(_TypeTheme t, TwistConfig cfg, BorderRadius br) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: br,
        boxShadow: [
          const BoxShadow(
              color: Colors.white, blurRadius: 16, offset: Offset(-6, -6)),
          BoxShadow(color: Colors.grey.withValues(alpha: 0.35), blurRadius: 16,
              offset: const Offset(6, 6)),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: br,
          border: Border.all(color: t.color.withValues(alpha: 0.1)),
        ),
        child: _content(t, cfg, _V.neumorphic, br),
      ),
    );
  }

  // ── 9. TINTED ─────────────────────────────────────────────────────────────
  Widget _tintedCard(_TypeTheme t, TwistConfig cfg, BorderRadius br) {
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: t.color.withValues(alpha: 0.18),
            borderRadius: br,
            border: Border.all(color: t.color.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(color: t.color.withValues(alpha: 0.2), blurRadius: 20,
                  spreadRadius: 1, offset: const Offset(0, 4)),
            ],
          ),
          child: _content(t, cfg, _V.tinted, br),
        ),
      ),
    );
  }

  // ============================================================================
  // SHARED CARD CONTENT
  // ============================================================================

  Widget _content(_TypeTheme t, TwistConfig cfg, _V variant, BorderRadius br) {
    final data = widget.data;
    final title = data.title ?? t.label;

    final isLight  = variant == _V.flat || variant == _V.material || variant == _V.neumorphic;
    final isGrad   = variant == _V.gradient;
    final isTinted = variant == _V.tinted;

    final titleColor = isGrad ? Colors.white : t.color;
    final msgColor = isGrad
        ? Colors.white.withValues(alpha: 0.92)
        : isLight
        ? Colors.black54
        : isTinted
        ? t.color.withValues(alpha: 0.85)
        : Colors.white70;
    final iconBg = isGrad
        ? Colors.white.withValues(alpha: 0.18)
        : isLight
        ? t.color.withValues(alpha: 0.10)
        : t.color.withValues(alpha: 0.14);
    final closeIconColor = isGrad
        ? Colors.white.withValues(alpha: 0.85)
        : isLight ? Colors.black38 : Colors.white54;
    final closeBg = isGrad
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.09);

    return ClipRRect(
      borderRadius: br,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.showProgress && data.type != TwistType.loading)
            _TwistProgress(
              duration: data.duration,
              color: isGrad ? Colors.white : t.color,
              bg: isGrad
                  ? Colors.white.withValues(alpha: 0.22)
                  : isLight
                  ? t.color.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.08),
            ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              14,
              data.showProgress ? 10 : 14,
              14,
              data.action != null ? 4 : 14,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(t, iconBg, isGrad, variant == _V.neon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          letterSpacing: 0.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: msgColor,
                          height: 1.4,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (data.type != TwistType.loading)
                  GestureDetector(
                    onTap: () => _triggerDismiss(manual: true),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: closeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.close_rounded,
                          color: closeIconColor, size: 15),
                    ),
                  ),
              ],
            ),
          ),

          if (data.action != null)
            _buildActionRow(t, isGrad, isLight),
        ],
      ),
    );
  }

  // ── Icon widget ────────────────────────────────────────────────────────────
  Widget _buildIcon(_TypeTheme t, Color bg, bool isGrad, bool isNeon) {
    final data = widget.data;

    if (data.type == TwistType.loading) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(10),
        child: AnimatedBuilder(
          animation: _loadingCtrl,
          builder: (_, __) => CircularProgressIndicator(
            value: null,
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
                isGrad ? Colors.white : t.color),
          ),
        ),
      );
    }

    final icon = (data.type == TwistType.custom && data.customIcon != null)
        ? data.customIcon!
        : Icon(t.icon, color: isGrad ? Colors.white : t.color, size: 22);

    return ScaleTransition(
      scale: _pulse,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isNeon
              ? [
            BoxShadow(
                color: t.color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1)
          ]
              : null,
        ),
        child: Center(child: icon),
      ),
    );
  }

  // ── Action row ─────────────────────────────────────────────────────────────
  Widget _buildActionRow(_TypeTheme t, bool isGrad, bool isLight) {
    final a = widget.data.action!;
    final color     = a.color ?? t.color;
    final textColor = a.textColor ?? (isGrad ? Colors.white : color);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              a.onPressed();
              if (a.dismissOnPress) { _triggerDismiss(manual: true); }
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: isGrad
                    ? Colors.white.withValues(alpha: 0.18)
                    : isLight
                    ? color.withValues(alpha: 0.10)
                    : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isGrad
                      ? Colors.white.withValues(alpha: 0.3)
                      : color.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                a.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PROGRESS BAR
// =============================================================================

class _TwistProgress extends StatefulWidget {
  final Duration duration;
  final Color color;
  final Color bg;

  const _TwistProgress({
    required this.duration,
    required this.color,
    required this.bg,
  });

  @override
  State<_TwistProgress> createState() => _TwistProgressState();
}

class _TwistProgressState extends State<_TwistProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => SizedBox(
        height: 3,
        child: LinearProgressIndicator(
          value: 1 - _c.value,
          backgroundColor: widget.bg,
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
          minHeight: 3,
        ),
      ),
    );
  }
}

// =============================================================================
// WIPE CLIPPER
// =============================================================================

class _WipeClipper extends CustomClipper<Rect> {
  final double progress;
  final bool fromLeft;

  const _WipeClipper({required this.progress, required this.fromLeft});

  @override
  Rect getClip(Size size) {
    if (fromLeft) {
      return Rect.fromLTWH(0, 0, size.width * progress, size.height);
    } else {
      final w = size.width * progress;
      return Rect.fromLTWH(size.width - w, 0, w, size.height);
    }
  }

  @override
  bool shouldReclip(_WipeClipper old) => old.progress != progress;
}

// =============================================================================
// HEARTBEAT CURVE
// =============================================================================

class _HeartbeatCurve extends Curve {
  @override
  double transformInternal(double t) {
    if (t < 0.2)  { return 1.0 + math.sin(t * math.pi / 0.2) * 0.15; }
    if (t < 0.35) { return 1.0; }
    if (t < 0.55) { return 1.0 + math.sin((t - 0.35) * math.pi / 0.2) * 0.25; }
    return 1.0;
  }
}

// =============================================================================
// INTERNAL MODELS
// =============================================================================

enum _V { glass, flat, gradient, outlined, material, neumorphic, neon, tinted }

class _TypeTheme {
  final Color color;
  final IconData icon;
  final String label;
  final List<Color> gradients;

  const _TypeTheme(this.color, this.icon, this.label, this.gradients);
}