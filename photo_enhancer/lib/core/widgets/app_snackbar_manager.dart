import 'package:flutter/material.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/locator.dart';

enum AppSnackbarVariant {
  defaultVariant,
  error,
}

class AppSnackbarManager {
  static void show({
    required Widget content,
    AppSnackbarVariant variant = AppSnackbarVariant.defaultVariant,
  }) {
    final globalContext = getIt<AppNavigator>().navigatorKey.currentContext!;
    ScaffoldMessenger.of(globalContext).showSnackBar(
      SnackBar(
        backgroundColor: _getColor(globalContext, variant),
        content: content,
      ),
    );
  }

  static Color _getColor(BuildContext context, AppSnackbarVariant variant) {
    switch (variant) {
      case AppSnackbarVariant.defaultVariant:
        return Theme.of(context).primaryColor;

      case AppSnackbarVariant.error:
        return Theme.of(context).colorScheme.error;
    }
  }
}
