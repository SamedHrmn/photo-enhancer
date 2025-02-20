import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_lottie_player.dart';
import 'package:photo_enhancer/common/widgets/app_primary_button.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';

class ImageResultErrorDialog extends StatelessWidget {
  const ImageResultErrorDialog({super.key, required this.onTryAgain, required this.onCancel});

  final AsyncCallback onTryAgain;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppText(
        AppLocalizedKeys.somethingWentWrong,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: AppSizer.scaleHeight(200),
            child: AppLottiePlayer(path: AppAssetManager.errorLottie),
          ),
          AppText(
            AppLocalizedKeys.imageResultDialogErrorText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: AppPrimaryButton(
            onPressed: () async {
              await onTryAgain();
            },
            localizedKey: AppLocalizedKeys.tryAgain,
          ),
        ),
        AppPrimaryButton(
          onPressed: onCancel,
          variant: AppPrimaryButtonVariant.negativeVariant,
          localizedKey: AppLocalizedKeys.cancel,
        ),
      ],
    );
  }
}
