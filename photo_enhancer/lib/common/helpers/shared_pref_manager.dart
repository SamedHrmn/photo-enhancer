import 'dart:convert';

import 'package:photo_enhancer/common/shared/cached_prediction_data.dart';
import 'package:photo_enhancer/core/enums/shared_pref_keys.dart';
import 'package:photo_enhancer/core/widgets/app_logger.dart';
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

  Future<List<String>> getStringList(SharedPrefKeys key) async {
    final response = await _asyncPrefs.getStringList(key.name, _option);
    return response ?? [];
  }

  Future<void> setStringList(SharedPrefKeys key, List<String> list) async {
    await _asyncPrefs.setStringList(key.name, list, _option);
  }

  Future<void> saveCacheImageData({required SharedPrefKeys key, required CachedPredictionData newPrediction, int maxLength = 10}) async {
    // Retrieve existing list
    List<String> storedList = await getStringList(key);
    final copyList = storedList.toList();

    if (storedList.length + 1 >= maxLength) {
      copyList.removeAt(0);
    }

    // Convert new prediction to JSON string and add it
    copyList.add(jsonEncode(newPrediction.toJson()));

    // Save updated list back to SharedPreferences
    AppLogger.logInfo("Old list size: ${storedList.length}, new list size: ${copyList.length}");
    await setStringList(key, copyList);
  }

  Future<List<CachedPredictionData>> getColorizeImageCached() async {
    final list = await getStringList(SharedPrefKeys.colorizeImageCache);
    return list.map((item) => CachedPredictionData.fromJson(jsonDecode(item))).toList();
  }

  Future<List<CachedPredictionData>> getDeblurImageCached() async {
    final list = await getStringList(SharedPrefKeys.deblurImageCache);
    return list.map((item) => CachedPredictionData.fromJson(jsonDecode(item))).toList();
  }

  Future<List<CachedPredictionData>> getFaceRestorationCached() async {
    final list = await getStringList(SharedPrefKeys.faceRestorationCache);
    return list.map((item) => CachedPredictionData.fromJson(jsonDecode(item))).toList();
  }
}
