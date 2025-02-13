import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/widgets/app_scaffold.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/widgets/base_statefull_widget.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_state.dart';
import 'package:photo_enhancer/features/colorize-image/pick_image_view.dart';
import 'package:photo_enhancer/features/home/home_view_model.dart';

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
                Text("Your id: ${state.appUser.googleId}"),
                Text("Your credit: ${state.appUser.credit}"),
                Expanded(child: PickImageView()),
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
