import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_enhancer/common/helpers/app_device_manager.dart';
import 'package:photo_enhancer/locator.dart';

final class AppPermissionManager {
  AppPermissionManager({required this.appDeviceManager});
  final AppDeviceManager appDeviceManager;

  Future<void> askStoragePermission({
    AsyncCallback? onGranted,
    AsyncCallback? onDenied,
    AsyncCallback? aboveSdk33,
  }) async {
    if (Platform.isAndroid) {
      final sdkIntAndroid = await appDeviceManager.getAndroidSdkInt();
      if (sdkIntAndroid < 33) {
        final isGranted = await Permission.storage.isGranted;
        if (!isGranted) {
          final status = await Permission.storage.request();
          if (status.isGranted) {
            await onGranted?.call();
          } else {
            await onDenied?.call();
          }
        }
      } else {
        await aboveSdk33?.call();
      }
    }
  }

  Future<bool> storagePermissionIsGrantedBelowSdk33() async {
    if (Platform.isAndroid) {
      final sdkIntAndroid = await getIt<AppDeviceManager>().getAndroidSdkInt();
      if (sdkIntAndroid < 33) {
        return Permission.storage.isGranted;
      }
      return false;
    } else if (Platform.isIOS) {
      return Permission.storage.isGranted;
    }
    return false;
  }
}
