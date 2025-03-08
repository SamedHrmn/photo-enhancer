import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_enhancer/common/helpers/app_file_manager.dart';
import 'package:photo_enhancer/core/widgets/base_data_holder.dart';

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
