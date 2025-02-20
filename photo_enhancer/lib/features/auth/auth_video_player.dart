import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:video_player/video_player.dart';

class AuthVideoPlayer extends StatefulWidget {
  const AuthVideoPlayer({super.key, required this.authVideoController});

  final AuthVideoController authVideoController;

  @override
  State<AuthVideoPlayer> createState() => AuthVideoPlayerState();
}

class AuthVideoPlayerState extends State<AuthVideoPlayer> {
  @override
  void dispose() {
    widget.authVideoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.authVideoController.isInitialized
        ? VideoPlayer(
            widget.authVideoController.controller,
          )
        : const SizedBox.shrink();
  }
}

class AuthVideoController {
  static final AuthVideoController _instance = AuthVideoController._internal();
  factory AuthVideoController() => _instance;

  late final VideoPlayerController controller;
  bool isInitialized = false;

  AuthVideoController._internal();

  Future<void> initialize() async {
    if (!isInitialized) {
      controller = VideoPlayerController.asset(AppAssetManager.loginVideo);
      await controller.initialize();
      controller.setLooping(true);
      controller.play();
      isInitialized = true;
    }
  }

  void dispose() {
    if (isInitialized) {
      controller.dispose();
      isInitialized = false;
    }
  }
}
