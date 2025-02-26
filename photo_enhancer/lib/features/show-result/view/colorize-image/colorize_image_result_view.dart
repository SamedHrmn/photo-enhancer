import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/widgets/app_lottie_player.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/core/widgets/app_loader_overlay_manager.dart';
import 'package:photo_enhancer/features/show-result/data/show_result_view_data_holder.dart';
import 'package:photo_enhancer/features/show-result/image_result_error_dialog.dart';
import 'package:photo_enhancer/features/show-result/image_result_sheet.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_result_state.dart';
import 'package:photo_enhancer/features/show-result/show_result_view_model.dart';
import 'package:photo_enhancer/locator.dart';

class ColorizeImageResultView extends StatefulWidget {
  const ColorizeImageResultView({
    super.key,
    required this.onErrorTryAgain,
    required this.child,
  });

  final AsyncCallback onErrorTryAgain;
  final Widget child;

  @override
  State<ColorizeImageResultView> createState() => _ColorizeImageResultViewState();
}

class _ColorizeImageResultViewState extends State<ColorizeImageResultView> {
  bool errorDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShowResultViewModel, ShowResultViewDataHolder>(
      listenWhen: (previous, current) => previous.colorizedImageResultState != current.colorizedImageResultState,
      listener: (context, state) {
        switch (state.colorizedImageResultState) {
          case null:
          case ColorizeImageOnInitial():
            break;
          case ColorizedImageOnLoading():
            AppLoaderOverlayManager.showOverlay(
              widget: AppLottiePlayer(path: AppAssetManager.loadingLottie),
            );
            break;
          case ColorizedImageOnError(error: _):
            if (errorDialogOpen) {
              getIt<AppNavigator>().goBack(context);
            }

            errorDialogOpen = true;
            AppLoaderOverlayManager.hideOverlay();

            showDialog(
              context: context,
              builder: (context) => ImageResultErrorDialog(
                onTryAgain: () async {
                  getIt<AppNavigator>().goBack(context);
                  await widget.onErrorTryAgain();
                },
                onCancel: () {
                  getIt<AppNavigator>().goBack(context);
                },
              ),
            ).then((_) {
              errorDialogOpen = false;
              context.read<ShowResultViewModel>().updateState(colorizedImageState: ColorizeImageOnInitial());
            });

            break;
          case ColorizedImageOnLoaded(result: final result):
            AppLoaderOverlayManager.hideOverlay();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: false,
              enableDrag: false,
              useSafeArea: true,
              builder: (context) => ImageResultSheet(bytes: result.bytes!),
            );
            break;
        }
      },
      child: widget.child,
    );
  }
}
