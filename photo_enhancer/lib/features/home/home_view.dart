import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_scaffold.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/widgets/base_statefull_widget.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_state.dart';
import 'package:photo_enhancer/features/colorize-image/pick_image_view.dart';
import 'package:photo_enhancer/features/home/home_view_model.dart';
import 'package:photo_enhancer/features/home/widget/app_action_selection.dart';
import 'package:photo_enhancer/features/home/widget/app_action_tooltip.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BaseStatefullWidget<HomeView> {
  @override
  Future<void> onInitAsync() async {
    await context.read<HomeViewModel>().askStoragePermissionIfNeeded();
    return super.onInitAsync();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBarTitle: AppLocalizedKeys.appName,
      child: BlocBuilder<AuthViewModel, AuthViewDataHolder>(
        builder: (context, state) {
          if (state.appUser.checkHasDefaultData()) {
            return Column(
              children: [
                Expanded(
                  child: PickImageView(),
                ),
                AppActionSelectionBuilder(),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class AppActionSelectionBuilder extends StatefulWidget {
  const AppActionSelectionBuilder({super.key});

  @override
  State<AppActionSelectionBuilder> createState() => _AppActionSelectionBuilderState();
}

class _AppActionSelectionBuilderState extends State<AppActionSelectionBuilder> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewModel, HomeViewDataHolder>(
      buildWhen: (previous, current) => previous.appAction != current.appAction,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            spacing: 12,
            children: AppAction.values.map(
              (e) {
                final GlobalKey parentKey = GlobalKey();

                return Expanded(
                  child: AppActionSelection(
                    key: parentKey,
                    title: e.selectionTitle(),
                    onIconTapped: () {
                      AppActionTooltip.showTooltip(
                        context,
                        parentKey: parentKey,
                        rightPadding: e == AppAction.deblurImage ? AppSizer.scaleWidth(72) : 0,
                        bottomPadding: e == AppAction.deblurImage ? AppSizer.scaleHeight(64) : AppSizer.scaleHeight(16),
                        content: e.tooltipContent(),
                      );
                    },
                    value: state.appAction == e,
                    onChanged: (value) {
                      if (value) {
                        context.read<HomeViewModel>().updateState(appAction: e);
                      }
                    },
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}
