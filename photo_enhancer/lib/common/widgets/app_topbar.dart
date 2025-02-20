import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_lottie_player.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_state.dart';
import 'package:photo_enhancer/features/paywall/paywall_view.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({required this.title, super.key, this.actions});

  final AppLocalizedKeys title;
  final List<AppTopBarActionButton>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            title,
            size: AppSizer.scaleWidth(20),
          ),
          BlocBuilder<AuthViewModel, AuthViewDataHolder>(
            builder: (context, state) {
              if (state.signInStatus == SignInStatus.success && state.appUser.credit != null) {
                return InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return PaywallView();
                      },
                    );
                  },
                  customBorder: RoundedRectangleBorder(borderRadius: AppSizer.borderRadius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          state.appUser.credit!.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        AppLottiePlayer(
                          height: AppSizer.scaleHeight(kToolbarHeight - 16),
                          path: AppAssetManager.photoCoinLottie,
                          durationMultiplier: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppTopBarActionButton extends StatelessWidget {
  const AppTopBarActionButton({required this.child, this.onPressed, this.onTapDown, super.key});

  final Widget child;
  final VoidCallback? onPressed;
  final void Function(TapDownDetails details)? onTapDown;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: onTapDown,
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: SizedBox.square(
        dimension: kMinInteractiveDimension,
        child: child,
      ),
    );
  }
}
