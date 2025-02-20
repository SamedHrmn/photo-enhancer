import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/widgets/app_primary_button.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/locator.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({
    super.key,
    required this.onConfirm,
  });

  final AsyncCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.warning,
        color: Colors.red,
      ),
      title: AppText(
        AppLocalizedKeys.accountDeletionTitle,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      content: AppText(
        AppLocalizedKeys.accountDeletionWarning,
        textAlign: TextAlign.center,
      ),
      actionsOverflowButtonSpacing: 16,
      actions: [
        AppPrimaryButton(
          variant: AppPrimaryButtonVariant.negativeVariant,
          onPressed: () async {
            await onConfirm();
          },
          localizedKey: AppLocalizedKeys.imSure,
        ),
        AppPrimaryButton(
          onPressed: () {
            getIt<AppNavigator>().goBack(context);
          },
          localizedKey: AppLocalizedKeys.cancel,
        ),
      ],
    );
  }
}
