import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_primary_button.dart';
import 'package:photo_enhancer/common/widgets/app_privacy_policy_sheet.dart';
import 'package:photo_enhancer/common/widgets/app_styled_text.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/enums/route_enum.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/core/theme/app_theme.dart';
import 'package:photo_enhancer/core/widgets/app_snackbar_manager.dart';
import 'package:photo_enhancer/core/widgets/base_statefull_widget.dart';
import 'package:photo_enhancer/core/widgets/app_loader_overlay_manager.dart';
import 'package:photo_enhancer/features/auth/widget/auth_video_player.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_state.dart';
import 'package:photo_enhancer/locator.dart';
import 'package:styled_text/styled_text.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends BaseStatefullWidget<AuthView> {
  @override
  Future<void> onInitAsync() async {
    final authViewModel = context.read<AuthViewModel>();

    final hasId = await authViewModel.checkUserLoginBefore();
    if (hasId) {
      await authViewModel.signInWithGoogle();
      await authViewModel.createUser();
    }
    return super.onInitAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: videoPlayer(),
          ),
          Positioned.fill(
            child: backgroundGradient(),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: AppSizer.scaleHeight(52),
            child: authSection(context),
          ),
        ],
      ),
    );
  }

  Column authSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocListener<AuthViewModel, AuthViewDataHolder>(
          listenWhen: (previous, current) => (previous.signInStatus != current.signInStatus),
          listener: (context, state) {
            switch (state.signInStatus) {
              case null:
              case SignInStatus.initial:
                AppLoaderOverlayManager.hideOverlay();
                return;
              case SignInStatus.loading:
                AppLoaderOverlayManager.showOverlay();

              case SignInStatus.success:
                AppLoaderOverlayManager.hideOverlay();
                getIt<AppNavigator>().replaceWith(RouteEnum.homeView);
              case SignInStatus.error:
                AppLoaderOverlayManager.hideOverlay();
                AppSnackbarManager.show(
                  content: AppText(AppLocalizedKeys.userDataNotFoundErrorText),
                  variant: AppSnackbarVariant.error,
                );
                context.read<AuthViewModel>().updateState(signInStatus: SignInStatus.initial);
            }
          },
          child: AppPrimaryButton(
            onPressed: () async {
              final authViewModel = context.read<AuthViewModel>();

              await authViewModel.signInWithGoogle();
              await authViewModel.createUser();
            },
            localizedKey: AppLocalizedKeys.signInWithGoogle,
          ),
        ),
        policyStyledText(context),
      ],
    );
  }

  Padding policyStyledText(BuildContext context) {
    return Padding(
      padding: AppSizer.allPadding(24),
      child: AppStyledText(
        localizedKey: AppLocalizedKeys.authPolicyAgreement,
        args: ["<bold>${AppLocalizedKeys.actionMenuPrivacyPolicy.toLocalized(context)}</bold>"],
        colorBuilder: (_) => AppTheme.textColorDark.withValues(alpha: 0.7),
        tags: {
          "bold": StyledTextActionTag(
            (text, attributes) {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return const AppPrivacyPolicySheet();
                },
              );
            },
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColorDark,
              decoration: TextDecoration.underline,
            ),
          ),
        },
      ),
    );
  }

  Container backgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.2),
            Colors.transparent,
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
      ),
    );
  }

  AuthVideoPlayer videoPlayer() {
    return AuthVideoPlayer(
      authVideoController: AuthVideoController(),
    );
  }
}
