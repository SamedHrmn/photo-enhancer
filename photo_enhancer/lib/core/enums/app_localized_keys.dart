import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum AppLocalizedKeys {
  appName,
  somethingWentWrong,
  actionMenuPrivacyPolicy,
  actionMenuLicences,
  deleteAccount,
  signOut,
  discard,
  save,
  openSettings,
  noContinue,
  storagePermissionNeeded,
  continueDiscardDialogTitle,
  continueDiscardDialogContent,
  continueDiscardDialogAction1,
  continueDiscardDialogAction2,
  imageSavedSuccessfullyTo,
  tapToPickImage,
  colorizeIt,
  deblurIt,
  appActionColorizeImage,
  appActionDeblurImage,
  tooltipsColorizeImage,
  tooltipsDeblurImage,
  imageResultDialogErrorText,
  tryAgain,
  cancel,
  imSure,
  accountDeletionTitle,
  accountDeletionWarning,
  signInWithGoogle,
  authPolicyAgreement,
  userDataNotFoundErrorText,
  unsupportedFileTypeErrorText,
  errorVerifyDevice,
  rejectedVerifyDevice,
  photoCoin,
  goToPurchase,
  purchasedSuccessfully,
  okay;

  String toLocalized(BuildContext context, {List<String>? args}) {
    switch (this) {
      case AppLocalizedKeys.appName:
      case AppLocalizedKeys.somethingWentWrong:
      case AppLocalizedKeys.okay:
      case AppLocalizedKeys.discard:
      case AppLocalizedKeys.save:
      case AppLocalizedKeys.openSettings:
      case AppLocalizedKeys.noContinue:
      case AppLocalizedKeys.storagePermissionNeeded:
      case AppLocalizedKeys.imageSavedSuccessfullyTo:
      case AppLocalizedKeys.tapToPickImage:
      case AppLocalizedKeys.colorizeIt:
      case AppLocalizedKeys.deblurIt:
      case AppLocalizedKeys.imageResultDialogErrorText:
      case AppLocalizedKeys.tryAgain:
      case AppLocalizedKeys.cancel:
      case AppLocalizedKeys.imSure:
      case AppLocalizedKeys.accountDeletionTitle:
      case AppLocalizedKeys.accountDeletionWarning:
      case AppLocalizedKeys.signInWithGoogle:
      case AppLocalizedKeys.authPolicyAgreement:
      case AppLocalizedKeys.userDataNotFoundErrorText:
      case AppLocalizedKeys.unsupportedFileTypeErrorText:
      case AppLocalizedKeys.errorVerifyDevice:
      case AppLocalizedKeys.rejectedVerifyDevice:
      case AppLocalizedKeys.photoCoin:
      case AppLocalizedKeys.goToPurchase:
      case AppLocalizedKeys.purchasedSuccessfully:
        return name.tr(context: context, args: args);
      case AppLocalizedKeys.actionMenuPrivacyPolicy:
        return 'actionMenu.privacyPolicy'.tr(context: context, args: args);
      case AppLocalizedKeys.actionMenuLicences:
        return 'actionMenu.licences'.tr(context: context, args: args);
      case AppLocalizedKeys.deleteAccount:
        return 'actionMenu.deleteAccount'.tr(context: context, args: args);
      case AppLocalizedKeys.signOut:
        return 'actionMenu.signOut'.tr(context: context, args: args);
      case AppLocalizedKeys.continueDiscardDialogTitle:
        return 'continueDiscardDialog.title'.tr(context: context, args: args);
      case AppLocalizedKeys.continueDiscardDialogContent:
        return 'continueDiscardDialog.content'.tr(context: context, args: args);
      case AppLocalizedKeys.continueDiscardDialogAction1:
        return 'continueDiscardDialog.action1'.tr(context: context, args: args);
      case AppLocalizedKeys.continueDiscardDialogAction2:
        return 'continueDiscardDialog.action2'.tr(context: context, args: args);
      case AppLocalizedKeys.appActionColorizeImage:
        return 'appAction.colorizeImage'.tr(context: context, args: args);
      case AppLocalizedKeys.appActionDeblurImage:
        return 'appAction.deblurImage'.tr(context: context, args: args);
      case AppLocalizedKeys.tooltipsColorizeImage:
        return 'tooltips.colorizeImage'.tr(context: context, args: args);
      case AppLocalizedKeys.tooltipsDeblurImage:
        return 'tooltips.deblurImage'.tr(context: context, args: args);
    }
  }
}
