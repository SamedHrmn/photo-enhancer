import 'package:photo_enhancer/core/widgets/base_data_holder.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_result_state.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_result_state.dart';

class ShowResultViewDataHolder extends BaseDataHolder {
  final ColorizedImageResultState? colorizedImageResultState;
  final DebluredImageResultState? debluredImageResultState;
  final bool shouldGoPurchase;

  const ShowResultViewDataHolder({
    this.colorizedImageResultState,
    this.debluredImageResultState,
    this.shouldGoPurchase = false,
  });

  @override
  ShowResultViewDataHolder copyWith({
    ColorizedImageResultState? colorizedImageResultState,
    DebluredImageResultState? debluredImageResultState,
    bool? shouldGoPurchase,
  }) {
    return ShowResultViewDataHolder(
      colorizedImageResultState: colorizedImageResultState ?? this.colorizedImageResultState,
      debluredImageResultState: debluredImageResultState ?? this.debluredImageResultState,
      shouldGoPurchase: shouldGoPurchase ?? this.shouldGoPurchase,
    );
  }

  @override
  List<Object?> get props => [
        colorizedImageResultState,
        debluredImageResultState,
        shouldGoPurchase,
      ];
}
