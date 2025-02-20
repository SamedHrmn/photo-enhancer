import 'package:dio/dio.dart';
import 'package:photo_enhancer/common/helpers/app_initializer.dart';
import 'package:photo_enhancer/core/enums/env_keys.dart';

final class DioApiClient {
  DioApiClient({
    Dio? dio,
    required this.appCheckToken,
  }) {
    _dio = dio ??= Dio(BaseOptions(
      headers: {"X-Firebase-AppCheck": appCheckToken},
    ));
  }
  late final Dio _dio;
  final String? appCheckToken;

  Future<T?> post<T>(String path, {Object? data}) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        error: e,
        response: e.response,
        message: e.message,
        stackTrace: e.stackTrace,
        type: e.type,
      );
    }
  }

  Future<T?> fetch<T>(String path, {Object? data}) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: data as Map<String, dynamic>,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 && path == AppInitializer.getStringEnv(EnvKeys.getUserDataUrl)) {
        throw UserDataNotFound();
      }
      throw DioException(
        requestOptions: e.requestOptions,
        error: e,
        response: e.response,
        message: e.message,
        stackTrace: e.stackTrace,
        type: e.type,
      );
    }
  }
}

sealed class PhotoEnhancerApiException implements Exception {
  const PhotoEnhancerApiException();
}

class UserDataNotFound extends PhotoEnhancerApiException {}
