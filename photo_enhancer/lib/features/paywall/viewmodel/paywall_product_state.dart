import 'package:photo_enhancer/core/widgets/base_data_holder.dart';
import 'package:photo_enhancer/features/paywall/data/photo_coins.dart';

sealed class PaywallProductState {}

class PaywallProductInitial implements PaywallProductState {
  const PaywallProductInitial();
}

class PaywallProductLoading implements PaywallProductState {
  const PaywallProductLoading();
}

class PaywallProductLoaded implements PaywallProductState {
  final List<PhotoCoins> photoCoins;

  PaywallProductLoaded({required this.photoCoins});
}

class PaywallProductError implements PaywallProductState {
  const PaywallProductError();
}

enum PurchaseStatus {
  initial,
  loading,
  purchased,
  error,
}

class PaywallViewDataHolder extends BaseDataHolder {
  const PaywallViewDataHolder({
    this.isAvailable = false,
    this.paywallProduct,
    this.selectedPack,
    this.purchaseStatus = PurchaseStatus.initial,
  });

  final bool isAvailable;
  final PaywallProductState? paywallProduct;
  final PhotoCoins? selectedPack;
  final PurchaseStatus purchaseStatus;

  @override
  PaywallViewDataHolder copyWith({
    bool? isAvailable,
    PaywallProductState? paywallProduct,
    PhotoCoins? selectedPack,
    PurchaseStatus? purchaseStatus,
  }) {
    return PaywallViewDataHolder(
      isAvailable: isAvailable ?? this.isAvailable,
      paywallProduct: paywallProduct ?? this.paywallProduct,
      selectedPack: selectedPack ?? this.selectedPack,
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
    );
  }

  @override
  List<Object?> get props => [
        isAvailable,
        paywallProduct,
        selectedPack,
        purchaseStatus,
      ];
}
