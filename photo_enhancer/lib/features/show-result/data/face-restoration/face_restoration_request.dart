import 'package:photo_enhancer/features/show-result/data/base_image_request.dart';

class FaceRestorationRequest extends BaseImageRequest {
  final String imageBase64;
  final String userId;
  final String fileFormat;

  FaceRestorationRequest({
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
