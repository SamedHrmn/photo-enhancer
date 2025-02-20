import 'package:equatable/equatable.dart';

class ColorizeImageResponse extends Equatable {
  final bool? success;
  final String? imageUrl;
  final String? error;
  final String? cacheBase64;

  const ColorizeImageResponse({
    this.success,
    this.imageUrl,
    this.cacheBase64,
    this.error,
  });

  factory ColorizeImageResponse.fromJson(Map<String, dynamic>? json) {
    return ColorizeImageResponse(
      success: json?["success"] ?? false,
      error: json?["error"],
      imageUrl: json?["imageUrl"],
    );
  }

  Map<String, dynamic> _toJson({String? cacheBas64Log}) {
    return {
      "success": success,
      "imageUrl": imageUrl,
      "error": error,
      "cacheBase64": cacheBas64Log ?? cacheBase64,
    };
  }

  @override
  List<Object?> get props => [
        success,
        imageUrl,
        error,
        cacheBase64,
      ];

  @override
  String toString() {
    return _toJson(
      cacheBas64Log: cacheBase64 != null ? cacheBase64!.substring(0, cacheBase64!.length <= 10 ? cacheBase64!.length : 10) : "",
    ).toString();
  }
}
