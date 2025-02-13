import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_file_manager.dart';

import 'package:photo_enhancer/core/widgets/base_data_holder.dart';
import 'package:photo_enhancer/features/show-result/colorize_image_repository.dart';

class PickImageViewModel extends Cubit<PickImageViewDataHolder> {
  final AppFileManager appFileManager;

  PickImageViewModel({required this.appFileManager}) : super(const PickImageViewDataHolder());

  void updateState({
    AppPickedImage? appPickedImage,
    CompressImageState? compressImageState,
    bool? hasError,
  }) {
    emit(state.copyWith(
      appPickedImage: appPickedImage,
      pickedImageCompressingState: compressImageState,
      hasError: hasError,
    ));
  }

  void clearState() {
    emit(const PickImageViewDataHolder());
  }

  Future<void> pickImage() async {
    await appFileManager.pickAndCompressImage(
      (state) {
        switch (state) {
          case CompressOnLoading():
          case CompressOnInitial():
          case CompressOnCancelled():
            updateState(compressImageState: state);
            break;
          case CompressOnError(error: _):
            updateState(hasError: true);

          case CompressOnSuccess(image: final image):
            updateState(appPickedImage: image);
        }
      },
    );
  }

  ColorizeImageRequest? createColorizeImageRequest() {
    if (state.appPickedImage?.bytes == null) return null;

    return ColorizeImageRequest(
      imageBase64: appFileManager.encodeBase64FromByte(state.appPickedImage!.bytes!),
    );
  }
}

class PickImageViewDataHolder extends BaseDataHolder {
  final AppPickedImage? appPickedImage;
  final CompressImageState pickedImageCompressingState;
  final bool hasError;

  const PickImageViewDataHolder({
    this.appPickedImage,
    this.pickedImageCompressingState = const CompressOnInitial(),
    this.hasError = false,
  });

  @override
  PickImageViewDataHolder copyWith({
    AppPickedImage? appPickedImage,
    CompressImageState? pickedImageCompressingState,
    bool? hasError,
  }) {
    return PickImageViewDataHolder(
      appPickedImage: appPickedImage ?? this.appPickedImage,
      pickedImageCompressingState: pickedImageCompressingState ?? this.pickedImageCompressingState,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [appPickedImage];
}

class AppPickedImage extends Equatable {
  final Uint8List? bytes;
  final PickedImageFormat format;

  const AppPickedImage({
    this.bytes,
    this.format = PickedImageFormat.jpg,
  });

  @override
  List<Object?> get props => [bytes, format];
}

enum PickedImageFormat {
  png,
  jpg,
  jpeg,
  unsupported;
}
