import 'dart:convert';
import 'dart:io';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:photo_enhancer/features/colorize-image/pick_image_view_model.dart';

// Define callback type for state updates
typedef ProcessingStateCallback = void Function(CompressImageState state);

sealed class CompressImageState {
  const CompressImageState();
}

class CompressOnInitial extends CompressImageState {
  const CompressOnInitial() : super();
}

class CompressOnLoading extends CompressImageState {
  const CompressOnLoading() : super();
}

class CompressOnSuccess extends CompressImageState {
  final AppPickedImage image;

  CompressOnSuccess({required this.image}) : super();
}

class CompressOnError extends CompressImageState {
  final String error;

  CompressOnError({required this.error}) : super();
}

class CompressOnCancelled extends CompressImageState {
  const CompressOnCancelled() : super();
}

class AppFileManager {
  String getFileExtFromPath(String path) => path.split('.').last;

  String getFileNameFromPath(String path) => path.substring(path.lastIndexOf('/') + 1);

  Future<String?> saveImageToDownloadsFolder(Uint8List bytes, {required String ext}) async {
    final formattedFileName = '${'${DateTime.now().millisecondsSinceEpoch}'}.$ext';

    final docDir = await getApplicationDocumentsDirectory();

    final fullPath = '${docDir.path}/$formattedFileName';

    final file = File(fullPath);
    await file.writeAsBytes(bytes);

    await _copyFileIntoDownloads(
      destinationPath: fullPath,
      fileName: getFileNameFromPath(fullPath),
      ext: getFileExtFromPath(fullPath),
    );
    await file.delete();

    return file.path;
  }

  Future<bool> _copyFileIntoDownloads({
    required String destinationPath,
    required String fileName,
    required String ext,
  }) async {
    final isSuccess = (await copyFileIntoDownloadFolder(destinationPath, fileName, desiredExtension: ext)) ?? false;
    return isSuccess;
  }

  PickedImageFormat determineFileExtFromPath(String filePath) {
    if (filePath.endsWith('.png')) {
      return PickedImageFormat.png;
    } else if (filePath.endsWith(".jpg")) {
      return PickedImageFormat.jpg;
    } else if (filePath.endsWith(".jpeg")) {
      return PickedImageFormat.jpeg;
    }

    return PickedImageFormat.unsupported;
  }

  Uint8List decodeBase64ToBytes(String base64) {
    return base64Decode(base64);
  }

  String encodeBase64FromByte(Uint8List byte) {
    return base64Encode(byte);
  }

  Future<void> pickAndCompressImage(ProcessingStateCallback onStateChanged) async {
    final picker = ImagePicker();

    // Pick an image from the gallery
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      onStateChanged(CompressOnCancelled());
      return;
    }

    onStateChanged(CompressOnLoading());

    final format = determineFileExtFromPath(pickedFile.path);

    // Run the image compression task in an isolate
    final result = await compute(_compressImageInIsolate, {
      'imagePath': pickedFile.path,
      'format': format.name,
    });

    if (result == null) {
      onStateChanged(CompressOnError(error: "Compression error, file object is null"));
      return;
    }

    final compressedBytes = await result.readAsBytes();

    onStateChanged(
      CompressOnSuccess(
        image: AppPickedImage(
          bytes: compressedBytes,
          format: format,
        ),
      ),
    );
  }
}

// Method to pick and compress image

// Function to run in isolate for image compression
Future<File?> _compressImageInIsolate(Map<String, dynamic> params) async {
  String imagePath = params['imagePath'];
  String format = params['format'];

  File file = File(imagePath);
  img.Image? image = img.decodeImage(file.readAsBytesSync());

  if (image == null) {
    return null;
  }

  int quality = 100;
  int targetSize = 1 * 1024 * 1024; // 1 MB in bytes
  List<int> compressedData = [];

  // Start compression loop
  while (compressedData.length > targetSize || quality > 10) {
    // Resize image while maintaining aspect ratio
    switch (format) {
      case "png":
        compressedData = img.encodePng(image);
        break;
      case "jpg":
      case "jpeg":
        compressedData = img.encodeJpg(image);
    }

    if (image.hasAlpha) quality -= 10;

    // Check the file size
    if (compressedData.length <= targetSize) {
      break;
    }
  }

  // Save the compressed image
  File compressedFile = await file.writeAsBytes(compressedData);

  return compressedFile;
}
