import 'package:photo_enhancer/core/widgets/base_data_holder.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_result_state.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_result_state.dart';
import 'package:photo_enhancer/features/show-result/data/face-restoration/face_restoration_result_state.dart';

class ShowResultViewDataHolder extends BaseDataHolder {
  final ColorizedImageResultState? colorizedImageResultState;
  final DebluredImageResultState? debluredImageResultState;
  final FaceRestorationResultState? faceRestorationResultState;
  final bool shouldGoPurchase;

  const ShowResultViewDataHolder({
    this.colorizedImageResultState,
    this.debluredImageResultState,
    this.faceRestorationResultState,
    this.shouldGoPurchase = false,
  });

  @override
  ShowResultViewDataHolder copyWith({
    ColorizedImageResultState? colorizedImageResultState,
    DebluredImageResultState? debluredImageResultState,
    FaceRestorationResultState? faceRestorationResultState,
    bool? shouldGoPurchase,
  }) {
    return ShowResultViewDataHolder(
      colorizedImageResultState: colorizedImageResultState ?? this.colorizedImageResultState,
      debluredImageResultState: debluredImageResultState ?? this.debluredImageResultState,
      faceRestorationResultState: faceRestorationResultState ?? this.faceRestorationResultState,
      shouldGoPurchase: shouldGoPurchase ?? this.shouldGoPurchase,
    );
  }

  @override
  List<Object?> get props => [
        colorizedImageResultState,
        debluredImageResultState,
        faceRestorationResultState,
        shouldGoPurchase,
      ];
}
