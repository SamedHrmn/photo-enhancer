import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLottiePlayer extends StatelessWidget {
  const AppLottiePlayer({
    super.key,
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      path,
    );
  }
}
