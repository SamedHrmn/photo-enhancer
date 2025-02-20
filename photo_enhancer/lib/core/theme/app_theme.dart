import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';

class AppTheme {
  static const textColorLight = Colors.black;
  static const textColorDark = Colors.white;
  static const elevatedButtonNegativeVariantBackgroundLight = Color(0xFFD32F2F);
  static const elevatedButtonNegativeVariantBackgroundDark = Color(0xFFCF6679);

  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white, // Text Color
    backgroundColor: Color(0xFF7B49C2), // Default Button Color
    disabledForegroundColor: Colors.white70, // Disabled Text
    disabledBackgroundColor: Color(0xFFD1C4E9), // Disabled Button Color
    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4, // Adds depth
  );

  static final ButtonStyle darkElevatedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.black,
    backgroundColor: Color(0xFFBB86FC), // Lighter purple for contrast
    disabledForegroundColor: Colors.black54,
    disabledBackgroundColor: Color(0xFF5A2E9C),
    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
  );

  static final lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF7B49C2),
      onPrimary: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: AppAssetManager.interFontFamily,
        fontSize: 16,
        color: textColorLight,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppAssetManager.interFontFamily,
        color: textColorLight,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle),
    scaffoldBackgroundColor: Color(0xFFF8F9FA),
  );

  static final darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFBB86FC),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: darkElevatedButtonStyle),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: AppAssetManager.interFontFamily,
        fontSize: 16,
        color: textColorDark,
        fontWeight: FontWeight.w500,
      ),
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
  );
}
