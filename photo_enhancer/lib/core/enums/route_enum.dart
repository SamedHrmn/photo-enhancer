import 'package:flutter/material.dart';
import 'package:photo_enhancer/core/constants/route_constant.dart';
import 'package:photo_enhancer/features/auth/auth_view.dart';
import 'package:photo_enhancer/features/home/home_view.dart';
import 'package:photo_enhancer/main.dart';

enum RouteEnum {
  initialView(RouteConstant.initialPath),
  authView(RouteConstant.authViewPath),
  homeView(RouteConstant.homeViewPath);

  static RouteEnum fromPath(String path) {
    for (final route in RouteEnum.values) {
      if (route.path == path) return route;
    }
    return RouteEnum.initialView;
  }

  MaterialPageRoute<dynamic> toMaterialRoute(RouteSettings settings) {
    switch (this) {
      case RouteEnum.initialView:
        return MaterialPageRoute(
          builder: (context) => const InitialView(),
          settings: settings,
        );
      case RouteEnum.authView:
        return MaterialPageRoute(
          builder: (context) => const AuthView(),
          settings: settings,
        );
      case RouteEnum.homeView:
        return MaterialPageRoute(
          builder: (context) => const HomeView(),
          settings: settings,
        );
    }
  }

  const RouteEnum(this.path);
  final String path;
}
