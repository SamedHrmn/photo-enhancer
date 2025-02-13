import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_enhancer/common/helpers/app_permission_manager.dart';

import 'package:photo_enhancer/core/widgets/base_data_holder.dart';

enum AppStoragePermissionStatus {
  notRequestedYet,
  requestedAndGranted,
  requestedAndDenied,
  implicitlyGranted,
}

class HomeViewModel extends Cubit<HomeViewDataHolder> {
  HomeViewModel({required this.appPermissionManager}) : super(const HomeViewDataHolder());

  final AppPermissionManager appPermissionManager;

  void updateState({AppStoragePermissionStatus? status}) {
    emit(state.copyWith(permissionStatus: status));
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

  const HomeViewDataHolder({
    this.permissionStatus = AppStoragePermissionStatus.notRequestedYet,
  });

  @override
  HomeViewDataHolder copyWith({
    AppStoragePermissionStatus? permissionStatus,
  }) {
    return HomeViewDataHolder(
      permissionStatus: permissionStatus ?? this.permissionStatus,
    );
  }

  @override
  List<Object?> get props => [permissionStatus];
}
