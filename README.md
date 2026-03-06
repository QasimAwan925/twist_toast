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

| success | error | warning | info | loading |
|---|---|---|---|---|
| ![success](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/success.gif) | ![error](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/connection_error.gif) | ![warning](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/low_balance_warning.gif) | ![info](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/driver_update.gif) | ![loading](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/searching.gif) |

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

| topCenter | topLeft | topRight | bottomCenter | bottomLeft | bottomRight | leftCenter | rightCenter | center |
|---|---|---|---|---|---|---|---|---|
| ![topCenter](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/top_center.gif) | ![topLeft](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/top_left.gif) | ![topRight](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/top_right.gif) | ![bottomCenter](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/bottom_center.gif) | ![bottomLeft](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/bottom_left.gif) | ![bottomRight](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/bottom_right.gif) | ![leftCenter](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/left_centre.gif) | ![rightCenter](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/right_center.gif) | ![center](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/center.gif) |

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

| slide | fade | scale | bounce | flip | flipY | rotate | elastic | zoom | ripple | drop | unfold |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ![slide](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/slide.gif) | ![fade](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/fade.gif) | ![scale](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/scale.gif) | ![bounce](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/bounce.gif) | ![flip](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/flip_x.gif) | ![flipY](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/flip_y.gif) | ![rotate](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/rotate.gif) | ![elastic](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/elastic.gif) | ![zoom](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/zoom.gif) | ![ripple](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/ripple.gif) | ![drop](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/drop.gif) | ![unfold](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/unfold.gif) |

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

| none | burst | sparkle | confetti | bubbles | firework | shatter | rippleBurst | hearts |
|---|---|---|---|---|---|---|---|---|
| ![none](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/none_effect.gif) | ![burst](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/burst_effect.gif) | ![sparkle](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/sparkle_effect.gif) | ![confetti](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/confetti_effect.gif) | ![bubbles](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/bubbles_effect.gif) | ![firework](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/firework_effect.gif) | ![shatter](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/shatter_effect.gif) | ![rippleBurst](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/ripple_burst_effect.gif) | ![hearts](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/hearts_effect.gif) |

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

| glass | flat | gradient | outlined | material | minimal | neon | neumorphic | tinted |
|---|---|---|---|---|---|---|---|---|
| ![glass](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/glass_style.gif) | ![flat](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/flat_style.gif) | ![gradient](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/gradient_style.gif) | ![outlined](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/outlined_style.gif) | ![material](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/material_style.gif) | ![minimal](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/minimal_style.gif) | ![neon](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/neon_style.gif) | ![neumorphic](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/neumorphic_style.gif) | ![tinted](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/tinted_style.gif) |

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

![custom_animation](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/custom_animation.gif)

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

![custom_effect](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/custom_effect.gif)

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

![your_driver_arrived](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/your_driver_arrived.gif)

### Queue
```dart
TwistToast.info(context, 'Searching for drivers...');
TwistToast.success(context, 'Driver found!');
TwistToast.info(context, 'Driver is on the way.');
TwistToast.success(context, 'Enjoy your ride!');
```

![4_step](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/4_step.gif)

### Loading
```dart
TwistToast.loading(context, 'Processing payment...');
// When done:
TwistToast.dismiss();
TwistToast.success(context, 'Payment complete!');
```

![booking_confirmed](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/booking_confirmed.gif)

### Programmatic Control
```dart
TwistToast.dismiss();        // dismiss current
TwistToast.clearQueue();     // dismiss + clear all queued
print(TwistToast.isShowing); // bool
print(TwistToast.queueLength); // int
```

![callback_demo](https://raw.githubusercontent.com/QasimAwan925/twist_toast/main/assets/callback_demo.gif)