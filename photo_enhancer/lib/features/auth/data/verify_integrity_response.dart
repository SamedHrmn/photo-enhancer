import 'package:flutter/foundation.dart';
import 'package:photo_enhancer/core/widgets/base_data_holder.dart';

class VerifyIntegrityRequest extends BaseDataHolder {
  final String integrityToken;
  final String packageName;

  const VerifyIntegrityRequest({
    required this.integrityToken,
    required this.packageName,
  });

  Map<String, dynamic> toJson() => {
        "integrityToken": integrityToken,
        "packageName": packageName,
        "buildMode": kDebugMode ? 'debug' : 'release',
      };

  @override
  VerifyIntegrityRequest copyWith({
    String? integrityToken,
    String? packageName,
  }) {
    return VerifyIntegrityRequest(
      integrityToken: integrityToken ?? this.integrityToken,
      packageName: packageName ?? this.packageName,
    );
  }

  @override
  List<Object?> get props => [integrityToken, packageName];
}

class VerifyIntegrityResponse extends BaseDataHolder {
  final bool success;
  final String? error;

  const VerifyIntegrityResponse({required this.success, this.error});

  factory VerifyIntegrityResponse.fromJson(Map<Object?, Object?> json) => VerifyIntegrityResponse(
        success: json["success"] as bool,
        error: json["error"] as String?,
      );

  @override
  VerifyIntegrityResponse copyWith({
    bool? success,
    String? error,
  }) {
    return VerifyIntegrityResponse(
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [success, error];
}
