import 'package:equatable/equatable.dart';

import 'package:photo_enhancer/features/auth/data/get_user_data_response.dart';

class AppUser extends Equatable {
  final String? googleId;
  final String? androidId;
  final int? credit;
  final List<Purchase> purchases;

  const AppUser({
    this.googleId,
    this.androidId,
    this.credit,
    this.purchases = const [],
  });

  bool checkHasDefaultData() => googleId != null && androidId != null && credit != null;

  factory AppUser.fromResponse(GetUserDataResponse response) {
    return AppUser(
        googleId: response.googleId,
        androidId: response.androidId,
        credit: response.credit,
        purchases: response.purchases.isEmpty
            ? []
            : response.purchases
                .map(
                  (e) => Purchase.fromResponse(e),
                )
                .toList());
  }

  @override
  List<Object?> get props => [googleId, androidId, credit, purchases];

  AppUser copyWith({
    String? googleId,
    String? androidId,
    int? credit,
    List<Purchase>? purchases,
  }) {
    return AppUser(
      googleId: googleId ?? this.googleId,
      androidId: androidId ?? this.androidId,
      credit: credit ?? this.credit,
      purchases: purchases ?? this.purchases,
    );
  }
}

class Purchase extends Equatable {
  final String productId;
  final String purchaseToken;
  final int purchaseTime;

  const Purchase({
    required this.productId,
    required this.purchaseToken,
    required this.purchaseTime,
  });

  factory Purchase.fromResponse(ResponsePurchase response) {
    return Purchase(
      productId: response.productId,
      purchaseToken: response.purchaseToken,
      purchaseTime: response.purchaseTime,
    );
  }

  @override
  List<Object?> get props => [productId, purchaseTime, purchaseToken];
}
