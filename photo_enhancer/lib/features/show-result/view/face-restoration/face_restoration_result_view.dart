import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/widgets/app_lottie_player.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/core/widgets/app_loader_overlay_manager.dart';
import 'package:photo_enhancer/features/show-result/data/face-restoration/face_restoration_result_state.dart';
import 'package:photo_enhancer/features/show-result/data/show_result_view_data_holder.dart';
import 'package:photo_enhancer/features/show-result/show_result_view_model.dart';
import 'package:photo_enhancer/features/show-result/widget/image_result_error_dialog.dart';
import 'package:photo_enhancer/features/show-result/widget/image_result_sheet.dart';
import 'package:photo_enhancer/locator.dart';

class FaceRestorationResultView extends StatelessWidget {
  const FaceRestorationResultView({
    super.key,
    required this.onErrorTryAgain,
    required this.child,
  });

  final AsyncCallback onErrorTryAgain;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShowResultViewModel, ShowResultViewDataHolder>(
      listener: (context, state) {
        switch (state.faceRestorationResultState) {
          case null:
            break;
          case FaceRestorationOnLoading():
            AppLoaderOverlayManager.showOverlay(
              widget: AppLottiePlayer(path: AppAssetManager.loadingLottie),
            );
            break;
          case FaceRestorationOnError(error: _):
            AppLoaderOverlayManager.hideOverlay();
            showDialog(
              context: context,
              builder: (context) => ImageResultErrorDialog(
                onTryAgain: () async {
                  getIt<AppNavigator>().goBack(context);
                  await onErrorTryAgain();
                },
                onCancel: () {
                  getIt<AppNavigator>().goBack(context);
                },
              ),
            );
            break;
          case FaceRestorationOnLoaded(result: final result):
            AppLoaderOverlayManager.hideOverlay();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: false,
              enableDrag: false,
              useSafeArea: true,
              builder: (context) => ImageResultSheet(
                bytes: result.bytes!,
              ),
            );
            break;
        }
      },
      child: child,
    );
  }
}
