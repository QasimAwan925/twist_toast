// =============================================================================
// twist_toast_core.dart
// =============================================================================
// Main public API: TwistToast
// Manages the Overlay, queue, haptics, and all convenience methods.
// =============================================================================

import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'twist_toast_types.dart';
import 'twist_toast_config.dart';
import 'twist_toast_widget.dart';

/// The primary entry point for showing TwistToast notifications.
///
/// Quick start:
/// ```dart
/// TwistToast.success(context, 'Done!');
/// TwistToast.error(context, 'Oops!');
/// TwistToast.warning(context, 'Low balance.');
/// TwistToast.info(context, 'Driver is near.');
/// TwistToast.loading(context, 'Finding driver...');
/// // Dismiss manually:
/// TwistToast.dismiss();
/// ```
///
/// Full control:
/// ```dart
/// TwistToast.show(context, TwistToastData(
///   message: 'Ride booked!',
///   type: TwistType.success,
///   style: TwistStyle.gradient,
///   animationType: TwistAnimationType.bounce,
///   dismissEffect: TwistDismissEffect.confetti,
/// ));
/// ```
class TwistToast {
  TwistToast._();

  // ── Queue ──────────────────────────────────────────────────────────────────
  static final Queue<_Queued> _queue = Queue();
  static OverlayEntry? _currentEntry;
  static bool _isShowing = false;
  static Timer? _safetyTimer;

  // ── State getters ──────────────────────────────────────────────────────────

  /// True while a toast is visible or animating.
  static bool get isShowing => _isShowing;

  /// Number of toasts waiting in the queue (excluding current).
  static int get queueLength => _queue.length;

  // ============================================================================
  // CORE SHOW
  // ============================================================================

  /// Show a toast with complete [TwistToastData] control.
  static void show(BuildContext context, TwistToastData data) {
    _queue.add(_Queued(context, data));
    if (!_isShowing) _next();
  }

  static void _next() {
    if (_queue.isEmpty) { _isShowing = false; return; }
    _isShowing = true;
    final q = _queue.removeFirst();
    _insert(q.context, q.data);
  }

  static void _insert(BuildContext context, TwistToastData data) {
    _safetyTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;

    if (!context.mounted) { _next(); return; }

    if (data.haptic && TwistConfig.instance.defaultHaptic) {
      _haptic(data.type);
    }

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => TwistToastWidget(
        data: data,
        callerContext: context,
        onDismiss: () {
          try { if (entry.mounted) entry.remove(); } catch (_) {}
          if (_currentEntry == entry) _currentEntry = null;
          data.onDismiss?.call();
          Future.delayed(const Duration(milliseconds: 140), _next);
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    // Safety net timer (loading toasts are exempt)
    if (data.type != TwistType.loading) {
      final budget = data.duration.inMilliseconds +
          data.animationDuration.inMilliseconds * 2 + 800;
      _safetyTimer = Timer(Duration(milliseconds: budget), () {
        if (_currentEntry == entry) {
          try { _currentEntry?.remove(); } catch (_) {}
          _currentEntry = null;
          _next();
        }
      });
    }
  }

  static void _haptic(TwistType type) {
    switch (type) {
      case TwistType.success: HapticFeedback.lightImpact();  break;
      case TwistType.error:   HapticFeedback.heavyImpact();  break;
      case TwistType.warning: HapticFeedback.mediumImpact(); break;
      case TwistType.loading: break;
      default:                HapticFeedback.selectionClick(); break;
    }
  }

  // ============================================================================
  // DISMISS CONTROLS
  // ============================================================================

  /// Immediately remove the current toast and start the next queued one.
  static void dismiss() {
    _safetyTimer?.cancel();
    try { _currentEntry?.remove(); } catch (_) {}
    _currentEntry = null;
    _isShowing = false;
    _next();
  }

  /// Dismiss current toast AND clear the entire queue.
  static void clearQueue() {
    _queue.clear();
    dismiss();
  }

  // ============================================================================
  // CONVENIENCE METHODS
  // ============================================================================

  static void success(BuildContext ctx, String msg, {
    String? title,
    TwistDirection? direction,
    TwistAnimationType? animationType,
    TwistStyle? style,
    TwistDismissEffect? dismissEffect,
    Duration? duration,
    Duration? animationDuration,
    TwistAction? action,
    Widget? customIcon,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    bool? showProgress,
    bool? haptic,
    double? maxWidth,
    BorderRadius? borderRadius,
    TwistAnimationBuilder? customAnimationBuilder,
    TwistDismissEffectBuilder? customDismissEffectBuilder,
  }) => show(ctx, _d(msg, title: title, type: TwistType.success,
      direction: direction, animationType: animationType, style: style,
      dismissEffect: dismissEffect, duration: duration,
      animationDuration: animationDuration, action: action,
      customIcon: customIcon, onTap: onTap, onDismiss: onDismiss,
      showProgress: showProgress, haptic: haptic, maxWidth: maxWidth,
      borderRadius: borderRadius,
      customAnimationBuilder: customAnimationBuilder,
      customDismissEffectBuilder: customDismissEffectBuilder));

  static void error(BuildContext ctx, String msg, {
    String? title,
    TwistDirection? direction,
    TwistAnimationType? animationType,
    TwistStyle? style,
    TwistDismissEffect? dismissEffect,
    Duration? duration,
    Duration? animationDuration,
    TwistAction? action,
    Widget? customIcon,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    bool? showProgress,
    bool? haptic,
    double? maxWidth,
    BorderRadius? borderRadius,
    TwistAnimationBuilder? customAnimationBuilder,
    TwistDismissEffectBuilder? customDismissEffectBuilder,
  }) => show(ctx, _d(msg, title: title, type: TwistType.error,
      direction: direction, animationType: animationType, style: style,
      dismissEffect: dismissEffect, duration: duration,
      animationDuration: animationDuration, action: action,
      customIcon: customIcon, onTap: onTap, onDismiss: onDismiss,
      showProgress: showProgress, haptic: haptic, maxWidth: maxWidth,
      borderRadius: borderRadius,
      customAnimationBuilder: customAnimationBuilder,
      customDismissEffectBuilder: customDismissEffectBuilder));

  static void warning(BuildContext ctx, String msg, {
    String? title,
    TwistDirection? direction,
    TwistAnimationType? animationType,
    TwistStyle? style,
    TwistDismissEffect? dismissEffect,
    Duration? duration,
    Duration? animationDuration,
    TwistAction? action,
    Widget? customIcon,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    bool? showProgress,
    bool? haptic,
    double? maxWidth,
    BorderRadius? borderRadius,
    TwistAnimationBuilder? customAnimationBuilder,
    TwistDismissEffectBuilder? customDismissEffectBuilder,
  }) => show(ctx, _d(msg, title: title, type: TwistType.warning,
      direction: direction, animationType: animationType, style: style,
      dismissEffect: dismissEffect, duration: duration,
      animationDuration: animationDuration, action: action,
      customIcon: customIcon, onTap: onTap, onDismiss: onDismiss,
      showProgress: showProgress, haptic: haptic, maxWidth: maxWidth,
      borderRadius: borderRadius,
      customAnimationBuilder: customAnimationBuilder,
      customDismissEffectBuilder: customDismissEffectBuilder));

  static void info(BuildContext ctx, String msg, {
    String? title,
    TwistDirection? direction,
    TwistAnimationType? animationType,
    TwistStyle? style,
    TwistDismissEffect? dismissEffect,
    Duration? duration,
    Duration? animationDuration,
    TwistAction? action,
    Widget? customIcon,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    bool? showProgress,
    bool? haptic,
    double? maxWidth,
    BorderRadius? borderRadius,
    TwistAnimationBuilder? customAnimationBuilder,
    TwistDismissEffectBuilder? customDismissEffectBuilder,
  }) => show(ctx, _d(msg, title: title, type: TwistType.info,
      direction: direction, animationType: animationType, style: style,
      dismissEffect: dismissEffect, duration: duration,
      animationDuration: animationDuration, action: action,
      customIcon: customIcon, onTap: onTap, onDismiss: onDismiss,
      showProgress: showProgress, haptic: haptic, maxWidth: maxWidth,
      borderRadius: borderRadius,
      customAnimationBuilder: customAnimationBuilder,
      customDismissEffectBuilder: customDismissEffectBuilder));

  /// Loading toast — NEVER auto-dismisses. Call [TwistToast.dismiss()] manually.
  static void loading(BuildContext ctx, String msg, {
    String? title,
    TwistDirection? direction,
    TwistAnimationType? animationType,
    TwistStyle? style,
  }) => show(ctx, TwistToastData(
      message: msg,
      title: title ?? 'Loading',
      type: TwistType.loading,
      direction: direction ?? TwistConfig.instance.defaultDirection,
      animationType: animationType ?? TwistConfig.instance.defaultAnimationType,
      style: style ?? TwistConfig.instance.defaultStyle,
      showProgress: false,
      haptic: false,
      dismissEffect: TwistDismissEffect.none,
    ));

  static void custom(BuildContext ctx, String msg, {
    String? title,
    required Color color,
    Widget? icon,
    List<Color>? gradient,
    TwistDirection? direction,
    TwistAnimationType? animationType,
    TwistStyle? style,
    TwistDismissEffect? dismissEffect,
    Duration? duration,
    Duration? animationDuration,
    TwistAction? action,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    bool? showProgress,
    bool? haptic,
    double? maxWidth,
    BorderRadius? borderRadius,
    TwistAnimationBuilder? customAnimationBuilder,
    TwistDismissEffectBuilder? customDismissEffectBuilder,
    TwistWidgetBuilder? customWidgetBuilder,
  }) => show(ctx, TwistToastData(
      message: msg, title: title,
      type: TwistType.custom,
      customColor: color, customIcon: icon, customGradient: gradient,
      direction: direction ?? TwistConfig.instance.defaultDirection,
      animationType: animationType ?? TwistConfig.instance.defaultAnimationType,
      style: style ?? TwistConfig.instance.defaultStyle,
      dismissEffect: dismissEffect ?? TwistConfig.instance.defaultDismissEffect,
      duration: duration ?? TwistConfig.instance.defaultDuration,
      animationDuration: animationDuration ?? TwistConfig.instance.defaultAnimationDuration,
      action: action, onTap: onTap, onDismiss: onDismiss,
      showProgress: showProgress ?? TwistConfig.instance.defaultShowProgress,
      haptic: haptic ?? TwistConfig.instance.defaultHaptic,
      maxWidth: maxWidth, borderRadius: borderRadius,
      customAnimationBuilder: customAnimationBuilder,
      customDismissEffectBuilder: customDismissEffectBuilder,
      customWidgetBuilder: customWidgetBuilder,
    ));

  // ── Internal builder ───────────────────────────────────────────────────────
  static TwistToastData _d(String msg, {
    String? title,
    required TwistType type,
    TwistDirection? direction,
    TwistAnimationType? animationType,
    TwistStyle? style,
    TwistDismissEffect? dismissEffect,
    Duration? duration,
    Duration? animationDuration,
    TwistAction? action,
    Widget? customIcon,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    bool? showProgress,
    bool? haptic,
    double? maxWidth,
    BorderRadius? borderRadius,
    TwistAnimationBuilder? customAnimationBuilder,
    TwistDismissEffectBuilder? customDismissEffectBuilder,
  }) {
    final cfg = TwistConfig.instance;
    return TwistToastData(
      message: msg, title: title, type: type,
      direction: direction ?? cfg.defaultDirection,
      animationType: animationType ?? cfg.defaultAnimationType,
      style: style ?? cfg.defaultStyle,
      dismissEffect: dismissEffect ?? cfg.defaultDismissEffect,
      duration: duration ?? cfg.defaultDuration,
      animationDuration: animationDuration ?? cfg.defaultAnimationDuration,
      action: action, customIcon: customIcon, onTap: onTap, onDismiss: onDismiss,
      showProgress: showProgress ?? cfg.defaultShowProgress,
      haptic: haptic ?? cfg.defaultHaptic,
      maxWidth: maxWidth, borderRadius: borderRadius,
      customAnimationBuilder: customAnimationBuilder,
      customDismissEffectBuilder: customDismissEffectBuilder,
    );
  }
}

class _Queued {
  final BuildContext context;
  final TwistToastData data;
  _Queued(this.context, this.data);
}
