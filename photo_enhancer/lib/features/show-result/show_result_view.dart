import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_primary_button.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/widgets/app_loader_overlay_manager.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/colorize-image/pick_image_view_model.dart';
import 'package:photo_enhancer/features/home/home_view_model.dart';
import 'package:photo_enhancer/features/paywall/paywall_view.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/show_result_view_data_holder.dart';
import 'package:photo_enhancer/features/show-result/show_result_view_model.dart';
import 'package:photo_enhancer/features/show-result/view/colorize-image/colorize_image_result_view.dart';
import 'package:photo_enhancer/features/show-result/view/deblur-image/deblur_image_result_view.dart';

class ShowResultView extends StatelessWidget {
  const ShowResultView({super.key, required this.pickedImage});

  final AppPickedImage pickedImage;

  Future<void> _colorizeIt(BuildContext context) async {
    final request = await context.read<PickImageViewModel>().createImageRequest(
          authViewModel: context.read<AuthViewModel>(),
          context.read<HomeViewModel>().state.appAction,
        ) as ColorizeImageRequest?;
    if (request != null) {
      await context.read<ShowResultViewModel>().enhanceImage(request, context.read<AuthViewModel>());
    } else {
      context.read<PickImageViewModel>().updateState(hasError: true);
    }
  }

  Future<void> _deblurIt(BuildContext context) async {
    final request = await context.read<PickImageViewModel>().createImageRequest(
          authViewModel: context.read<AuthViewModel>(),
          context.read<HomeViewModel>().state.appAction,
        ) as DeblurImageRequest?;
    if (request != null) {
      await context.read<ShowResultViewModel>().enhanceImage(request, context.read<AuthViewModel>());
    } else {
      context.read<PickImageViewModel>().updateState(hasError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShowResultViewModel, ShowResultViewDataHolder>(
      listenWhen: (previous, current) => previous.shouldGoPurchase != current.shouldGoPurchase,
      listener: (context, state) {
        if (state.shouldGoPurchase) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return PaywallView();
            },
          ).then((_) {
            AppLoaderOverlayManager.hideOverlay();
            context.read<ShowResultViewModel>().updateState(shouldGoPurchase: false);
          });
        }
      },
      child: BlocBuilder<HomeViewModel, HomeViewDataHolder>(
        buildWhen: (previous, current) => previous.appAction != current.appAction,
        builder: (context, state) {
          switch (state.appAction) {
            case AppAction.colorizeImage:
              return ColorizeImageResultView(
                onErrorTryAgain: () async => await _colorizeIt(context),
                child: AppActionsView(
                  pickedImage: pickedImage,
                  actions: {
                    AppAction.colorizeImage: () async => await _colorizeIt(context),
                    AppAction.deblurImage: () async => await _deblurIt(context),
                  },
                ),
              );

            case AppAction.deblurImage:
              return DeblurImageResultView(
                onErrorTryAgain: () async => await _deblurIt(context),
                child: AppActionsView(
                  pickedImage: pickedImage,
                  actions: {
                    AppAction.colorizeImage: () async => await _colorizeIt(context),
                    AppAction.deblurImage: () async => await _deblurIt(context),
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class AppActionsView extends StatelessWidget {
  const AppActionsView({
    super.key,
    required this.pickedImage,
    required this.actions,
  });

  final Map<AppAction, AsyncCallback> actions;
  final AppPickedImage pickedImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSizer.scaleHeight(32),
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final appAction = context.read<HomeViewModel>().state.appAction;

              await context.read<PickImageViewModel>().pickImage(appAction: appAction);
            },
            child: Align(
              alignment: Alignment.center,
              child: Image.memory(
                pickedImage.bytes!,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BlocBuilder<HomeViewModel, HomeViewDataHolder>(
            buildWhen: (previous, current) => previous.appAction != current.appAction,
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: Durations.medium1,
                child: switch (state.appAction) {
                  AppAction.colorizeImage => AppPrimaryButton(
                      key: ValueKey(state.appAction),
                      onPressed: () async {
                        await actions[state.appAction]!();
                      },
                      localizedKey: AppLocalizedKeys.colorizeIt,
                    ),
                  AppAction.deblurImage => AppPrimaryButton(
                      key: ValueKey(state.appAction),
                      localizedKey: AppLocalizedKeys.deblurIt,
                      onPressed: () async {
                        await actions[state.appAction]!();
                      },
                    ),
                },
              );
            },
          ),
        ),
        SizedBox(
          height: AppSizer.scaleHeight(32),
        ),
      ],
    );
  }
}
