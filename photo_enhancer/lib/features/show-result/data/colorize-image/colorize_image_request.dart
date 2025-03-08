import 'package:photo_enhancer/features/show-result/data/base_image_request.dart';

class ColorizeImageRequest extends BaseImageRequest {
  final String imageBase64;

  ColorizeImageRequest({required this.imageBase64});

  Map<String, dynamic> toJson() => {
        "imageBase64": imageBase64,
      };
}
