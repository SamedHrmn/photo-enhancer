class VerifyPurchaseRequest {
  final String packageName;
  final String productId;
  final String userId;
  final int creditAmount;
  final String serverSideVerificationData;

  VerifyPurchaseRequest({
    required this.packageName,
    required this.productId,
    required this.serverSideVerificationData,
    required this.userId,
    required this.creditAmount,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'packageName': packageName,
      'productId': productId,
      'purchaseToken': serverSideVerificationData,
      'userId': userId,
      'creditAmount': creditAmount,
    };
  }
}
