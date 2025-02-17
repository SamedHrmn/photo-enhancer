import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:photo_enhancer/common/helpers/app_package_manager.dart';
import 'package:photo_enhancer/core/enums/env_keys.dart';
import 'package:photo_enhancer/features/auth/auth_video_player.dart';
import 'package:photo_enhancer/locator.dart';

class AppInitializer {
  const AppInitializer.__();

  static Future<void> initializeApp() async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: binding);

    await Future.wait([
      EasyLocalization.ensureInitialized(),
      dotenv.load(fileName: kDebugMode ? '.env.development' : '.env.production'),
    ]);

    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    );
    await setupLocator();

    await Future.wait([
      AuthVideoController().initialize(),
      getIt<AppPackageManager>().initialize(),
    ]);
  }

  static String getStringEnv(EnvKeys key) {
    return dotenv.get(key.keyName);
  }

  static Future<String?> getAppCheckToken() async {
    return FirebaseAppCheck.instance.getToken();
  }

  static void hideSplash() {
    FlutterNativeSplash.remove();
  }
}
