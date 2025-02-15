import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  bool isDarkTheme() => Theme.of(this).brightness == Brightness.dark;
}
