import 'package:photo_enhancer/core/widgets/base_data_holder.dart';
import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_result_state.dart';
import 'package:photo_enhancer/features/show-result/data/deblur-image/deblur_image_result_state.dart';

class ShowResultViewDataHolder extends BaseDataHolder {
  final ColorizedImageResultState? colorizedImageResultState;
  final DebluredImageResultState? debluredImageResultState;

  const ShowResultViewDataHolder({
    this.colorizedImageResultState,
    this.debluredImageResultState,
  });

  @override
  ShowResultViewDataHolder copyWith({
    ColorizedImageResultState? colorizedImageResultState,
    DebluredImageResultState? debluredImageResultState,
  }) {
    return ShowResultViewDataHolder(
      colorizedImageResultState: colorizedImageResultState ?? this.colorizedImageResultState,
      debluredImageResultState: debluredImageResultState ?? this.debluredImageResultState,
    );
  }

  @override
  List<Object?> get props => [
        colorizedImageResultState,
        debluredImageResultState,
      ];
}
