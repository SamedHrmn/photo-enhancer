import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/locator.dart';

class AppLoaderOverlayManager {
  const AppLoaderOverlayManager();

  static void showOverlay() {
    getIt<AppNavigator>().navigatorKey.currentContext!.loaderOverlay.show();
  }

  static void hideOverlay() {
    getIt<AppNavigator>().navigatorKey.currentContext!.loaderOverlay.hide();
  }
}

class AppLoaderOverlay extends StatelessWidget {
  const AppLoaderOverlay({super.key, this.customIndicator});

  final Widget? customIndicator;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withValues(alpha: 0.5),
        ),
        Center(
          child: customIndicator ?? const CircularProgressIndicator(),
        ),
      ],
    );
  }
}
