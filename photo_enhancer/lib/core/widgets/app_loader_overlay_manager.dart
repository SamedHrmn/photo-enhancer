import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/widgets/app_lottie_player.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/locator.dart';

class AppLoaderOverlayManager {
  const AppLoaderOverlayManager();

  static void showOverlay({Widget? widget}) {
    getIt<AppNavigator>().navigatorKey.currentContext!.loaderOverlay.show();
  }

  static void hideOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AppNavigator>().overlayKey.currentState?.hideOverlay();
    });
  }
}

class AppLoaderOverlay extends StatefulWidget {
  const AppLoaderOverlay({
    this.customIndicator,
    required this.globalKey,
    this.child,
    this.onHidingAnimationComplete,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: globalKey);

  final Widget? customIndicator;
  final GlobalKey<AppLoaderOverlayState> globalKey;
  final VoidCallback? onHidingAnimationComplete;
  final Duration animationDuration;
  final Widget? child;

  @override
  AppLoaderOverlayState createState() => AppLoaderOverlayState();
}

class AppLoaderOverlayState extends State<AppLoaderOverlay> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Define opacity animation for fade-in/fade-out effect
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Fade-in the overlay when it's first shown
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ??
        FadeTransition(
          opacity: _opacityAnimation,
          child: Stack(
            children: [
              Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
              Center(
                child: widget.customIndicator ?? AppLottiePlayer(path: AppAssetManager.loadingLottie),
              ),
            ],
          ),
        );
  }

  Future<void> hideOverlay() async {
    await _controller.reverse();
    widget.onHidingAnimationComplete?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
