import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:photo_enhancer/features/paywall/data/photo_coins.dart';

class IAPManager {
  IAPManager() : _inAppPurchase = InAppPurchase.instance;

  late final InAppPurchase _inAppPurchase;
  StreamSubscription<List<PurchaseDetails>>? _purchaseStream;

  Future<bool> checkAvailable() async {
    return _inAppPurchase.isAvailable();
  }

  Future<List<PhotoCoins>?> getProducts({required Set<String> products}) async {
    final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails(products);
    if (products.isEmpty) return null;

    return response.productDetails
        .map(
          (e) => PhotoCoins(type: PhotoCoinTypes.fromId(e.id), productDetails: e),
        )
        .toList();
  }

  Future<bool> buyProduct({required PhotoCoins photoCoin}) async {
    return _inAppPurchase.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: photoCoin.productDetails),
    );
  }

  void dispose() {
    _purchaseStream?.cancel();
    _purchaseStream = null;
  }

  void listenPurchases({
    required void Function() onError,
    required void Function(String serverSideVerificationData) onPurchased,
  }) {
    _purchaseStream = _inAppPurchase.purchaseStream.listen(
      (event) {
        event.forEach(
          (element) async {
            if (element.status == PurchaseStatus.pending) {
              return;
            } else {
              if (element.status == PurchaseStatus.error) {
                onError();
              } else if (element.status == PurchaseStatus.purchased) {
                onPurchased(element.verificationData.serverVerificationData);
              }

              if (element.pendingCompletePurchase) {
                await _inAppPurchase.completePurchase(element);
              }
            }
          },
        );
      },
    );
  }
}
