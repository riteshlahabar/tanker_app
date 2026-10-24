import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/shared/widgets/sheet_body.dart';

/// A modal bottom sheet sits against the bottom of the window, so two
/// different insets can swallow its last row — and every sheet in the app
/// padded for only one of them.
///
/// `viewInsets.bottom` is the keyboard. `padding.bottom` is the system
/// navigation bar. Before Android 15 an app opted out of edge-to-edge and the
/// system drew that bar on its own ground, so missing it was invisible; from
/// Android 15 the opt-out is gone and the sheet's confirm buttons end up
/// underneath it.
///
/// These assert the arithmetic rather than a screenshot, because the
/// arithmetic is the contract: `padding`, not `viewPadding`, is what makes the
/// two insets safe to add together.
void main() {
  /// The resolved bottom padding SheetBody applies under [data].
  Future<double> bottomInsetOf(WidgetTester tester, MediaQueryData data) async {
    await tester.pumpWidget(
      MediaQuery(
        data: data,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SheetBody(child: SizedBox(height: 40)),
        ),
      ),
    );

    final padding = tester.widget<Padding>(
      find.descendant(of: find.byType(SheetBody), matching: find.byType(Padding)),
    );

    return (padding.padding as EdgeInsets).bottom;
  }

  testWidgets('leaves room for the system navigation bar', (tester) async {
    // A gesture pill or three-button bar, keyboard closed.
    final bottom = await bottomInsetOf(
      tester,
      const MediaQueryData(
        padding: EdgeInsets.only(bottom: 48),
        viewPadding: EdgeInsets.only(bottom: 48),
      ),
    );

    expect(bottom, 16 + 48);
  });

  testWidgets('leaves room for the keyboard', (tester) async {
    // Android zeroes `padding` while the IME covers the navigation bar.
    final bottom = await bottomInsetOf(
      tester,
      const MediaQueryData(
        viewInsets: EdgeInsets.only(bottom: 300),
        viewPadding: EdgeInsets.only(bottom: 48),
      ),
    );

    expect(bottom, 16 + 300);
  });

  testWidgets('does not count the navigation bar twice behind the keyboard', (tester) async {
    // `viewPadding` keeps reporting the bar while the keyboard is open, which
    // is exactly why it must not be the field that is read: 16 + 300 + 48
    // would push the buttons 48px above the keyboard for no reason.
    final bottom = await bottomInsetOf(
      tester,
      const MediaQueryData(
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.only(bottom: 300),
        viewPadding: EdgeInsets.only(bottom: 48),
      ),
    );

    expect(bottom, 16 + 300);
  });

  testWidgets('keeps the design\'s 16px inset when there is nothing to avoid', (tester) async {
    expect(await bottomInsetOf(tester, const MediaQueryData()), 16);
  });
}
