class UpdateUserCreditRequest {
  final String userId;
  final int amount;

  UpdateUserCreditRequest({required this.userId, required this.amount});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'amount': amount,
    };
  }
}
