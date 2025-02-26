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
    BuildContext? context,
    AppSnackbarVariant variant = AppSnackbarVariant.defaultVariant,
  }) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: _getColor(context, variant),
        content: content,
      ));
      return;
    }

    final scaffoldState = getIt<AppNavigator>().scaffoldMessengerKey.currentState!;
    scaffoldState.showSnackBar(
      SnackBar(
        backgroundColor: _getColor(scaffoldState.context, variant),
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
