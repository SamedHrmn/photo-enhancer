import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_primary_button.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/core/theme/app_theme.dart';
import 'package:photo_enhancer/core/widgets/app_loader_overlay_manager.dart';
import 'package:photo_enhancer/core/widgets/app_snackbar_manager.dart';
import 'package:photo_enhancer/core/widgets/base_statefull_widget.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/paywall/data/photo_coins.dart';
import 'package:photo_enhancer/features/paywall/paywall_view_model.dart';
import 'package:photo_enhancer/locator.dart';

class PaywallView extends StatefulWidget {
  const PaywallView({super.key});

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends BaseStatefullWidget<PaywallView> {
  @override
  Future<void> onInitAsync() async {
    final paywallViewModel = context.read<PaywallViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    await paywallViewModel.checkAvailable();
    if (paywallViewModel.state.isAvailable) {
      await paywallViewModel.getPhotoCoinsPack();

      paywallViewModel.listenPurchases(authViewModel: authViewModel);
    }
    return super.onInitAsync();
  }

  @override
  void onDispose() {
    getIt<AppNavigator>().navigatorKey.currentContext!.read<PaywallViewModel>().clearState();
    super.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQueryData.fromView(View.of(context)).padding.top,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  getIt<AppNavigator>().goBack(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 24,
                ),
              ),
              const Spacer(),
              AppText(AppLocalizedKeys.appName),
              const Spacer(),
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocConsumer<PaywallViewModel, PaywallViewDataHolder>(
              listener: (context, state) {
                if (state.paywallProduct is PaywallProductLoaded || state.paywallProduct is PaywallProductError) {
                  AppLoaderOverlayManager.hideOverlay();
                } else {
                  AppLoaderOverlayManager.showOverlay();
                }

                if (state.purchaseStatus == PurchaseStatus.error) {
                  AppSnackbarManager.show(
                    context: context,
                    content: AppText(
                      AppLocalizedKeys.somethingWentWrong,
                      color: AppTheme.textColorDark,
                    ),
                    variant: AppSnackbarVariant.error,
                  );

                  context.read<PaywallViewModel>().updateState(purchaseStatus: PurchaseStatus.initial);
                } else if (state.purchaseStatus == PurchaseStatus.purchased) {
                  AppSnackbarManager.show(
                    context: context,
                    content: AppText(
                      AppLocalizedKeys.purchasedSuccessfully,
                      color: AppTheme.textColorDark,
                      localizedArg: [state.selectedPack!.productDetails.title],
                    ),
                  );

                  context.read<PaywallViewModel>().updateState(purchaseStatus: PurchaseStatus.initial);
                }
              },
              builder: (context, state) {
                switch (state.paywallProduct) {
                  case null:
                  case PaywallProductInitial():
                  case PaywallProductLoading():
                    return const SizedBox.shrink();
                  case PaywallProductError():
                    return Center(
                      child: AppText(AppLocalizedKeys.somethingWentWrong),
                    );

                  case PaywallProductLoaded(photoCoins: final photoCoins):
                    return Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            height: AppSizer.scaleHeight(400),
                            child: ListView(
                              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                              scrollDirection: Axis.horizontal,
                              children: photoCoins
                                  .map(
                                    (e) => PhotoCoinCarouselItem(
                                      photoCoin: e,
                                      onSelected: (coin) {
                                        context.read<PaywallViewModel>().updateState(selectedPack: coin);
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 16,
                          right: 16,
                          child: BlocBuilder<PaywallViewModel, PaywallViewDataHolder>(
                            builder: (context, state) {
                              if (state.selectedPack == null) {
                                return const SizedBox.shrink();
                              }

                              return AppPrimaryButton(
                                localizedKey: AppLocalizedKeys.goToPurchase,
                                localizedKeyArgs: [state.selectedPack!.productDetails.title],
                                onPressed: () async {
                                  await context.read<PaywallViewModel>().buyPhotoCoinPack();
                                },
                              );
                            },
                          ),
                        )
                      ],
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoCoinCarouselItem extends StatelessWidget {
  const PhotoCoinCarouselItem({
    super.key,
    required this.photoCoin,
    required this.onSelected,
  });

  final PhotoCoins photoCoin;
  final Function(PhotoCoins coin) onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(photoCoin),
      customBorder: RoundedRectangleBorder(borderRadius: AppSizer.borderRadius),
      child: Container(
        width: AppSizer.scaleWidth(280),
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: AppSizer.borderRadius,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.amber,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Expanded(
              child: Image.asset(
                photoCoin.type!.toAssetImage(),
              ),
            ),
            AppText(
              AppLocalizedKeys.photoCoin,
              localizedArg: [
                photoCoin.type!.count.toString(),
              ],
            ),
            AppText(
              null,
              text: photoCoin.productDetails.price,
            ),
            const SizedBox(height: 12)
          ],
        ),
      ),
    );
  }
}
