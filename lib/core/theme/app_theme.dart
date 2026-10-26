import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import 'colors.dart';

/// Lifted from the appetit design source
/// (`flutter design/appetit/lib/utils/AppTheme.dart`), light and dark both.
///
/// Only two things differ from the original, and neither is a design choice:
/// `CardTheme` is `CardThemeData` on Flutter 3.44, `withOpacity` is
/// `withValues`, and `OpenUpwardsPageTransitionsBuilder` was deleted from the
/// SDK after appetit shipped — `FadeForwardsPageTransitionsBuilder` is the
/// current Material equivalent.
class AppThemeData {
  AppThemeData._();

  /// A filled button is a block of colour, so the design's own blue is used in
  /// both themes — it reads against white and against #262626 alike.
  static FilledButtonThemeData _filledButtons(Color background, Color label) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(backgroundColor: background, foregroundColor: label),
    );
  }

  static ElevatedButtonThemeData _elevatedButtons(Color background, Color label) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: background, foregroundColor: label),
    );
  }

  /// A label on the surface itself, so this one takes the lighter tint in dark
  /// mode — see `appColorPrimaryOnDark`.
  static TextButtonThemeData _textButtons(Color label) {
    return TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: label));
  }

  static OutlinedButtonThemeData _outlinedButtons(Color label) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: label,
        side: BorderSide(color: label.withValues(alpha: 0.6)),
      ),
    );
  }

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: appColorPrimary,
    primaryColorDark: appColorPrimary,
    hoverColor: Colors.white54,
    dividerColor: viewLineColor,
    fontFamily: GoogleFonts.openSans().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: appBottomNavColor,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: appBottomNavColor,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.black),
    cardTheme: const CardThemeData(color: Colors.white),
    cardColor: Colors.white,
    iconTheme: const IconThemeData(color: textPrimaryColor),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: whiteColor),
    textTheme: const TextTheme(
      labelLarge: TextStyle(color: appColorPrimary),
      titleLarge: TextStyle(color: textPrimaryColor),
      titleSmall: TextStyle(color: textSecondaryColor),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: const ColorScheme.light(primary: appColorPrimary).copyWith(error: Colors.red),
    // Stated rather than inherited, so no button depends on what the ambient
    // scheme happens to call "primary". See the dark theme for why.
    filledButtonTheme: _filledButtons(appColorPrimary, Colors.white),
    elevatedButtonTheme: _elevatedButtons(appColorPrimary, Colors.white),
    textButtonTheme: _textButtons(appColorPrimary),
    outlinedButtonTheme: _outlinedButtons(appColorPrimary),
  ).copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
    }),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: appBackgroundColorDark,
    highlightColor: appBackgroundColorDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: appBottomNavColor,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: appBottomNavColor,
      ),
    ),
    primaryColor: color_primary_black,
    dividerColor: const Color(0xFFDADADA).withValues(alpha: 0.3),
    primaryColorDark: color_primary_black,
    textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white),
    hoverColor: Colors.black12,
    fontFamily: GoogleFonts.openSans().fontFamily,
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: appBackgroundColorDark),
    primaryTextTheme: TextTheme(
      titleLarge: primaryTextStyle(color: Colors.white),
      labelSmall: primaryTextStyle(color: Colors.white),
    ),
    cardTheme: const CardThemeData(color: cardBackgroundBlackDark),
    cardColor: appSecondaryBackgroundColor,
    iconTheme: const IconThemeData(color: whiteColor),
    textTheme: const TextTheme(
      labelLarge: TextStyle(color: color_primary_black),
      titleLarge: TextStyle(color: whiteColor),
      titleSmall: TextStyle(color: Colors.white54),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // `primary` was `appBackgroundColorDark` and `onPrimary` was
    // `cardBackgroundBlackDark` — the page colour and the card colour, handed
    // to the scheme as its accent pair. Every button that did not style itself
    // then drew in the colour of the surface behind it: a FilledButton was a
    // #262626 block with #1F1F1F text on a #262626 page, and a TextButton's
    // label was #262626 on #1F1F1F. Present but invisible, which is exactly
    // what the owner reported.
    //
    // The two surface colours stay where they belong — `surface` — and the
    // accent is the design's own blue, lightened only where it has to carry a
    // label. appetit never hit this because every button in it was styled by
    // hand.
    colorScheme: const ColorScheme.dark(
      primary: appColorPrimaryOnDark,
      onPrimary: Colors.black,
      surface: appBackgroundColorDark,
      onSurface: Colors.white,
    ).copyWith(secondary: whiteColor).copyWith(error: const Color(0xFFCF6676)),
    filledButtonTheme: _filledButtons(appColorPrimary, Colors.white),
    elevatedButtonTheme: _elevatedButtons(appColorPrimary, Colors.white),
    textButtonTheme: _textButtons(appColorPrimaryOnDark),
    outlinedButtonTheme: _outlinedButtons(appColorPrimaryOnDark),
  ).copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}
