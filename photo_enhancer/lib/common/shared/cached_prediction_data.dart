import 'package:equatable/equatable.dart';

class CachedPredictionData extends Equatable {
  final String inputImageBase64;
  final String outputImageBase64;

  const CachedPredictionData({
    required this.inputImageBase64,
    required this.outputImageBase64,
  });

  Map<String, dynamic> toJson() => {
        'input': inputImageBase64,
        'output': outputImageBase64,
      };

  factory CachedPredictionData.fromJson(Map<String, dynamic> json) {
    return CachedPredictionData(
      inputImageBase64: json['input'],
      outputImageBase64: json['output'],
    );
  }

  @override
  List<Object?> get props => [inputImageBase64, outputImageBase64];
}
