import 'dart:developer';

import 'package:photo_enhancer/common/helpers/app_initializer.dart';
import 'package:photo_enhancer/core/api/dio_api_client.dart';
import 'package:photo_enhancer/core/enums/env_keys.dart';

class ColorizeImageRepository {
  final DioApiClient dioApiClient;

  ColorizeImageRepository({required this.dioApiClient});

  Future<ColorizeImageResponse?> colorizeImage(ColorizeImageRequest request) async {
    try {
      final response = await dioApiClient.post<Map<String, dynamic>>(
        AppInitializer.getStringEnv(EnvKeys.colorizeImageUrl),
        data: request.toJson(),
      );

      return ColorizeImageResponse.fromJson(response);
    } catch (e) {
      log(e.toString(), error: e);
      return null;
    }
  }
}

class ColorizeImageResponse {
  final bool? success;
  final String? imageBase64;
  final String? error;

  const ColorizeImageResponse({
    this.success,
    this.imageBase64,
    this.error,
  });

  factory ColorizeImageResponse.fromJson(Map<String, dynamic>? json) {
    return ColorizeImageResponse(
      success: json?["success"] ?? false,
      error: json?["error"],
      imageBase64: json?["imageBase64"],
    );
  }
}

class ColorizeImageRequest {
  final String imageBase64;

  ColorizeImageRequest({required this.imageBase64});

  Map<String, dynamic> toJson() => {
        "imageBase64": imageBase64,
      };
}
