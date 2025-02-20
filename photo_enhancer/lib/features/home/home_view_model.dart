import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_enhancer/common/helpers/app_permission_manager.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';

import 'package:photo_enhancer/core/widgets/base_data_holder.dart';

enum AppStoragePermissionStatus {
  notRequestedYet,
  requestedAndGranted,
  requestedAndDenied,
  implicitlyGranted,
}

enum AppAction {
  colorizeImage,
  deblurImage;

  const AppAction();

  AppLocalizedKeys tooltipContent() {
    switch (this) {
      case AppAction.colorizeImage:
        return AppLocalizedKeys.tooltipsColorizeImage;
      case AppAction.deblurImage:
        return AppLocalizedKeys.tooltipsDeblurImage;
    }
  }

  AppLocalizedKeys selectionTitle() {
    switch (this) {
      case AppAction.colorizeImage:
        return AppLocalizedKeys.appActionColorizeImage;
      case AppAction.deblurImage:
        return AppLocalizedKeys.appActionDeblurImage;
    }
  }

  Size maxFileSize() {
    switch (this) {
      case AppAction.colorizeImage:
        return Size(1024, 1024);

      case AppAction.deblurImage:
        return Size(360, 360);
    }
  }
}

class HomeViewModel extends Cubit<HomeViewDataHolder> {
  HomeViewModel({required this.appPermissionManager}) : super(const HomeViewDataHolder());

  final AppPermissionManager appPermissionManager;

  void updateState({
    AppStoragePermissionStatus? status,
    AppAction? appAction,
  }) {
    emit(
      state.copyWith(permissionStatus: status, appAction: appAction),
    );
  }

  Future<void> askStoragePermissionIfNeeded() async {
    await appPermissionManager.askStoragePermission(
      onGranted: () async {
        updateState(status: AppStoragePermissionStatus.requestedAndGranted);
      },
      onDenied: () async {
        updateState(status: AppStoragePermissionStatus.requestedAndDenied);
      },
      aboveSdk33: () async {
        updateState(status: AppStoragePermissionStatus.implicitlyGranted);
      },
    );
  }

  Future<void> openAppSettingsForPermission() async {
    await openAppSettings();
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
