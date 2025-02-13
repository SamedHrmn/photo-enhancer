import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_lottie_player.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/core/widgets/app_loader_overlay_manager.dart';
import 'package:photo_enhancer/features/colorize-image/pick_image_view_model.dart';
import 'package:photo_enhancer/features/show-result/colorized_image_result_error_dialog.dart';
import 'package:photo_enhancer/features/show-result/colorized_image_result_sheet.dart';
import 'package:photo_enhancer/features/show-result/show_result_view_model.dart';
import 'package:photo_enhancer/locator.dart';

class ShowResultView extends StatelessWidget {
  const ShowResultView({super.key, required this.pickedImage});

  final AppPickedImage pickedImage;

  Future<void> _colorizeIt(BuildContext context) async {
    final request = context.read<PickImageViewModel>().createColorizeImageRequest();
    if (request != null) {
      await context.read<ShowResultViewModel>().colorizeImage(request);
    } else {
      context.read<PickImageViewModel>().updateState(hasError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShowResultViewModel, ShowResultViewDataHolder>(
      listener: (context, state) {
        switch (state.colorizedImageResultState) {
          case null:
            break;
          case ColorizedImageOnLoading():
            AppLoaderOverlayManager.showOverlay(
              widget: AppLottiePlayer(path: AppAssetManager.loadingLottie),
            );
            break;
          case ColorizedImageOnError(error: _):
            AppLoaderOverlayManager.hideOverlay();
            showDialog(
              context: context,
              builder: (context) => ColorizedImageResultErrorDialog(
                onTryAgain: () async {
                  getIt<AppNavigator>().goBack(context);
                  await _colorizeIt(context);
                },
                onCancel: () {
                  getIt<AppNavigator>().goBack(context);
                },
              ),
            );
            break;
          case ColorizedImageOnLoaded(result: final result):
            AppLoaderOverlayManager.hideOverlay();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: false,
              useSafeArea: true,
              builder: (context) => ColorizedImageResultSheet(result: result),
            );
            break;
        }
      },
      child: Column(
        spacing: AppSizer.scaleHeight(32),
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Image.memory(
                pickedImage.bytes!,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _colorizeIt(context);
            },
            child: Text("Colorize it"),
          ),
          SizedBox(
            height: AppSizer.scaleHeight(32),
          ),
        ],
      ),
    );
  }
}
