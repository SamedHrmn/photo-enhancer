import 'package:flutter/services.dart';

final class PhotoEnhancerChannelHelper {
  const PhotoEnhancerChannelHelper._();
  static const MethodChannel _channel = MethodChannel('photoEnhancerChannel');

  static Future<String?> getIntegrityToken({required String gcpId}) async {
    try {
      final String? integrityToken = await _channel.invokeMethod('getIntegrityToken', int.parse(gcpId));
      return integrityToken;
    } on PlatformException catch (e) {
      print("Error getting integrity token: ${e.message}");
      return null;
    }
  }

  static Future<String?> getAndroidId() async {
    try {
      final String androidId = await _channel.invokeMethod('getAndroidId');
      return androidId;
    } on PlatformException catch (e) {
      print("Failed to get Android ID: '${e.message}'.");
      return null;
    }
  }
}
