import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_enhancer/common/helpers/app_package_manager.dart';
import 'package:photo_enhancer/core/enums/env_keys.dart';
import 'package:photo_enhancer/locator.dart';

class AppInitializer {
  const AppInitializer.__();

  static Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    await dotenv.load(fileName: kDebugMode ? '.env.development' : '.env.production');
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    );
    await setupLocator();

    await getIt<AppPackageManager>().initialize();
  }

  static String getStringEnv(EnvKeys key) {
    return dotenv.get(key.keyName);
  }

  static Future<String?> getAppCheckToken() async {
    return FirebaseAppCheck.instance.getToken();
  }
}
