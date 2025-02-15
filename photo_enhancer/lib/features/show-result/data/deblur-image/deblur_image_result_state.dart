import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class DebluredImageResult extends Equatable {
  final Uint8List? bytes;

  const DebluredImageResult({
    required this.bytes,
  });

  @override
  List<Object?> get props => [bytes];
}

sealed class DebluredImageResultState {
  const DebluredImageResultState();
}

class DebluredImageOnLoading extends DebluredImageResultState {
  const DebluredImageOnLoading() : super();
}

class DebluredImageOnLoaded extends DebluredImageResultState {
  final DebluredImageResult result;

  const DebluredImageOnLoaded({required this.result}) : super();
}

class DebluredImageOnError extends DebluredImageResultState {
  final String error;

  const DebluredImageOnError({required this.error}) : super();
}
