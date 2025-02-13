import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

final class AppDeviceManager {
  Future<int> getAndroidSdkInt() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }

  Future<T> platformOperationHandler<T>({
    required Future<T> Function()? belowSDK33,
    required Future<T> Function()? aboveSDK33,
    required Future<T> Function()? onIOS,
    required Future<T> Function()? noneOfThem,
  }) async {
    if (Platform.isAndroid) {
      final sdkInt = await getAndroidSdkInt();
      if (sdkInt < 33) {
        if (belowSDK33 != null) return belowSDK33();
      } else {
        if (aboveSDK33 != null) return aboveSDK33();
      }
    } else if (Platform.isIOS) {
      if (onIOS != null) return onIOS();
    } else {
      if (noneOfThem != null) return noneOfThem();
    }

    throw UnsupportedError('Platform or operation not supported.');
  }
}
