import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';

class AppPackageManager {
  final Completer<PackageInfo> _packageInfo = Completer();

  Future<void> initialize() async {
    _packageInfo.complete(PackageInfo.fromPlatform());
  }

  Future<String> getAppVersion() async {
    final info = await _packageInfo.future;
    return info.version;
  }

  Future<String> getAppName() async {
    final info = await _packageInfo.future;
    return info.appName;
  }
}
