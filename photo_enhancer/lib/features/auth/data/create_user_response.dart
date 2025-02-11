import 'package:photo_enhancer/core/widgets/base_data_holder.dart';
import 'package:photo_enhancer/features/auth/data/app_user.dart';
import 'package:photo_enhancer/features/auth/data/get_user_data_response.dart';

class CreateUserResponse {
  final bool success;
  final String? message;
  final ResponseUserData? data;
  final ResponseErrorData? error;

  CreateUserResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null ? ResponseUserData.fromJson(json['data']) : null,
      error: json['error'] != null ? ResponseErrorData.fromJson(json['error']) : null,
    );
  }

  AppUser toAppUser() => AppUser(
        androidId: data?.androidId,
        googleId: data?.googleId,
        credit: data?.credit,
        purchases: data?.responsePurchase.map((e) => Purchase.fromResponse(e)).toList() ?? const [],
      );
}

class ResponseUserData {
  final String? message;
  final String? googleId;
  final String? androidId;
  final int? credit;
  final List<ResponsePurchase> responsePurchase;

  ResponseUserData({
    this.message,
    this.googleId,
    this.androidId,
    this.credit,
    this.responsePurchase = const [],
  });

  factory ResponseUserData.fromJson(Map<String, dynamic> json) {
    return ResponseUserData(
      message: json['message'] as String?,
      googleId: json['googleId'] as String?,
      androidId: json['androidId'] as String?,
      credit: json['credit'] != null ? int.parse(json['credit'].toString()) : null,
      responsePurchase: (json['purchases'] as List<dynamic>?)?.map((purchase) => ResponsePurchase.fromMap(purchase)).toList() ?? const [],
    );
  }
}

class ResponseErrorData {
  final String? code;
  final String? details;

  ResponseErrorData({
    this.code,
    this.details,
  });

  factory ResponseErrorData.fromJson(Map<String, dynamic> json) {
    return ResponseErrorData(
      code: json['code'] as String?,
      details: json['details'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (code != null) 'code': code,
        if (details != null) 'details': details,
      };
}

class CreateUserRequest extends BaseDataHolder {
  final String? googleId;
  final String? androidId;

  const CreateUserRequest({
    this.googleId,
    this.androidId,
  });

  bool checkDataIsNull() => googleId == null || androidId == null;

  Map<String, dynamic> toJson() => {
        "googleId": googleId,
        "androidId": androidId,
      };

  @override
  CreateUserRequest copyWith({
    String? googleId,
    String? androidId,
  }) {
    return CreateUserRequest(
      googleId: googleId ?? this.googleId,
      androidId: androidId ?? this.androidId,
    );
  }

  @override
  List<Object?> get props => [googleId, androidId];
}
