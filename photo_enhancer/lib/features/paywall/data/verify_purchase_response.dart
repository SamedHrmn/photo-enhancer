class VerifyPurchaseResponse {
  final bool? success;
  final Map<String, dynamic>? data;

  VerifyPurchaseResponse({
    this.success,
    this.data,
  });

  factory VerifyPurchaseResponse.fromJson(Map<String, dynamic> map) {
    return VerifyPurchaseResponse(
      success: map['success'] != null ? map['success'] as bool : null,
      data: map['data'] != null ? Map<String, dynamic>.from((map['data'] as Map<String, dynamic>)) : null,
    );
  }
}
