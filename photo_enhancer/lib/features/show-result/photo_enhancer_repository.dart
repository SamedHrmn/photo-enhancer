import 'dart:developer';

import 'package:photo_enhancer/common/helpers/app_file_manager.dart';
import 'package:photo_enhancer/common/helpers/app_initializer.dart';
import 'package:photo_enhancer/common/helpers/shared_pref_manager.dart';
import 'package:photo_enhancer/common/shared/cached_prediction_data.dart';
import 'package:photo_enhancer/core/api/dio_api_client.dart';
import 'package:photo_enhancer/core/enums/env_keys.dart';
import 'package:photo_enhancer/core/enums/shared_pref_keys.dart';
import 'package:photo_enhancer/core/extension/iterable_extensions.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_response.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_response.dart';

class PhotoEnhancerRepository {
  final DioApiClient dioApiClient;
  final SharedPrefManager sharedPrefManager;
  final AppFileManager appFileManager;

  PhotoEnhancerRepository({
    required this.dioApiClient,
    required this.sharedPrefManager,
    required this.appFileManager,
  });

  Future<ColorizeImageResponse?> colorizeImage(ColorizeImageRequest request) async {
    try {
      // Check output has already in cache
      final cachedList = await sharedPrefManager.getColorizeImageCached();

      final cachedElement = cachedList.firstWhereOrNull((element) => element.inputImageBase64 == request.imageBase64);
      if (cachedElement != null) {
        return ColorizeImageResponse(
          success: true,
          cacheBase64: cachedElement.outputImageBase64,
        );
      }

      final response = await dioApiClient.post<Map<String, dynamic>>(
        AppInitializer.getStringEnv(EnvKeys.colorizeImageUrl),
        data: request.toJson(),
      );

      final colorizedImage = ColorizeImageResponse.fromJson(response);
      if (colorizedImage.imageUrl != null) {
        final outputBytes = await appFileManager.loadImageBytesFromImageUrl(colorizedImage.imageUrl!);
        final outputBase64 = appFileManager.encodeBase64FromByte(outputBytes);

        await sharedPrefManager.saveCacheImageData(
          key: SharedPrefKeys.colorizeImageCache,
          newPrediction: CachedPredictionData(
            inputImageBase64: request.imageBase64,
            outputImageBase64: outputBase64,
          ),
        );

        return colorizedImage;
      }

      return null;
    } catch (e) {
      log(e.toString(), error: e);
      return null;
    }
  }

  Future<DeblurImageResponse?> deblurImage(DeblurImageRequest request) async {
    try {
      // Check output has already in cache
      final cachedList = await sharedPrefManager.getDeblurImageCached();

      final cachedElement = cachedList.firstWhereOrNull((element) => element.inputImageBase64 == request.imageBase64);
      if (cachedElement != null) {
        return DeblurImageResponse(
          success: true,
          cacheBase64: cachedElement.outputImageBase64,
        );
      }

      final response = await dioApiClient.post<Map<String, dynamic>>(
        AppInitializer.getStringEnv(EnvKeys.deblurImageUrl),
        data: request.toJson(),
      );

      final debluredImage = DeblurImageResponse.fromJson(response);
      if (debluredImage.imageUrl != null) {
        final outputBytes = await appFileManager.loadImageBytesFromImageUrl(debluredImage.imageUrl!);
        final outputBase64 = appFileManager.encodeBase64FromByte(outputBytes);

        await sharedPrefManager.saveCacheImageData(
          key: SharedPrefKeys.deblurImageCache,
          newPrediction: CachedPredictionData(
            inputImageBase64: request.imageBase64,
            outputImageBase64: outputBase64,
          ),
        );

        return debluredImage;
      }

      return null;
    } catch (e) {
      log(e.toString(), error: e);
      return null;
    }
  }
}
