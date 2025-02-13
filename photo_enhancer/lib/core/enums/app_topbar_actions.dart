import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_package_manager.dart';
import 'package:photo_enhancer/common/widgets/app_privacy_policy_sheet.dart';
import 'package:photo_enhancer/common/widgets/delete_account_dialog.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/enums/route_enum.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/core/widgets/app_loader_overlay_manager.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/locator.dart';

enum AppTopBarActions {
  privacyPolicy,
  licences,
  signOut,
  deleteAccount;

  AppLocalizedKeys toLocalizedKey() {
    switch (this) {
      case AppTopBarActions.privacyPolicy:
        return AppLocalizedKeys.actionMenuPrivacyPolicy;

      case AppTopBarActions.licences:
        return AppLocalizedKeys.actionMenuLicences;
      case AppTopBarActions.deleteAccount:
        return AppLocalizedKeys.deleteAccount;
      case AppTopBarActions.signOut:
        return AppLocalizedKeys.signOut;
    }
  }

  AsyncCallback action() {
    switch (this) {
      case AppTopBarActions.privacyPolicy:
        return () async {
          final context = getIt<AppNavigator>().navigatorKey.currentContext!;

          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return const AppPrivacyPolicySheet();
            },
          );
        };

      case AppTopBarActions.licences:
        return () async {
          final appVer = await getIt<AppPackageManager>().getAppVersion();
          final appName = await getIt<AppPackageManager>().getAppName();
          final context = getIt<AppNavigator>().navigatorKey.currentContext!;

          if (!context.mounted) return;

          showLicensePage(
            context: context,
            applicationName: appName,
            applicationVersion: appVer,
          );
        };
      case AppTopBarActions.signOut:
        return () async {
          final context = getIt<AppNavigator>().navigatorKey.currentContext!;
          final isSignedOut = await context.read<AuthViewModel>().signOut();
          if (isSignedOut) {
            getIt<AppNavigator>().navigateToPopBackAll(RouteEnum.initialView);
          }
        };

      case AppTopBarActions.deleteAccount:
        return () async {
          final context = getIt<AppNavigator>().navigatorKey.currentContext!;
          await showDialog(
            context: context,
            builder: (context) => DeleteAccountDialog(
              onConfirm: () async {
                final context = getIt<AppNavigator>().navigatorKey.currentContext!;

                AppLoaderOverlayManager.showOverlay();
                final isDeleted = await context.read<AuthViewModel>().deleteAccount();
                AppLoaderOverlayManager.hideOverlay();

                if (isDeleted) {
                  getIt<AppNavigator>().navigateToPopBackAll(RouteEnum.initialView);
                }
              },
            ),
          );
        };
    }
  }
}
