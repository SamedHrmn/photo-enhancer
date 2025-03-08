import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/widgets/app_lottie_player.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/theme/app_theme.dart';
import 'package:photo_enhancer/core/widgets/app_snackbar_manager.dart';
import 'package:photo_enhancer/features/pick-image/viewmodel/pick_image_state.dart';
import 'package:photo_enhancer/features/pick-image/viewmodel/pick_image_view_model.dart';
import 'package:photo_enhancer/features/home/viewmodel/home_view_model.dart';
import 'package:photo_enhancer/features/show-result/view/show_result_view.dart';

class PickImageView extends StatelessWidget {
  const PickImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PickImageViewModel, PickImageViewDataHolder>(
      listenWhen: (previous, current) => (previous.hasError != current.hasError) || (previous.showUnsupportedFileError != current.showUnsupportedFileError),
      listener: (context, state) {
        if (state.hasError) {
          AppSnackbarManager.show(
            content: AppText(
              AppLocalizedKeys.somethingWentWrong,
              color: AppTheme.textColorDark,
            ),
          );
          context.read<PickImageViewModel>().updateState(hasError: false);
        }

        if (state.showUnsupportedFileError) {
          AppSnackbarManager.show(
            content: AppText(
              AppLocalizedKeys.unsupportedFileTypeErrorText,
              color: AppTheme.textColorDark,
            ),
          );
          context.read<PickImageViewModel>().updateState(showUnsupportedFileError: false);
        }
      },
      builder: (context, state) {
        if (state.appPickedImage == null || state.appPickedImage?.bytes == null) {
          return Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final appAction = context.read<HomeViewModel>().state.appAction;

                  await context.read<PickImageViewModel>().pickImage(appAction: appAction);
                },
                child: AppLottiePlayer(
                  path: AppAssetManager.tapToPickLottie,
                ),
              ),
              AppText(AppLocalizedKeys.tapToPickImage),
            ],
          );
        }

        return ShowResultView(
          pickedImage: state.appPickedImage!,
        );
      },
    );
  }
}
