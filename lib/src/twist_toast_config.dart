// =============================================================================
// twist_toast_config.dart
// =============================================================================
// Global configuration singleton. Call TwistConfig.setup() once in main().
// =============================================================================

import 'package:flutter/material.dart';
import 'twist_toast_types.dart';

/// Global default configuration for TwistToast.
///
/// Call [TwistConfig.setup] once in your [main] function:
/// ```dart
/// void main() {
///   TwistConfig.setup(
///     defaultDirection: TwistDirection.topCenter,
///     defaultStyle: TwistStyle.glass,
///     defaultAnimationType: TwistAnimationType.bounce,
///     defaultDismissEffect: TwistDismissEffect.confetti,
///   );
///   runApp(MyApp());
/// }
/// ```
class TwistConfig {
  static final TwistConfig _instance = TwistConfig._();
  TwistConfig._();
  static TwistConfig get instance => _instance;

  // ── Defaults ───────────────────────────────────────────────────────────────
  TwistDirection defaultDirection = TwistDirection.topCenter;
  TwistAnimationType defaultAnimationType = TwistAnimationType.slide;
  TwistStyle defaultStyle = TwistStyle.glass;
  TwistDismissEffect defaultDismissEffect = TwistDismissEffect.burst;
  Duration defaultDuration = const Duration(seconds: 3);
  Duration defaultAnimationDuration = const Duration(milliseconds: 520);
  bool defaultHaptic = true;
  bool defaultShowProgress = true;

  // ── Layout ─────────────────────────────────────────────────────────────────
  double horizontalPadding = 16;
  double verticalPadding = 12;
  double defaultBorderRadius = 18;
  double maxWidth = 600;

  // ── Colour overrides per type ──────────────────────────────────────────────
  Color? successColor;
  Color? errorColor;
  Color? warningColor;
  Color? infoColor;
  Color? loadingColor;

  // ── API ────────────────────────────────────────────────────────────────────

  /// Apply global defaults. Every parameter is optional.
  static void setup({
    TwistDirection? defaultDirection,
    TwistAnimationType? defaultAnimationType,
    TwistStyle? defaultStyle,
    TwistDismissEffect? defaultDismissEffect,
    Duration? defaultDuration,
    Duration? defaultAnimationDuration,
    bool? defaultHaptic,
    bool? defaultShowProgress,
    double? horizontalPadding,
    double? verticalPadding,
    double? defaultBorderRadius,
    double? maxWidth,
    Color? successColor,
    Color? errorColor,
    Color? warningColor,
    Color? infoColor,
    Color? loadingColor,
  }) {
    final i = _instance;
    if (defaultDirection != null) i.defaultDirection = defaultDirection;
    if (defaultAnimationType != null) i.defaultAnimationType = defaultAnimationType;
    if (defaultStyle != null) i.defaultStyle = defaultStyle;
    if (defaultDismissEffect != null) i.defaultDismissEffect = defaultDismissEffect;
    if (defaultDuration != null) i.defaultDuration = defaultDuration;
    if (defaultAnimationDuration != null) i.defaultAnimationDuration = defaultAnimationDuration;
    if (defaultHaptic != null) i.defaultHaptic = defaultHaptic;
    if (defaultShowProgress != null) i.defaultShowProgress = defaultShowProgress;
    if (horizontalPadding != null) i.horizontalPadding = horizontalPadding;
    if (verticalPadding != null) i.verticalPadding = verticalPadding;
    if (defaultBorderRadius != null) i.defaultBorderRadius = defaultBorderRadius;
    if (maxWidth != null) i.maxWidth = maxWidth;
    if (successColor != null) i.successColor = successColor;
    if (errorColor != null) i.errorColor = errorColor;
    if (warningColor != null) i.warningColor = warningColor;
    if (infoColor != null) i.infoColor = infoColor;
    if (loadingColor != null) i.loadingColor = loadingColor;
  }

  /// Reset all values back to their original defaults.
  static void reset() {
    _instance
      ..defaultDirection = TwistDirection.topCenter
      ..defaultAnimationType = TwistAnimationType.slide
      ..defaultStyle = TwistStyle.glass
      ..defaultDismissEffect = TwistDismissEffect.burst
      ..defaultDuration = const Duration(seconds: 3)
      ..defaultAnimationDuration = const Duration(milliseconds: 520)
      ..defaultHaptic = true
      ..defaultShowProgress = true
      ..horizontalPadding = 16
      ..verticalPadding = 12
      ..defaultBorderRadius = 18
      ..maxWidth = 600
      ..successColor = null
      ..errorColor = null
      ..warningColor = null
      ..infoColor = null
      ..loadingColor = null;
  }
}
