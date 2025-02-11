class GetUserDataResponse {
  final String googleId;
  final String androidId;
  final int credit;
  final List<ResponsePurchase> purchases;

  GetUserDataResponse({
    required this.googleId,
    required this.androidId,
    required this.credit,
    required this.purchases,
  });

  factory GetUserDataResponse.fromMap(Map<String, dynamic> data) {
    return GetUserDataResponse(
      googleId: data['googleId'] ?? "",
      androidId: data['androidId'] ?? "",
      credit: data['credit'] ?? 0,
      purchases: (data['purchases'] as List<dynamic>?)?.map((purchase) => ResponsePurchase.fromMap(purchase)).toList() ?? [],
    );
  }
}

class ResponsePurchase {
  final String productId;
  final String purchaseToken;
  final int purchaseTime;

  ResponsePurchase({
    required this.productId,
    required this.purchaseToken,
    required this.purchaseTime,
  });

  factory ResponsePurchase.fromMap(Map<String, dynamic> data) {
    return ResponsePurchase(
      productId: data['productId'] ?? "",
      purchaseToken: data['purchaseToken'] ?? "",
      purchaseTime: data['purchaseTime'] ?? 0,
    );
  }
}
