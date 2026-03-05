// =============================================================================
// twist_toast_types.dart
// =============================================================================
// All enums, typedefs, and data models for TwistToast.
// Import via the barrel: import 'package:twist_toast/twist_toast.dart'
// =============================================================================

import 'package:flutter/material.dart';

// =============================================================================
// ENTRY / EXIT DIRECTION  (9 values)
// =============================================================================

/// Controls where the toast enters FROM and exits TO.
enum TwistDirection {
  topCenter,    // Slides in from the top, horizontally centred
  topLeft,      // Slides in from the top-left corner
  topRight,     // Slides in from the top-right corner
  bottomCenter, // Slides in from the bottom, horizontally centred
  bottomLeft,   // Slides in from the bottom-left corner
  bottomRight,  // Slides in from the bottom-right corner
  leftCenter,   // Slides in from the left edge, vertically centred
  rightCenter,  // Slides in from the right edge, vertically centred
  center,       // Appears from the centre of the screen
}

// =============================================================================
// ENTRANCE / EXIT ANIMATION TYPE  (22 values)
// Every animation plays in reverse on exit.
// =============================================================================

enum TwistAnimationType {
  // ── Basic ──────────────────────────────────────────────────────────────────
  slide,          // Translates from the entry direction
  fade,           // Pure opacity fade
  scale,          // Elastic scale pop from zero
  zoom,           // Zoom from tiny to full with elastic overshoot

  // ── Physics ────────────────────────────────────────────────────────────────
  bounce,         // Bouncy spring slide from the entry direction
  elastic,        // Elastic overshoot on the slide translation
  drop,           // Drops from above with gravity + bounce landing
  springUp,       // Springs upward from below the card's final position

  // ── 3-D ────────────────────────────────────────────────────────────────────
  flip,           // 3-D flip around the X (horizontal) axis
  flipY,          // 3-D flip around the Y (vertical) axis
  flipDiagonal,   // 3-D flip around a diagonal axis (X + Y combined)
  swing,          // Pendulum swing from top anchor point

  // ── Rotate ────────────────────────────────────────────────────────────────
  rotate,         // Rotates in ~20° while fading and scaling
  rotateFull,     // Full 360° rotation entrance
  spiral,         // Spiral (rotate + zoom) entrance

  // ── Reveal ────────────────────────────────────────────────────────────────
  unfold,         // Reveals the card height from top (like unfolding paper)
  wipeLeft,       // Slides a clip mask from left to right
  wipeRight,      // Slides a clip mask from right to left
  ripple,         // Expands from a circle — material ink ripple feel

  // ── Shake ─────────────────────────────────────────────────────────────────
  shake,          // Quick horizontal shake before settling (draws attention)
  jelly,          // Squash-and-stretch jelly physics
  heartbeat,      // Two rapid scale pulses — like a heartbeat

  // ── Custom ────────────────────────────────────────────────────────────────
  custom,         // Developer provides TwistAnimationBuilder
}

// =============================================================================
// DISMISS PARTICLE EFFECT  (12 values)
// Played when the user MANUALLY taps or swipes to dismiss.
// Auto-timer dismissal skips the effect entirely.
// =============================================================================

enum TwistDismissEffect {
  none,           // No effect — straight exit animation
  burst,          // Ring of coloured dots exploding outward
  sparkle,        // 4-pointed star sparkles radiating from centre
  confetti,       // Gravity-affected coloured squares scatter
  bubbles,        // Translucent bubbles float upward with a glint highlight
  firework,       // Rocket + explosion with coloured dot trails
  shatter,        // Card shatters into triangular shards
  rippleBurst,    // 3 staggered expanding ripple rings from the tap point
  hearts,         // Bezier-curve heart shapes scatter outward
  snow,           // Snowflake particles drift downward
  lightning,      // Electric fork-lightning bolts from tap point
  pixelate,       // Grid of coloured squares scatter (8-bit feel)
  custom,         // Developer provides TwistDismissEffectBuilder
}

// =============================================================================
// CARD VISUAL STYLE  (10 values)
// =============================================================================

enum TwistStyle {
  glass,          // Glassmorphism: dark frosted blur
  flat,           // White card with thick coloured left border
  gradient,       // Animated shimmer gradient background
  outlined,       // Dark bg with glowing coloured border
  material,       // Material 3 elevation card
  minimal,        // Compact pill: icon + one line of text
  neon,           // Dark card with pulsing neon edge glow
  neumorphic,     // Soft-shadow light card
  tinted,         // Frosted coloured tint matching the toast type
  custom,         // Developer provides full TwistWidgetBuilder
}

// =============================================================================
// TOAST TYPE  (6 values)
// =============================================================================

/// Semantic type: drives the default colour, icon, and title label.
enum TwistType {
  success,  // Green checkmark
  error,    // Red cancel
  warning,  // Amber warning
  info,     // Blue info
  loading,  // Purple spinner — never auto-dismisses
  custom,   // Developer provides colour and icon
}

// =============================================================================
// TYPEDEFS — Developer Extension Points
// =============================================================================

/// Custom entrance / exit animation wrapper.
///
/// [animation] goes 0→1 on enter and 1→0 on exit.
/// [child]     is the fully-built toast card widget — wrap it however you like.
///
/// Example — spinning entrance:
/// ```dart
/// customAnimationBuilder: (context, animation, child) {
///   return AnimatedBuilder(
///     animation: animation,
///     builder: (_, c) => Transform.rotate(
///       angle: (1 - animation.value) * 3.14,
///       child: Opacity(opacity: animation.value, child: c),
///     ),
///     child: child,
///   );
/// },
/// ```
typedef TwistAnimationBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

/// Custom dismiss particle effect.
///
/// [color]       : the toast accent colour — use it to tint your particles.
/// [tapPosition] : screen coordinates of the user's tap.
/// [onComplete]  : YOU MUST CALL THIS when your effect finishes, otherwise
///                 the toast card will never exit.
///
/// Return a full-screen widget that plays the effect.
typedef TwistDismissEffectBuilder = Widget Function(
  BuildContext context,
  Color color,
  Offset tapPosition,
  VoidCallback onComplete,
);

/// Custom full-card widget builder.
///
/// [data]    : the [TwistToastData] driving this toast.
/// [dismiss] : call this to close the toast from inside your widget.
///
/// The package still positions, animates, and handles swipe for your widget.
typedef TwistWidgetBuilder = Widget Function(
  BuildContext context,
  TwistToastData data,
  VoidCallback dismiss,
);

// =============================================================================
// ACTION BUTTON
// =============================================================================

/// An optional action button rendered inside the toast card.
///
/// Example:
/// ```dart
/// action: TwistAction(
///   label: 'Top Up',
///   onPressed: () => Navigator.pushNamed(context, '/wallet'),
/// ),
/// ```
class TwistAction {
  /// Label text shown on the button.
  final String label;

  /// Called when the user taps the button.
  final VoidCallback onPressed;

  /// Override the button accent colour (defaults to the toast type colour).
  final Color? color;

  /// Override the button text colour.
  final Color? textColor;

  /// Whether tapping this button also dismisses the toast. Default: [true].
  final bool dismissOnPress;

  const TwistAction({
    required this.label,
    required this.onPressed,
    this.color,
    this.textColor,
    this.dismissOnPress = true,
  });
}

// =============================================================================
// TOAST DATA — Complete specification for one toast
// =============================================================================

/// All configuration for a single toast.
///
/// Pass to [TwistToast.show] for maximum control, or use the convenience
/// methods ([TwistToast.success], [TwistToast.error], etc.) for quick calls.
/// Only [message] is required.
class TwistToastData {
  // ── Content ────────────────────────────────────────────────────────────────
  final String message;
  final String? title;

  // ── Type & Style ───────────────────────────────────────────────────────────
  final TwistType type;
  final TwistStyle style;

  // ── Position ───────────────────────────────────────────────────────────────
  final TwistDirection direction;

  // ── Entrance / Exit Animation ──────────────────────────────────────────────
  final TwistAnimationType animationType;
  final Duration animationDuration;
  final TwistAnimationBuilder? customAnimationBuilder;

  // ── Dismiss Particle Effect ────────────────────────────────────────────────
  final TwistDismissEffect dismissEffect;
  final TwistDismissEffectBuilder? customDismissEffectBuilder;

  // ── Timing ─────────────────────────────────────────────────────────────────
  final Duration duration;

  // ── Content Overrides ──────────────────────────────────────────────────────
  final Widget? customIcon;
  final Color? customColor;
  final List<Color>? customGradient;
  final TwistAction? action;

  // ── Callbacks ──────────────────────────────────────────────────────────────
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  // ── Layout & Behaviour ─────────────────────────────────────────────────────
  final bool showProgress;
  final bool haptic;
  final double? maxWidth;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  // ── Custom Card ────────────────────────────────────────────────────────────
  final TwistWidgetBuilder? customWidgetBuilder;

  const TwistToastData({
    required this.message,
    this.title,
    this.type = TwistType.info,
    this.style = TwistStyle.glass,
    this.direction = TwistDirection.topCenter,
    this.animationType = TwistAnimationType.slide,
    this.animationDuration = const Duration(milliseconds: 520),
    this.customAnimationBuilder,
    this.dismissEffect = TwistDismissEffect.burst,
    this.customDismissEffectBuilder,
    this.duration = const Duration(seconds: 3),
    this.customIcon,
    this.customColor,
    this.customGradient,
    this.action,
    this.onTap,
    this.onDismiss,
    this.showProgress = true,
    this.haptic = true,
    this.maxWidth,
    this.borderRadius,
    this.margin,
    this.customWidgetBuilder,
  });

  /// Returns a new [TwistToastData] with selected fields replaced.
  TwistToastData copyWith({
    String? message,
    String? title,
    TwistType? type,
    TwistStyle? style,
    TwistDirection? direction,
    TwistAnimationType? animationType,
    Duration? animationDuration,
    TwistAnimationBuilder? customAnimationBuilder,
    TwistDismissEffect? dismissEffect,
    TwistDismissEffectBuilder? customDismissEffectBuilder,
    Duration? duration,
    Widget? customIcon,
    Color? customColor,
    List<Color>? customGradient,
    TwistAction? action,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    bool? showProgress,
    bool? haptic,
    double? maxWidth,
    BorderRadius? borderRadius,
    EdgeInsets? margin,
    TwistWidgetBuilder? customWidgetBuilder,
  }) {
    return TwistToastData(
      message: message ?? this.message,
      title: title ?? this.title,
      type: type ?? this.type,
      style: style ?? this.style,
      direction: direction ?? this.direction,
      animationType: animationType ?? this.animationType,
      animationDuration: animationDuration ?? this.animationDuration,
      customAnimationBuilder: customAnimationBuilder ?? this.customAnimationBuilder,
      dismissEffect: dismissEffect ?? this.dismissEffect,
      customDismissEffectBuilder: customDismissEffectBuilder ?? this.customDismissEffectBuilder,
      duration: duration ?? this.duration,
      customIcon: customIcon ?? this.customIcon,
      customColor: customColor ?? this.customColor,
      customGradient: customGradient ?? this.customGradient,
      action: action ?? this.action,
      onTap: onTap ?? this.onTap,
      onDismiss: onDismiss ?? this.onDismiss,
      showProgress: showProgress ?? this.showProgress,
      haptic: haptic ?? this.haptic,
      maxWidth: maxWidth ?? this.maxWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      margin: margin ?? this.margin,
      customWidgetBuilder: customWidgetBuilder ?? this.customWidgetBuilder,
    );
  }
}
