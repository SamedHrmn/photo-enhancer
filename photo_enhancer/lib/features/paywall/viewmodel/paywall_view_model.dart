import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_initializer.dart';
import 'package:photo_enhancer/common/helpers/iap_manager.dart';
import 'package:photo_enhancer/core/enums/env_keys.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/paywall/data/photo_coins.dart';
import 'package:photo_enhancer/features/paywall/data/photo_coins_repository.dart';
import 'package:photo_enhancer/features/paywall/data/verify_purchase_request.dart';
import 'package:photo_enhancer/features/paywall/viewmodel/paywall_product_state.dart';

class PaywallViewModel extends Cubit<PaywallViewDataHolder> {
  final IAPManager iapManager;
  final PhotoCoinsRepository photoCoinsRepository;

  PaywallViewModel({
    required this.iapManager,
    required this.photoCoinsRepository,
  }) : super(const PaywallViewDataHolder());

  void updateState({
    bool? isAvailable,
    PaywallProductState? paywallProduct,
    PhotoCoins? selectedPack,
    PurchaseStatus? purchaseStatus,
  }) {
    emit(
      state.copyWith(
        isAvailable: isAvailable,
        paywallProduct: paywallProduct,
        selectedPack: selectedPack,
        purchaseStatus: purchaseStatus,
      ),
    );
  }

  void clearState() {
    iapManager.dispose();
    emit(const PaywallViewDataHolder());
  }

  Future<void> checkAvailable() async {
    final isAvailable = await iapManager.checkAvailable();
    updateState(isAvailable: isAvailable);
  }

  void listenPurchases({required AuthViewModel authViewModel}) {
    iapManager.listenPurchases(
      onError: () {
        updateState(purchaseStatus: PurchaseStatus.error);
      },
      onPurchased: (serverSideVerificationData) async {
        final hasVerified = await _verifyPurchase(serverSideVerificationData, authViewModel);
        if (hasVerified) {
          authViewModel.updateUserCredit(state.selectedPack!.type!.count);
        }
      },
    );
  }

  Future<bool> _verifyPurchase(String serverSideVerificationData, AuthViewModel authViewModel) async {
    final response = await photoCoinsRepository.verifyPurchase(
      request: VerifyPurchaseRequest(
        packageName: AppInitializer.getStringEnv(EnvKeys.packageName),
        productId: state.selectedPack!.productDetails.id,
        serverSideVerificationData: serverSideVerificationData,
        creditAmount: state.selectedPack!.type!.count,
        userId: authViewModel.state.appUser.googleId!,
      ),
    );

    if (response.success == true) {
      updateState(purchaseStatus: PurchaseStatus.purchased);
      return true;
    } else {
      updateState(purchaseStatus: PurchaseStatus.error);
      return false;
    }
  }

  Future<void> getPhotoCoinsPack() async {
    updateState(paywallProduct: PaywallProductLoading());

    final response = await iapManager.getProducts(
      products: {
        AppInitializer.getStringEnv(EnvKeys.coinsPack1),
        AppInitializer.getStringEnv(EnvKeys.coinsPack2),
        AppInitializer.getStringEnv(EnvKeys.coinsPack3),
        AppInitializer.getStringEnv(EnvKeys.coinsPack4),
        AppInitializer.getStringEnv(EnvKeys.coinsPack5),
      },
    );

    if (response != null) {
      updateState(paywallProduct: PaywallProductLoaded(photoCoins: response));
    } else {
      updateState(paywallProduct: PaywallProductError());
    }
  }

  Future<void> buyPhotoCoinPack() async {
    if (state.selectedPack == null) return;

    await iapManager.buyProduct(photoCoin: state.selectedPack!);
  }
}
