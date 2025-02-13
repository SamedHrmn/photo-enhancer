import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_file_manager.dart';
import 'package:photo_enhancer/core/widgets/base_data_holder.dart';
import 'package:photo_enhancer/features/show-result/colorize_image_repository.dart';

class ColorizedImageResult extends Equatable {
  final Uint8List? bytes;

  const ColorizedImageResult({
    required this.bytes,
  });

  @override
  List<Object?> get props => [bytes];
}

class ShowResultViewModel extends Cubit<ShowResultViewDataHolder> {
  ShowResultViewModel({
    required this.colorizeImageRepository,
    required this.appFileManager,
  }) : super(const ShowResultViewDataHolder());

  final ColorizeImageRepository colorizeImageRepository;
  final AppFileManager appFileManager;

  void updateState({
    ColorizedImageResultState? imageResultState,
  }) {
    emit(state.copyWith(
      colorizedImageResultState: imageResultState,
    ));
  }

  void clearState() {
    emit(const ShowResultViewDataHolder());
  }

  Future<void> colorizeImage(ColorizeImageRequest imageRequest) async {
    updateState(imageResultState: ColorizedImageOnLoading());

    final response = await colorizeImageRepository.colorizeImage(imageRequest);
    if (response == null) {
      updateState(imageResultState: ColorizedImageOnError(error: "Server error."));
      return;
    } else if (response.error != null || response.imageBase64 == null || response.imageBase64?.isEmpty == true) {
      updateState(imageResultState: ColorizedImageOnError(error: "Server error."));
      return;
    }

    final resultBytes = appFileManager.decodeBase64ToBytes(response.imageBase64!);

    updateState(
      imageResultState: ColorizedImageOnLoaded(
        result: ColorizedImageResult(bytes: resultBytes),
      ),
    );
  }

  Future<String?> saveResultImage() async {
    if (state.colorizedImageResultState! is ColorizedImageOnLoaded) {
      return null;
    }

    final image = state.colorizedImageResultState as ColorizedImageOnLoaded;

    return appFileManager.saveImageToDownloadsFolder(image.result.bytes!, ext: "jpg");
  }
}

sealed class ColorizedImageResultState {
  const ColorizedImageResultState();
}

class ColorizedImageOnLoading extends ColorizedImageResultState {
  const ColorizedImageOnLoading() : super();
}

class ColorizedImageOnLoaded extends ColorizedImageResultState {
  final ColorizedImageResult result;

  const ColorizedImageOnLoaded({required this.result}) : super();
}

class ColorizedImageOnError extends ColorizedImageResultState {
  final String error;

  const ColorizedImageOnError({required this.error}) : super();
}

class ShowResultViewDataHolder extends BaseDataHolder {
  final ColorizedImageResultState? colorizedImageResultState;

  const ShowResultViewDataHolder({
    this.colorizedImageResultState,
  });

  @override
  ShowResultViewDataHolder copyWith({
    ColorizedImageResultState? colorizedImageResultState,
  }) {
    return ShowResultViewDataHolder(
      colorizedImageResultState: colorizedImageResultState ?? this.colorizedImageResultState,
    );
  }

  @override
  List<Object?> get props => [
        colorizedImageResultState,
      ];
}
