import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_lottie_player.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/features/home/viewmodel/home_view_state.dart';

class AppActionSelection extends StatelessWidget {
  const AppActionSelection({
    super.key,
    required this.action,
    required this.onIconTapped,
    required this.value,
    required this.onChanged,
  });

  final VoidCallback onIconTapped;
  final bool value;
  final AppAction action;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: AppSizer.borderRadius,
          ),
          onTap: onIconTapped,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              right: 8.0,
              bottom: 8,
              left: 4,
            ),
            child: Row(
              spacing: 6,
              children: [
                Expanded(
                  child: AppText(
                    action.selectionTitle(),
                    size: AppSizer.scaleWidth(12),
                  ),
                ),
                Row(
                  children: [
                    AppText(
                      null,
                      text: action.creditAmount.toString(),
                    ),
                    AppLottiePlayer(
                      path: AppAssetManager.photoCoinLottie,
                      height: AppSizer.scaleHeight(24),
                      animate: false,
                    ),
                  ],
                ),
                Icon(
                  Icons.info,
                  size: AppSizer.scaleWidth(16),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Switch(
              value: value,
              onChanged: onChanged,
            ),
          ),
        )
      ],
    );
  }
}
