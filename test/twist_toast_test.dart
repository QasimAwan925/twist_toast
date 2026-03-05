// =============================================================================
// twist_toast_test.dart
// =============================================================================
// Unit + widget tests for TwistToast.
//
// Run with:  flutter test test/twist_toast_test.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import from src directly so tests work both inside the package
// and when dropped into an app's test folder.
import '../lib/src/twist_toast_types.dart';
import '../lib/src/twist_toast_config.dart';
import '../lib/src/twist_toast_core.dart';
import '../lib/src/twist_toast_widget.dart';
import '../lib/src/twist_toast_particles.dart';

// =============================================================================
// TEST HELPERS
// =============================================================================

/// Wraps a widget in a minimal MaterialApp + Overlay so we can
/// test overlay-based widgets.
Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(builder: (ctx) => child),
    ),
  );
}

/// Pumps a TwistToastWidget into the tree and returns the BuildContext
/// of the inner Builder so we can call TwistToast from it.
Widget _toastHost(WidgetTester tester, TwistToastData data) {
  late BuildContext hostContext;
  return MaterialApp(
    home: Scaffold(
      body: Builder(builder: (ctx) {
        hostContext = ctx;
        return GestureDetector(
          onTap: () => TwistToast.show(hostContext, data),
          child: const Center(child: Text('Tap to show toast')),
        );
      }),
    ),
  );
}

// =============================================================================
// TESTS
// =============================================================================

void main() {

  // Reset config before each test so tests don't bleed into each other
  setUp(() {
    TwistConfig.reset();
    TwistToast.clearQueue();
  });

  // ===========================================================================
  // GROUP: TwistToastData
  // ===========================================================================

  group('TwistToastData', () {

    test('has correct default values', () {
      const data = TwistToastData(message: 'Hello');
      expect(data.message, 'Hello');
      expect(data.type, TwistType.info);
      expect(data.style, TwistStyle.glass);
      expect(data.direction, TwistDirection.topCenter);
      expect(data.animationType, TwistAnimationType.slide);
      expect(data.dismissEffect, TwistDismissEffect.burst);
      expect(data.duration, const Duration(seconds: 3));
      expect(data.animationDuration, const Duration(milliseconds: 520));
      expect(data.showProgress, true);
      expect(data.haptic, true);
      expect(data.title, isNull);
      expect(data.action, isNull);
      expect(data.customColor, isNull);
      expect(data.customGradient, isNull);
      expect(data.customIcon, isNull);
      expect(data.customWidgetBuilder, isNull);
      expect(data.customAnimationBuilder, isNull);
      expect(data.customDismissEffectBuilder, isNull);
    });

    test('copyWith replaces only specified fields', () {
      const original = TwistToastData(
        message: 'Original',
        type: TwistType.info,
        style: TwistStyle.glass,
      );

      final copy = original.copyWith(
        message: 'Updated',
        type: TwistType.success,
      );

      expect(copy.message, 'Updated');
      expect(copy.type, TwistType.success);
      // Unchanged fields keep original values
      expect(copy.style, TwistStyle.glass);
      expect(copy.direction, TwistDirection.topCenter);
      expect(copy.animationType, TwistAnimationType.slide);
    });

    test('copyWith with no arguments returns identical data', () {
      const data = TwistToastData(
        message: 'Test',
        type: TwistType.error,
        style: TwistStyle.neon,
        direction: TwistDirection.bottomRight,
      );

      final copy = data.copyWith();
      expect(copy.message, data.message);
      expect(copy.type, data.type);
      expect(copy.style, data.style);
      expect(copy.direction, data.direction);
    });

    test('all TwistType values are coverable', () {
      for (final type in TwistType.values) {
        final data = TwistToastData(message: 'test', type: type);
        expect(data.type, type);
      }
    });

    test('all TwistStyle values are coverable', () {
      for (final style in TwistStyle.values) {
        final data = TwistToastData(message: 'test', style: style);
        expect(data.style, style);
      }
    });

    test('all TwistDirection values are coverable', () {
      for (final dir in TwistDirection.values) {
        final data = TwistToastData(message: 'test', direction: dir);
        expect(data.direction, dir);
      }
    });

    test('all TwistAnimationType values are coverable', () {
      for (final anim in TwistAnimationType.values) {
        final data = TwistToastData(message: 'test', animationType: anim);
        expect(data.animationType, anim);
      }
    });

    test('all TwistDismissEffect values are coverable', () {
      for (final effect in TwistDismissEffect.values) {
        final data = TwistToastData(message: 'test', dismissEffect: effect);
        expect(data.dismissEffect, effect);
      }
    });
  });

  // ===========================================================================
  // GROUP: TwistAction
  // ===========================================================================

  group('TwistAction', () {

    test('default dismissOnPress is true', () {
      final action = TwistAction(
        label: 'OK',
        onPressed: () {},
      );
      expect(action.dismissOnPress, true);
    });

    test('can set dismissOnPress to false', () {
      final action = TwistAction(
        label: 'Retry',
        onPressed: () {},
        dismissOnPress: false,
      );
      expect(action.dismissOnPress, false);
    });

    test('color and textColor default to null', () {
      final action = TwistAction(label: 'Go', onPressed: () {});
      expect(action.color, isNull);
      expect(action.textColor, isNull);
    });

    test('onPressed is called', () {
      bool called = false;
      final action = TwistAction(
        label: 'Test',
        onPressed: () => called = true,
      );
      action.onPressed();
      expect(called, true);
    });
  });

  // ===========================================================================
  // GROUP: TwistConfig
  // ===========================================================================

  group('TwistConfig', () {

    test('has correct defaults', () {
      expect(TwistConfig.instance.defaultDirection, TwistDirection.topCenter);
      expect(TwistConfig.instance.defaultAnimationType, TwistAnimationType.slide);
      expect(TwistConfig.instance.defaultStyle, TwistStyle.glass);
      expect(TwistConfig.instance.defaultDismissEffect, TwistDismissEffect.burst);
      expect(TwistConfig.instance.defaultDuration, const Duration(seconds: 3));
      expect(TwistConfig.instance.defaultAnimationDuration, const Duration(milliseconds: 520));
      expect(TwistConfig.instance.defaultHaptic, true);
      expect(TwistConfig.instance.defaultShowProgress, true);
      expect(TwistConfig.instance.horizontalPadding, 16);
      expect(TwistConfig.instance.defaultBorderRadius, 18);
      expect(TwistConfig.instance.maxWidth, 600);
    });

    test('setup updates specified fields only', () {
      TwistConfig.setup(
        defaultDirection: TwistDirection.bottomCenter,
        defaultStyle: TwistStyle.neon,
        successColor: const Color(0xFF00FF00),
      );

      expect(TwistConfig.instance.defaultDirection, TwistDirection.bottomCenter);
      expect(TwistConfig.instance.defaultStyle, TwistStyle.neon);
      expect(TwistConfig.instance.successColor, const Color(0xFF00FF00));
      // Unchanged fields stay at default
      expect(TwistConfig.instance.defaultAnimationType, TwistAnimationType.slide);
      expect(TwistConfig.instance.defaultHaptic, true);
    });

    test('reset restores all defaults', () {
      TwistConfig.setup(
        defaultDirection: TwistDirection.leftCenter,
        defaultStyle: TwistStyle.neon,
        defaultHaptic: false,
        successColor: Colors.purple,
      );

      TwistConfig.reset();

      expect(TwistConfig.instance.defaultDirection, TwistDirection.topCenter);
      expect(TwistConfig.instance.defaultStyle, TwistStyle.glass);
      expect(TwistConfig.instance.defaultHaptic, true);
      expect(TwistConfig.instance.successColor, isNull);
    });

    test('setup with no args changes nothing', () {
      TwistConfig.setup(); // No args
      expect(TwistConfig.instance.defaultDirection, TwistDirection.topCenter);
      expect(TwistConfig.instance.defaultStyle, TwistStyle.glass);
    });

    test('multiple setup calls are cumulative', () {
      TwistConfig.setup(defaultStyle: TwistStyle.flat);
      TwistConfig.setup(defaultDirection: TwistDirection.bottomCenter);

      expect(TwistConfig.instance.defaultStyle, TwistStyle.flat);
      expect(TwistConfig.instance.defaultDirection, TwistDirection.bottomCenter);
    });

    test('colour overrides can be set independently', () {
      TwistConfig.setup(
        successColor: Colors.green,
        errorColor: Colors.red,
        warningColor: Colors.orange,
        infoColor: Colors.blue,
        loadingColor: Colors.purple,
      );
      expect(TwistConfig.instance.successColor, Colors.green);
      expect(TwistConfig.instance.errorColor, Colors.red);
      expect(TwistConfig.instance.warningColor, Colors.orange);
      expect(TwistConfig.instance.infoColor, Colors.blue);
      expect(TwistConfig.instance.loadingColor, Colors.purple);
    });
  });

  // ===========================================================================
  // GROUP: TwistToast (queue state)
  // ===========================================================================

  group('TwistToast state', () {

    test('starts not showing', () {
      expect(TwistToast.isShowing, false);
    });

    test('queueLength starts at zero', () {
      expect(TwistToast.queueLength, 0);
    });

    test('clearQueue resets queue', () {
      // Can call clearQueue safely even when nothing is showing
      TwistToast.clearQueue();
      expect(TwistToast.queueLength, 0);
    });

    test('dismiss is safe when nothing is showing', () {
      // Should not throw
      expect(() => TwistToast.dismiss(), returnsNormally);
    });
  });

  // ===========================================================================
  // GROUP: TwistToastWidget — rendering
  // ===========================================================================

  group('TwistToastWidget rendering', () {

    testWidgets('renders success glass toast', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => TwistToast.success(ctx, 'Ride booked!'),
            child: const Text('Show'),
          );
        }),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Ride booked!'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);

      TwistToast.dismiss();
      await tester.pump(); // let the overlay update
    });

    testWidgets('renders error toast', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => TwistToast.error(ctx, 'Payment failed.'),
            child: const Text('Show'),
          );
        }),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Payment failed.'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);

      TwistToast.dismiss();
      await tester.pump();
    });

    testWidgets('renders warning toast', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => TwistToast.warning(ctx, 'Low balance.'),
            child: const Text('Show'),
          );
        }),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Low balance.'), findsOneWidget);

      TwistToast.dismiss();
      await tester.pump();
    });

    testWidgets('renders info toast', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => TwistToast.info(ctx, 'Driver is near.'),
            child: const Text('Show'),
          );
        }),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Driver is near.'), findsOneWidget);

      TwistToast.dismiss();
      await tester.pump();
    });

    testWidgets('renders custom title', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => TwistToast.success(
                ctx, 'Booked!', title: 'Booking Confirmed'),
            child: const Text('Show'),
          );
        }),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Booking Confirmed'), findsOneWidget);
      expect(find.text('Booked!'), findsOneWidget);

      TwistToast.dismiss();
      await tester.pump();
    });

    testWidgets('renders action button', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => TwistToast.warning(
              ctx,
              'Low balance.',
              action: TwistAction(
                label: 'Top Up',
                onPressed: () {},
              ),
            ),
            child: const Text('Show'),
          );
        }),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Top Up'), findsOneWidget);

      TwistToast.dismiss();
      await tester.pump();
    });

    testWidgets('action button callback fires', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => TwistToast.warning(
              ctx,
              'Low balance.',
              action: TwistAction(
                label: 'Top Up',
                onPressed: () => pressed = true,
                dismissOnPress: false,
              ),
            ),
            child: const Text('Show'),
          );
        }),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Top Up'));
      await tester.pump();

      expect(pressed, true);

      TwistToast.dismiss();
      await tester.pump();
    });

    testWidgets('renders loading toast without close button', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => TwistToast.loading(ctx, 'Finding driver...'),
            child: const Text('Show'),
          );
        }),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Finding driver...'), findsOneWidget);
      // Loading toasts don't have a close icon
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      TwistToast.dismiss();
      await tester.pump();
    });

    testWidgets('renders all card styles without throwing', (tester) async {
      for (final style in TwistStyle.values) {
        if (style == TwistStyle.custom) continue; // requires customWidgetBuilder

        await tester.pumpWidget(_wrap(
          Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () => TwistToast.success(ctx, 'Style test', style: style),
              child: Text('Show $style'),
            );
          }),
        ));

        await tester.tap(find.text('Show $style'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Style test'), findsOneWidget,
            reason: 'Style $style did not render');

        TwistToast.dismiss();
        await tester.pump();
      }
    });

    testWidgets('renders all animation types without throwing', (tester) async {
      for (final anim in TwistAnimationType.values) {
        if (anim == TwistAnimationType.custom) continue;

        await tester.pumpWidget(_wrap(
          Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () => TwistToast.success(
                  ctx, 'Anim test', animationType: anim),
              child: Text('Show $anim'),
            );
          }),
        ));

        await tester.tap(find.text('Show $anim'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text('Anim test'), findsOneWidget,
            reason: 'Animation $anim did not render');

        TwistToast.dismiss();
        await tester.pump();
      }
    });

    testWidgets('renders all directions without throwing', (tester) async {
      for (final dir in TwistDirection.values) {
        await tester.pumpWidget(_wrap(
          Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () => TwistToast.info(ctx, 'Dir test', direction: dir),
              child: Text('Show $dir'),
            );
          }),
        ));

        await tester.tap(find.text('Show $dir'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text('Dir test'), findsOneWidget,
            reason: 'Direction $dir did not render');

        TwistToast.dismiss();
        await tester.pump();
      }
    });

    // FIXED: explicitly dismiss the toast at the end to avoid pending timers
    testWidgets('onDismiss callback fires after auto-dismiss', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => TwistToast.info(
              ctx,
              'Test',
              duration: const Duration(milliseconds: 100),
              onDismiss: () => dismissed = true,
            ),
            child: const Text('Show'),
          );
        }),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100)); // auto-dismiss triggers
      await tester.pump(const Duration(milliseconds: 600)); // exit animation

      expect(dismissed, true);

      // Ensure any remaining timers are cancelled
      TwistToast.dismiss();
      await tester.pump(); // let cleanup happen
    });

    testWidgets('custom widget builder is used when style is custom', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => TwistToast.show(ctx, TwistToastData(
              message: 'custom',
              style: TwistStyle.custom,
              customWidgetBuilder: (_, __, dismiss) => GestureDetector(
                onTap: dismiss,
                child: Container(
                  color: Colors.purple,
                  padding: const EdgeInsets.all(16),
                  child: const Text('MY CUSTOM CARD',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            )),
            child: const Text('Show'),
          );
        }),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('MY CUSTOM CARD'), findsOneWidget);

      TwistToast.dismiss();
      await tester.pump();
    });

    testWidgets('custom animation builder is used', (tester) async {
      bool builderCalled = false;

      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => TwistToast.info(
              ctx,
              'Custom anim',
              animationType: TwistAnimationType.custom,
              customAnimationBuilder: (context, animation, child) {
                builderCalled = true;
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            child: const Text('Show'),
          );
        }),
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(builderCalled, true);

      TwistToast.dismiss();
      await tester.pump();
    });
  });

  // ===========================================================================
  // GROUP: Particle effects
  // ===========================================================================

  group('TwistParticleOverlay', () {

    testWidgets('none effect calls onComplete immediately', (tester) async {
      bool completed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TwistParticleOverlay(
            effect: TwistDismissEffect.none,
            color: Colors.blue,
            tapPosition: const Offset(100, 100),
            onComplete: () => completed = true,
          ),
        ),
      ));

      await tester.pump();
      expect(completed, true);
    });

    testWidgets('burst effect renders without throwing', (tester) async {
      bool completed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              TwistParticleOverlay(
                effect: TwistDismissEffect.burst,
                color: Colors.green,
                tapPosition: const Offset(150, 150),
                onComplete: () => completed = true,
              ),
            ],
          ),
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(); // one extra frame for the callback

      expect(completed, true);
    });

    testWidgets('custom dismiss effect builder is called', (tester) async {
      bool builderCalled = false;
      bool completed = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              TwistParticleOverlay(
                effect: TwistDismissEffect.custom,
                color: Colors.red,
                tapPosition: const Offset(100, 100),
                onComplete: () => completed = true,
                customBuilder: (ctx, color, tap, done) {
                  builderCalled = true;
                  // Immediately signal done for test
                  WidgetsBinding.instance.addPostFrameCallback((_) => done());
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ));

      await tester.pump();
      await tester.pump();

      expect(builderCalled, true);
      expect(completed, true);
    });
  });

  // ===========================================================================
  // GROUP: Enum coverage
  // ===========================================================================

  group('Enum completeness', () {

    test('TwistDirection has 9 values', () {
      expect(TwistDirection.values.length, 9);
    });

    // FIXED: updated to 23 values (actual enum now has 23)
    test('TwistAnimationType has 23 values', () {
      expect(TwistAnimationType.values.length, 23);
    });

    // FIXED: updated to 13 values (actual enum now has 13)
    test('TwistDismissEffect has 13 values', () {
      expect(TwistDismissEffect.values.length, 13);
    });

    test('TwistStyle has 10 values', () {
      expect(TwistStyle.values.length, 10);
    });

    test('TwistType has 6 values', () {
      expect(TwistType.values.length, 6);
    });
  });
}