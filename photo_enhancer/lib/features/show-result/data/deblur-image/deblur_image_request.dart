import 'package:photo_enhancer/features/show-result/data/colorize-image/colorize_image_request.dart';

class DeblurImageRequest extends BaseImageRequest {
  final String imageBase64;
  final String userId;
  final String fileFormat;

  DeblurImageRequest({
    required this.imageBase64,
    required this.userId,
    required this.fileFormat,
  });

  Map<String, dynamic> toJson() => {
        "imageBase64": imageBase64,
        "userId": userId,
        "fileFormat": fileFormat,
      };
}
