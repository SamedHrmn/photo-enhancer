import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLottiePlayer extends StatefulWidget {
  const AppLottiePlayer({
    super.key,
    required this.path,
    this.durationMultiplier = 1.0,
    this.height,
    this.animate = true,
  });

  final String path;
  final double? height;
  final double durationMultiplier;
  final bool animate;

  @override
  State<AppLottiePlayer> createState() => _AppLottiePlayerState();
}

class _AppLottiePlayerState extends State<AppLottiePlayer> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      controller: controller,
      widget.path,
      height: widget.height,
      animate: widget.animate,
      onLoaded: (composition) {
        if (!widget.animate) return;

        controller
          ..duration = composition.duration * widget.durationMultiplier
          ..repeat();

        setState(() {});
      },
    );
  }
}
