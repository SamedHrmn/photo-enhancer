import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_file_manager.dart';
import 'package:photo_enhancer/common/helpers/app_permission_manager.dart';
import 'package:photo_enhancer/core/widgets/app_logger.dart';
import 'package:photo_enhancer/features/home/home_view_model.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_result_state.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_result_state.dart';
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
  }) {
    emit(state.copyWith(
      colorizedImageResultState: colorizedImageState,
      debluredImageResultState: debluredImageState,
    ));
  }

  void clearState() {
    emit(const ShowResultViewDataHolder());
  }

  Future<void> enhanceImage(BaseImageRequest imageRequest) async {
    switch (imageRequest) {
      case ColorizeImageRequest():
        await _handleColorizeImage(imageRequest);
        break;
      case DeblurImageRequest():
        await _handleDeblurImage(imageRequest);
        break;
    }
  }

  Future<void> _handleDeblurImage(DeblurImageRequest imageRequest) async {
    updateState(debluredImageState: DebluredImageOnLoading());

    final response = await colorizeImageRepository.deblurImage(imageRequest);
    AppLogger.logInfo("Response is : $response");

    if (response == null || response.error != null || (response.cacheBase64 == null && response.imageUrl == null)) {
      AppLogger.logError("Response is : $response", error: response?.error);
      updateState(debluredImageState: DebluredImageOnError(error: "Server error."));
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
  }

  Future<void> _handleColorizeImage(ColorizeImageRequest imageRequest) async {
    updateState(colorizedImageState: ColorizedImageOnLoading());

    final response = await colorizeImageRepository.colorizeImage(imageRequest);
    AppLogger.logInfo("Response is : $response");

    if (response == null || response.error != null || (response.cacheBase64 == null && response.imageUrl == null)) {
      AppLogger.logError("Response is : $response", error: response?.error);
      updateState(colorizedImageState: ColorizedImageOnError(error: "Server error."));
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
