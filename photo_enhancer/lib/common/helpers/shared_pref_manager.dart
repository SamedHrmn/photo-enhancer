import 'package:photo_enhancer/core/enums/shared_pref_keys.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

class SharedPrefManager {
  SharedPrefManager() {
    _asyncPrefs = SharedPreferencesAsyncAndroid();
  }

  late final SharedPreferencesAsyncAndroid _asyncPrefs;
  final _option = SharedPreferencesAsyncAndroidOptions();

  Future<void> setString(SharedPrefKeys key, String value) async {
    await _asyncPrefs.setString(key.name, value, _option);
  }

  Future<String> getString(SharedPrefKeys key) async {
    final response = await _asyncPrefs.getString(key.name, _option);
    return response ?? "";
  }

  Future<void> setBool(SharedPrefKeys key, bool value) async {
    await _asyncPrefs.setBool(key.name, value, _option);
  }

  Future<bool> getBool(SharedPrefKeys key) async {
    final response = await _asyncPrefs.getBool(key.name, _option);
    return response ?? false;
  }
}
