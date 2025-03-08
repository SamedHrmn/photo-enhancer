import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/home/viewmodel/home_view_model.dart';
import 'package:photo_enhancer/features/pick-image/viewmodel/pick_image_view_model.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/face-restoration/face_restoration_request.dart';
import 'package:photo_enhancer/features/show-result/show_result_view_model.dart';
import 'package:photo_enhancer/features/show-result/view/show_result_view.dart';

mixin ShowResultViewManager on State<ShowResultView> {
  Future<void> colorizeIt(BuildContext context) async {
    final pickImageViewModel = context.read<PickImageViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final showResultViewModel = context.read<ShowResultViewModel>();

    final request = await pickImageViewModel.createImageRequest(
      authViewModel: authViewModel,
      context.read<HomeViewModel>().state.appAction,
    ) as ColorizeImageRequest?;
    if (request != null) {
      await showResultViewModel.enhanceImage(request, authViewModel);
    } else {
      pickImageViewModel.updateState(hasError: true);
    }
  }

  Future<void> deblurIt(BuildContext context) async {
    final pickImageViewModel = context.read<PickImageViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final showResultViewModel = context.read<ShowResultViewModel>();

    final request = await pickImageViewModel.createImageRequest(
      authViewModel: authViewModel,
      context.read<HomeViewModel>().state.appAction,
    ) as DeblurImageRequest?;
    if (request != null) {
      await showResultViewModel.enhanceImage(request, context.read<AuthViewModel>());
    } else {
      pickImageViewModel.updateState(hasError: true);
    }
  }

  Future<void> faceRestoration(BuildContext context) async {
    final pickImageViewModel = context.read<PickImageViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final showResultViewModel = context.read<ShowResultViewModel>();

    final request = await pickImageViewModel.createImageRequest(
      authViewModel: authViewModel,
      context.read<HomeViewModel>().state.appAction,
    ) as FaceRestorationRequest?;
    if (request != null) {
      await showResultViewModel.enhanceImage(request, authViewModel);
    } else {
      pickImageViewModel.updateState(hasError: true);
    }
  }
}
