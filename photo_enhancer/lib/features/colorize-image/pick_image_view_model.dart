import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_enhancer/common/helpers/app_file_manager.dart';

import 'package:photo_enhancer/core/widgets/base_data_holder.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/home/home_view_model.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_request.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_request.dart';

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
    }
  }
}

class PickImageViewDataHolder extends BaseDataHolder {
  final AppPickedImage? appPickedImage;
  final CompressImageState pickedImageCompressingState;
  final bool hasError;
  final bool showUnsupportedFileError;

  const PickImageViewDataHolder({
    this.appPickedImage,
    this.pickedImageCompressingState = const CompressOnInitial(),
    this.hasError = false,
    this.showUnsupportedFileError = false,
  });

  @override
  PickImageViewDataHolder copyWith({
    AppPickedImage? appPickedImage,
    CompressImageState? pickedImageCompressingState,
    bool? hasError,
    bool? showUnsupportedFileError,
  }) {
    return PickImageViewDataHolder(
      appPickedImage: appPickedImage ?? this.appPickedImage,
      pickedImageCompressingState: pickedImageCompressingState ?? this.pickedImageCompressingState,
      hasError: hasError ?? this.hasError,
      showUnsupportedFileError: showUnsupportedFileError ?? this.showUnsupportedFileError,
    );
  }

  @override
  List<Object?> get props => [
        appPickedImage,
        pickedImageCompressingState,
        hasError,
        showUnsupportedFileError,
      ];
}

class AppPickedImage extends Equatable {
  final Uint8List? bytes;
  final String? path;
  final PickedImageFormat format;

  const AppPickedImage({
    this.bytes,
    this.format = PickedImageFormat.jpg,
    this.path,
  });

  @override
  List<Object?> get props => [bytes, format, path];

  XFile toXFile() {
    return XFile.fromData(bytes!, path: path);
  }

  /*BaseImageRequest toImageRequest(AppAction action, String base64Data) {
    switch (action) {
      case AppAction.colorizeImage:
        return ColorizeImageRequest(imageBase64: base64Data);
        
      case AppAction.deblurImage:
       return DeblurImageRequest(imageBase64: imageBase64, userId: userId, fileFormat: fileFormat)
    }
  }*/
}

enum PickedImageFormat {
  png,
  jpg,
  jpeg,
  unsupported;

  const PickedImageFormat();

  static PickedImageFormat fromString(String ext) {
    switch (ext) {
      case 'png':
        return PickedImageFormat.png;
      case 'jpg':
        return PickedImageFormat.jpg;
      case 'jpeg':
        return PickedImageFormat.jpeg;
      default:
        return PickedImageFormat.unsupported;
    }
  }
}
