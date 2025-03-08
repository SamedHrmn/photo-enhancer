import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_file_manager.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/home/viewmodel/home_view_state.dart';
import 'package:photo_enhancer/features/pick-image/viewmodel/pick_image_state.dart';
import 'package:photo_enhancer/features/show-result/data/base_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/face-restoration/face_restoration_request.dart';

class PickImageViewModel extends Cubit<PickImageViewDataHolder> {
  final AppFileManager appFileManager;

  PickImageViewModel({required this.appFileManager}) : super(const PickImageViewDataHolder());

  void updateState({
    AppPickedImage? appPickedImage,
    CompressImageState? compressImageState,
    bool? hasError,
    bool? showUnsupportedFileError,
  }) {
    emit(state.copyWith(
      appPickedImage: appPickedImage,
      pickedImageCompressingState: compressImageState,
      hasError: hasError,
      showUnsupportedFileError: showUnsupportedFileError,
    ));
  }

  void clearState() {
    emit(const PickImageViewDataHolder());
  }

  Future<void> pickImage({required AppAction appAction}) async {
    final (image, ext) = await appFileManager.pickImage();

    if (ext == PickedImageFormat.unsupported) {
      updateState(showUnsupportedFileError: true);
      return;
    } else if (image == null) {
      return;
    }

    updateState(
      appPickedImage: AppPickedImage(
        bytes: await image.readAsBytes(),
        path: image.path,
        format: PickedImageFormat.fromString(
          appFileManager.getFileExtFromPath(image.path),
        ),
      ),
    );
  }

  Future<AppPickedImage?> compressImage({
    required AppAction appAction,
    required AppPickedImage pickedImage,
  }) async {
    AppPickedImage? compressedImage;

    await appFileManager.compressImage(
      (state) {
        switch (state) {
          case CompressOnLoading():
          case CompressOnInitial():
            updateState(compressImageState: state);
            break;
          case CompressOnError(error: _):
            updateState(hasError: true, compressImageState: state);

          case CompressOnSuccess(image: final image):
            updateState(compressImageState: state);
            compressedImage = image;
        }
      },
      pickedFile: pickedImage.toXFile(),
      maxHeight: appAction.maxFileSize().height.truncate(),
      maxWidth: appAction.maxFileSize().width.truncate(),
    );

    return compressedImage;
  }

  Future<BaseImageRequest?> createImageRequest(
    AppAction selectedAction, {
    required AuthViewModel authViewModel,
  }) async {
    if (state.appPickedImage?.bytes == null) return null;

    switch (selectedAction) {
      case AppAction.colorizeImage:
        final compressedImage = await compressImage(appAction: selectedAction, pickedImage: state.appPickedImage!);
        if (compressedImage == null) return null;

        return ColorizeImageRequest(
          imageBase64: appFileManager.encodeBase64FromByte(compressedImage.bytes!),
        );

      case AppAction.deblurImage:
        final compressedImage = await compressImage(appAction: selectedAction, pickedImage: state.appPickedImage!);
        if (compressedImage == null) return null;

        return DeblurImageRequest(
          userId: authViewModel.state.appUser.googleId!,
          fileFormat: compressedImage.format.name,
          imageBase64: appFileManager.encodeBase64FromByte(compressedImage.bytes!),
        );
      case AppAction.faceRestoration:
        final compressedImage = await compressImage(appAction: selectedAction, pickedImage: state.appPickedImage!);
        if (compressedImage == null) return null;

        return FaceRestorationRequest(
          userId: authViewModel.state.appUser.googleId!,
          fileFormat: compressedImage.format.name,
          imageBase64: appFileManager.encodeBase64FromByte(compressedImage.bytes!),
        );
    }
  }
}
