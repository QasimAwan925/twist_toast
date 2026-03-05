# twist_toast

A stunning Flutter toast notification package that users love.

**9 directions · 13 animations · 10 card styles · 9 particle dismiss effects**

---

## Features

| Feature | Details |
|---|---|
| Directions | topCenter, topLeft, topRight, bottomCenter, bottomLeft, bottomRight, leftCenter, rightCenter, center |
| Animations | slide, fade, scale, bounce, flip, flipY, rotate, elastic, zoom, ripple, drop, unfold, **custom** |
| Card Styles | glass, flat, gradient, outlined, material, minimal, neon, neumorphic, tinted, **custom** |
| Dismiss Effects | none, burst, sparkle, confetti, bubbles, firework, shatter, rippleBurst, hearts, **custom** |
| Queue | Toasts show one after another — never overlap |
| Loading | Never auto-dismisses — call `TwistToast.dismiss()` manually |
| Action Buttons | With `dismissOnPress` control |
| Haptics | Per toast type |
| Progress Bar | Animated countdown |
| Keyboard-aware | Always sits above the keyboard |
| Swipe to dismiss | Direction-aware |
| Global config | `TwistConfig.setup()` in `main()` |
| Full custom | Animation builder · Dismiss effect builder · Card widget builder |

---

## Installation

```yaml
dependencies:
  twist_toast:
    path: ./twist_toast   # or pub.dev version
```

```dart
import 'package:twist_toast/twist_toast.dart';
```

---

## Quick Start

```dart
TwistToast.success(context, 'Ride booked!');
TwistToast.error(context, 'Payment failed.');
TwistToast.warning(context, 'Low balance.');
TwistToast.info(context, 'Driver is 2 mins away.');
TwistToast.loading(context, 'Finding driver...');
// When done:
TwistToast.dismiss();
```

---

## Global Config (once in main)

```dart
void main() {
  TwistConfig.setup(
    defaultDirection: TwistDirection.topCenter,
    defaultStyle: TwistStyle.glass,
    defaultAnimationType: TwistAnimationType.bounce,
    defaultDismissEffect: TwistDismissEffect.confetti,
    defaultDuration: Duration(seconds: 3),
    successColor: Color(0xFF22C55E),
    errorColor: Color(0xFFEF4444),
  );
  runApp(MyApp());
}
```

---

## All Options

```dart
TwistToast.show(context, TwistToastData(
  message: 'Payment of \$12.50 received.',
  title: 'Payment Success',
  type: TwistType.success,
  style: TwistStyle.gradient,
  direction: TwistDirection.topCenter,
  animationType: TwistAnimationType.bounce,
  animationDuration: Duration(milliseconds: 480),
  dismissEffect: TwistDismissEffect.confetti,
  duration: Duration(seconds: 4),
  showProgress: true,
  haptic: true,
  maxWidth: 400,
  borderRadius: BorderRadius.circular(20),
  action: TwistAction(
    label: 'View Receipt',
    onPressed: () => Navigator.pushNamed(context, '/receipt'),
    dismissOnPress: true,
  ),
  onTap: () => print('tapped'),
  onDismiss: () => print('dismissed'),
));
```

---

## Examples by Feature

### Directions
```dart
TwistToast.success(context, 'Top Left', direction: TwistDirection.topLeft);
TwistToast.info(context, 'Right Side', direction: TwistDirection.rightCenter);
TwistToast.warning(context, 'Bottom Right', direction: TwistDirection.bottomRight);
TwistToast.error(context, 'Center Screen', direction: TwistDirection.center);
```

### Animations
```dart
TwistToast.success(context, 'Bounce!', animationType: TwistAnimationType.bounce);
TwistToast.success(context, 'Flip!', animationType: TwistAnimationType.flip);
TwistToast.success(context, 'Flip Y!', animationType: TwistAnimationType.flipY);
TwistToast.success(context, 'Elastic!', animationType: TwistAnimationType.elastic);
TwistToast.success(context, 'Zoom!', animationType: TwistAnimationType.zoom);
TwistToast.success(context, 'Ripple!', animationType: TwistAnimationType.ripple);
TwistToast.success(context, 'Drop!', animationType: TwistAnimationType.drop);
TwistToast.success(context, 'Unfold!', animationType: TwistAnimationType.unfold);
```

### Dismiss Effects
```dart
TwistToast.success(context, 'Burst!', dismissEffect: TwistDismissEffect.burst);
TwistToast.info(context, 'Sparkle!', dismissEffect: TwistDismissEffect.sparkle);
TwistToast.success(context, 'Confetti!', dismissEffect: TwistDismissEffect.confetti);
TwistToast.info(context, 'Bubbles!', dismissEffect: TwistDismissEffect.bubbles);
TwistToast.error(context, 'Firework!', dismissEffect: TwistDismissEffect.firework);
TwistToast.error(context, 'Shatter!', dismissEffect: TwistDismissEffect.shatter);
TwistToast.info(context, 'Ripple!', dismissEffect: TwistDismissEffect.rippleBurst);
TwistToast.success(context, 'Hearts!', dismissEffect: TwistDismissEffect.hearts);
```

### Card Styles
```dart
TwistToast.success(context, 'Glass', style: TwistStyle.glass);
TwistToast.success(context, 'Flat', style: TwistStyle.flat);
TwistToast.success(context, 'Gradient', style: TwistStyle.gradient);
TwistToast.success(context, 'Outlined', style: TwistStyle.outlined);
TwistToast.success(context, 'Material', style: TwistStyle.material);
TwistToast.success(context, 'Minimal', style: TwistStyle.minimal);
TwistToast.success(context, 'Neon', style: TwistStyle.neon);
TwistToast.success(context, 'Neumorphic', style: TwistStyle.neumorphic);
TwistToast.success(context, 'Tinted', style: TwistStyle.tinted);
```

### Custom Animation
```dart
TwistToast.info(context, 'Spinning entrance!',
  animationType: TwistAnimationType.custom,
  customAnimationBuilder: (context, animation, child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, c) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ((1 - animation.value) * 3.14),
        child: Opacity(opacity: animation.value, child: c),
      ),
      child: child,
    );
  },
);
```

### Custom Dismiss Effect
```dart
TwistToast.success(context, 'Custom particles!',
  dismissEffect: TwistDismissEffect.custom,
  customDismissEffectBuilder: (context, color, tapPosition, onComplete) {
    // Play your own particle widget, then call onComplete()
    return MyParticleWidget(
      color: color,
      origin: tapPosition,
      onDone: onComplete,
    );
  },
);
```

### Custom Card Widget
```dart
TwistToast.custom(context, '',
  color: Colors.purple,
  style: TwistStyle.custom,
  customWidgetBuilder: (context, data, dismiss) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 20)],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_taxi, color: Colors.yellow, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Your driver arrived!',
              style: TextStyle(color: Colors.white, fontSize: 15,
                fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
          ),
          GestureDetector(onTap: dismiss,
            child: const Icon(Icons.close, color: Colors.white54, size: 18)),
        ],
      ),
    );
  },
);
```

### Queue
```dart
TwistToast.info(context, 'Searching for drivers...');
TwistToast.success(context, 'Driver found!');
TwistToast.info(context, 'Driver is on the way.');
TwistToast.success(context, 'Enjoy your ride!');
```

### Loading
```dart
TwistToast.loading(context, 'Processing payment...');
// When done:
TwistToast.dismiss();
TwistToast.success(context, 'Payment complete!');
```

### Programmatic Control
```dart
TwistToast.dismiss();        // dismiss current
TwistToast.clearQueue();     // dismiss + clear all queued
print(TwistToast.isShowing); // bool
print(TwistToast.queueLength); // int
```

---

## Running Tests

```bash
flutter test test/twist_toast_test.dart
```

---

## File Structure

```
lib/
  twist_toast.dart              # Barrel export — import this
  src/
    twist_toast_types.dart      # All enums, typedefs, models
    twist_toast_config.dart     # TwistConfig global singleton
    twist_toast_core.dart       # TwistToast API + queue
    twist_toast_widget.dart     # Card widget + animations
    twist_toast_particles.dart  # All particle dismiss effects
test/
  twist_toast_test.dart         # Full test suite
```
