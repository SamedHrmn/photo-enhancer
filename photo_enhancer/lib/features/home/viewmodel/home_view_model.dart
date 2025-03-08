import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_enhancer/common/helpers/app_permission_manager.dart';

import 'package:photo_enhancer/features/home/viewmodel/home_view_state.dart';

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
