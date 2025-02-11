import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';

class AppTheme {
  static const textColorLight = Colors.black;
  static const textColorDark = Colors.white;

  static final lightTheme = ThemeData.light().copyWith(
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: AppAssetManager.interFontFamily,
        fontSize: 16,
        color: textColorLight,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  static final darkTheme = ThemeData.dark().copyWith(
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: AppAssetManager.interFontFamily,
        fontSize: 16,
        color: textColorDark,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
