import 'package:flutter/material.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/locator.dart';

class AppSnackbarManager {
  static void show({required Widget content}) {
    final globalContext = getIt<AppNavigator>().navigatorKey.currentContext!;
    ScaffoldMessenger.of(globalContext).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(globalContext).primaryColor,
        content: content,
      ),
    );
  }
}
