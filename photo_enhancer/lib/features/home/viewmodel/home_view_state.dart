import 'dart:ui';

import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/widgets/base_data_holder.dart';

enum AppStoragePermissionStatus {
  notRequestedYet,
  requestedAndGranted,
  requestedAndDenied,
  implicitlyGranted,
}

enum AppAction {
  colorizeImage(2),
  faceRestoration(2),
  deblurImage(1);

  final int creditAmount;

  const AppAction(this.creditAmount);

  AppLocalizedKeys tooltipContent() {
    switch (this) {
      case AppAction.colorizeImage:
        return AppLocalizedKeys.tooltipsColorizeImage;
      case AppAction.faceRestoration:
        return AppLocalizedKeys.tooltipsFaceRestoration;
      case AppAction.deblurImage:
        return AppLocalizedKeys.tooltipsDeblurImage;
    }
  }

  AppLocalizedKeys selectionTitle() {
    switch (this) {
      case AppAction.colorizeImage:
        return AppLocalizedKeys.appActionColorizeImage;
      case AppAction.faceRestoration:
        return AppLocalizedKeys.appActionFaceRestoration;
      case AppAction.deblurImage:
        return AppLocalizedKeys.appActionDeblurImage;
    }
  }

  Size maxFileSize() {
    switch (this) {
      case AppAction.colorizeImage:
        return Size(1024, 1024);

      case AppAction.faceRestoration:
        return Size(1024, 1024);

      case AppAction.deblurImage:
        return Size(360, 360);
    }
  }
}

class HomeViewDataHolder extends BaseDataHolder {
  final AppStoragePermissionStatus permissionStatus;
  final AppAction appAction;

  const HomeViewDataHolder({
    this.permissionStatus = AppStoragePermissionStatus.notRequestedYet,
    this.appAction = AppAction.colorizeImage,
  });

  @override
  HomeViewDataHolder copyWith({
    AppStoragePermissionStatus? permissionStatus,
    AppAction? appAction,
  }) {
    return HomeViewDataHolder(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      appAction: appAction ?? this.appAction,
    );
  }

  @override
  List<Object?> get props => [
        permissionStatus,
        appAction,
      ];
}
