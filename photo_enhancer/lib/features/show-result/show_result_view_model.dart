import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_file_manager.dart';
import 'package:photo_enhancer/common/helpers/app_permission_manager.dart';
import 'package:photo_enhancer/core/widgets/app_logger.dart';
import 'package:photo_enhancer/features/auth/data/update_user_credit_request.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/home/viewmodel/home_view_model.dart';
import 'package:photo_enhancer/features/home/viewmodel/home_view_state.dart';
import 'package:photo_enhancer/features/show-result/data/base_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_result_state.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_result_state.dart';
import 'package:photo_enhancer/features/show-result/data/face-restoration/face_restoration_request.dart';
import 'package:photo_enhancer/features/show-result/data/face-restoration/face_restoration_result_state.dart';
import 'package:photo_enhancer/features/show-result/data/show_result_view_data_holder.dart';
import 'package:photo_enhancer/features/show-result/photo_enhancer_repository.dart';

class ShowResultViewModel extends Cubit<ShowResultViewDataHolder> {
  ShowResultViewModel({
    required this.colorizeImageRepository,
    required this.appFileManager,
    required this.permissionManager,
  }) : super(const ShowResultViewDataHolder());

  final PhotoEnhancerRepository colorizeImageRepository;
  final AppFileManager appFileManager;
  final AppPermissionManager permissionManager;

  void updateState({
    ColorizedImageResultState? colorizedImageState,
    DebluredImageResultState? debluredImageState,
    FaceRestorationResultState? faceRestorationState,
    bool? shouldGoPurchase,
  }) {
    emit(state.copyWith(
      colorizedImageResultState: colorizedImageState,
      debluredImageResultState: debluredImageState,
      faceRestorationResultState: faceRestorationState,
      shouldGoPurchase: shouldGoPurchase,
    ));
  }

  void clearState() {
    emit(const ShowResultViewDataHolder());
  }

  Future<void> enhanceImage(BaseImageRequest imageRequest, AuthViewModel authViewModel) async {
    switch (imageRequest) {
      case ColorizeImageRequest():
        await _handleColorizeImage(imageRequest, authViewModel);
        break;
      case DeblurImageRequest():
        await _handleDeblurImage(imageRequest, authViewModel);
        break;
      case FaceRestorationRequest():
        await _handleFaceRestoration(imageRequest, authViewModel);
    }
  }

  Future<void> _handleDeblurImage(DeblurImageRequest imageRequest, AuthViewModel authViewModel) async {
    updateState(debluredImageState: DebluredImageOnLoading());

    await authViewModel.spendCreditForProcess(
      amount: -AppAction.deblurImage.creditAmount,
      onSuccess: (oldAmount) async {
        final response = await colorizeImageRepository.deblurImage(imageRequest);
        AppLogger.logInfo("Response is : $response");

        if (response == null || response.error != null || (response.cacheBase64 == null && response.imageUrl == null)) {
          AppLogger.logError("Response is : $response", error: response?.error);
          updateState(debluredImageState: DebluredImageOnError(error: "Server error."));
          authViewModel.appUserRepository.updateUserCredit(
            request: UpdateUserCreditRequest(userId: authViewModel.state.appUser.googleId!, amount: oldAmount),
          );
          authViewModel.updateUserCredit(oldAmount, override: true);
          return;
        }

        // if in cache
        if (response.cacheBase64 != null) {
          final resultBytes = appFileManager.decodeBase64FromString(response.cacheBase64!);

          updateState(
            debluredImageState: DebluredImageOnLoaded(
              result: DebluredImageResult(bytes: resultBytes),
            ),
          );

          return;
        }

        final resultBytes = await appFileManager.loadImageBytesFromImageUrl(response.imageUrl!);

        updateState(
          debluredImageState: DebluredImageOnLoaded(
            result: DebluredImageResult(bytes: resultBytes),
          ),
        );
      },
      hasNoCredit: () {
        updateState(shouldGoPurchase: true);
      },
      onError: () {
        updateState(debluredImageState: DebluredImageOnError(error: "Server error."));
      },
    );
  }

  Future<void> _handleColorizeImage(ColorizeImageRequest imageRequest, AuthViewModel authViewModel) async {
    updateState(colorizedImageState: ColorizedImageOnLoading());

    await authViewModel.spendCreditForProcess(
      amount: -AppAction.colorizeImage.creditAmount,
      onSuccess: (oldAmount) async {
        final response = await colorizeImageRepository.colorizeImage(imageRequest);
        AppLogger.logInfo("Response is : $response");

        if (response == null || response.error != null || (response.cacheBase64 == null && response.imageUrl == null)) {
          AppLogger.logError("Response is : $response", error: response?.error);
          updateState(colorizedImageState: ColorizedImageOnError(error: "Server error."));
          authViewModel.appUserRepository.updateUserCredit(
            request: UpdateUserCreditRequest(userId: authViewModel.state.appUser.googleId!, amount: oldAmount),
          );
          authViewModel.updateUserCredit(oldAmount, override: true);
          return;
        }

        // if in cache
        if (response.cacheBase64 != null) {
          final resultBytes = appFileManager.decodeBase64FromString(response.cacheBase64!);

          updateState(
            colorizedImageState: ColorizedImageOnLoaded(
              result: ColorizedImageResult(bytes: resultBytes),
            ),
          );

          return;
        }

        final resultBytes = await appFileManager.loadImageBytesFromImageUrl(response.imageUrl!);

        updateState(
          colorizedImageState: ColorizedImageOnLoaded(
            result: ColorizedImageResult(bytes: resultBytes),
          ),
        );
      },
      hasNoCredit: () {
        updateState(shouldGoPurchase: true);
      },
      onError: () {
        updateState(colorizedImageState: ColorizedImageOnError(error: "Server error."));
      },
    );
  }

  Future<void> _handleFaceRestoration(FaceRestorationRequest imageRequest, AuthViewModel authViewModel) async {
    updateState(faceRestorationState: FaceRestorationOnLoading());

    await authViewModel.spendCreditForProcess(
      amount: -AppAction.faceRestoration.creditAmount,
      onSuccess: (oldAmount) async {
        final response = await colorizeImageRepository.faceRestoration(imageRequest);
        AppLogger.logInfo("Response is : $response");

        if (response == null || response.error != null || (response.cacheBase64 == null && response.imageUrl == null)) {
          AppLogger.logError("Response is : $response", error: response?.error);
          updateState(faceRestorationState: FaceRestorationOnError(error: "Server error."));
          authViewModel.appUserRepository.updateUserCredit(
            request: UpdateUserCreditRequest(userId: authViewModel.state.appUser.googleId!, amount: oldAmount),
          );
          authViewModel.updateUserCredit(oldAmount, override: true);
          return;
        }

        // if in cache
        if (response.cacheBase64 != null) {
          final resultBytes = appFileManager.decodeBase64FromString(response.cacheBase64!);

          updateState(
            faceRestorationState: FaceRestorationOnLoaded(
              result: FaceRestorationResult(bytes: resultBytes),
            ),
          );

          return;
        }

        final resultBytes = await appFileManager.loadImageBytesFromImageUrl(response.imageUrl!);

        updateState(
          faceRestorationState: FaceRestorationOnLoaded(
            result: FaceRestorationResult(bytes: resultBytes),
          ),
        );
      },
      hasNoCredit: () {
        updateState(shouldGoPurchase: true);
      },
      onError: () {
        updateState(faceRestorationState: FaceRestorationOnError(error: "Server error."));
      },
    );
  }

  Future<String?> saveResultImage(Uint8List byte) async {
    return appFileManager.saveImageToDownloadsFolder(byte, ext: "jpg");
  }

  Future<void> updateStoragePermissionGranted(HomeViewModel homeViewModel) async {
    final isGranted = await permissionManager.storagePermissionIsGrantedBelowSdk33();
    if (isGranted) {
      homeViewModel.updateState(status: AppStoragePermissionStatus.requestedAndGranted);
    }
  }
}
