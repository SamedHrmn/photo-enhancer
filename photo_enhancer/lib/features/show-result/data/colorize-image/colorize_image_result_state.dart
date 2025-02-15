import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ColorizedImageResult extends Equatable {
  final Uint8List? bytes;

  const ColorizedImageResult({
    required this.bytes,
  });

  @override
  List<Object?> get props => [bytes];
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
