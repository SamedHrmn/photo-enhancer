import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class FaceRestorationResult extends Equatable {
  final Uint8List? bytes;

  const FaceRestorationResult({
    required this.bytes,
  });

  @override
  List<Object?> get props => [bytes];
}

sealed class FaceRestorationResultState {
  const FaceRestorationResultState();
}

class FaceRestorationOnLoading extends FaceRestorationResultState {
  const FaceRestorationOnLoading() : super();
}

class FaceRestorationOnLoaded extends FaceRestorationResultState {
  final FaceRestorationResult result;

  const FaceRestorationOnLoaded({required this.result}) : super();
}

class FaceRestorationOnError extends FaceRestorationResultState {
  final String error;

  const FaceRestorationOnError({required this.error}) : super();
}
