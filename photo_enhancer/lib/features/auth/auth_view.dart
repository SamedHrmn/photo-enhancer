import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_privacy_policy_sheet.dart';
import 'package:photo_enhancer/common/widgets/app_styled_text.dart';
import 'package:photo_enhancer/core/enums/route_enum.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/core/theme/app_theme.dart';
import 'package:photo_enhancer/core/widgets/base_statefull_widget.dart';
import 'package:photo_enhancer/core/widgets/app_loader_overlay_manager.dart';
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
      body: SafeArea(
        child: Padding(
          padding: AppSizer.pageHorizontalPadding,
          child: Column(
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
                  }
                },
                child: ElevatedButton(
                  onPressed: () async {
                    final authViewModel = context.read<AuthViewModel>();

                    await authViewModel.signInWithGoogle();
                    await authViewModel.createUser();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sign In With Google"),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: AppSizer.allPadding(24),
                child: AppStyledText(
                  text: "By logging in you accept the <bold>Privacy Policy.</bold>",
                  colorBuilder: (current) => current.withValues(alpha: 0.4),
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
                        color: AppTheme.textColorLight,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
