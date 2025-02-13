import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/widgets/app_lottie_player.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';

class ColorizedImageResultErrorDialog extends StatelessWidget {
  const ColorizedImageResultErrorDialog({super.key, required this.onTryAgain, required this.onCancel});

  final AsyncCallback onTryAgain;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppText(AppLocalizedKeys.somethingWentWrong),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLottiePlayer(path: AppAssetManager.errorLottie),
          Text(
            "Your credit will only be spent after a successful transaction. Don't worry.",
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () async {
            await onTryAgain();
          },
          child: Text("Try again"),
        ),
        ElevatedButton(
          onPressed: onCancel,
          child: Text("Cancel"),
        ),
      ],
    );
  }
}
