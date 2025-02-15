import 'package:flutter/material.dart';
import 'package:photo_enhancer/core/constants/route_constant.dart';
import 'package:photo_enhancer/core/enums/route_enum.dart';
import 'package:photo_enhancer/core/widgets/app_loader_overlay_manager.dart';

class AppNavigator {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<AppLoaderOverlayState> overlayKey = GlobalKey<AppLoaderOverlayState>();

  // Push a new route onto the stack
  void navigateTo(RouteEnum route, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(
      route.path,
      arguments: arguments,
    );
  }

  void navigateToPopBackAll(RouteEnum route, {Object? arguments}) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route.path,
      (route) => route.settings.name == RouteConstant.initialPath,
      arguments: arguments,
    );
  }

  // Replace the current route with a new one
  void replaceWith(RouteEnum route) {
    navigatorKey.currentState?.pushReplacementNamed(
      route.path,
    );
  }

  // Pop the current route off the stack
  void goBack(BuildContext context) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    }
  }
}
