import 'package:dio/dio.dart';

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
    final response = await _dio.post<T>(
      path,
      data: data,
    );
    return response.data;
  }

  Future<T?> fetch<T>(String path, {Object? data}) async {
    final response = await _dio.get<T>(
      path,
      queryParameters: data as Map<String, dynamic>,
    );
    return response.data;
  }
}
