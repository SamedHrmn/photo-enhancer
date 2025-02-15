abstract class BaseImageRequest {}

class ColorizeImageRequest extends BaseImageRequest {
  final String imageBase64;

  ColorizeImageRequest({required this.imageBase64});

  Map<String, dynamic> toJson() => {
        "imageBase64": imageBase64,
      };
}
