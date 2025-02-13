import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/widgets/app_lottie_player.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/features/colorize-image/pick_image_view_model.dart';
import 'package:photo_enhancer/features/show-result/show_result_view.dart';

class PickImageView extends StatelessWidget {
  const PickImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PickImageViewModel, PickImageViewDataHolder>(
      listenWhen: (previous, current) => previous.hasError != current.hasError,
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: AppText(AppLocalizedKeys.somethingWentWrong),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.appPickedImage == null || state.appPickedImage?.bytes == null) {
          return Column(
            children: [
              GestureDetector(
                onTap: () async {
                  await context.read<PickImageViewModel>().pickImage();
                },
                child: AppLottiePlayer(
                  path: AppAssetManager.tapToPickLottie,
                ),
              ),
              Text("Tap to pick image"),
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
