import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum AppLocalizedKeys {
  appName,
  somethingWentWrong,
  actionMenuPrivacyPolicy,
  actionMenuLicences,
  deleteAccount,
  signOut,
  okay;

  String toLocalized(BuildContext context, {List<String>? args}) {
    switch (this) {
      case AppLocalizedKeys.appName:
      case AppLocalizedKeys.somethingWentWrong:
      case AppLocalizedKeys.okay:
        return name.tr(context: context, args: args);
      case AppLocalizedKeys.actionMenuPrivacyPolicy:
        return 'actionMenu.privacyPolicy'.tr(context: context, args: args);
      case AppLocalizedKeys.actionMenuLicences:
        return 'actionMenu.licences'.tr(context: context, args: args);
      case AppLocalizedKeys.deleteAccount:
        return 'actionMenu.deleteAccount'.tr(context: context, args: args);
      case AppLocalizedKeys.signOut:
        return 'actionMenu.signOut'.tr(context: context, args: args);
    }
  }
}
