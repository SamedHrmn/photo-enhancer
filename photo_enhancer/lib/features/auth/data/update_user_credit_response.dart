class UpdateUserCreditResponse {
  final int? amount;
  final bool? success;

  UpdateUserCreditResponse({required this.amount, required this.success});

  factory UpdateUserCreditResponse.fromJson(Map<String, dynamic> map) {
    return UpdateUserCreditResponse(
      amount: map['amount'] != null ? map['amount'] as int : null,
      success: map['success'] != null ? map['success'] as bool : null,
    );
  }
}
