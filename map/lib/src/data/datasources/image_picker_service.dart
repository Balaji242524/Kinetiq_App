import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/logger.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  Future<File?> pickImageFromCamera() async {
    try {
      AppLogger.log('Opening camera...');
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        AppLogger.log('User cancelled image capture from camera.');
        return null;
      }
      AppLogger.log('Image captured successfully from camera.');
      return File(image.path);
    } catch (e, s) {
      AppLogger.log('ImagePicker Error: Failed to pick from camera', error: e, stackTrace: s);
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      AppLogger.log('Opening gallery...');
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        AppLogger.log('User cancelled image selection from gallery.');
        return null;
      }
      AppLogger.log('Image selected successfully from gallery.');
      return File(image.path);
    } catch (e, s) {
      AppLogger.log('ImagePicker Error: Failed to pick from gallery', error: e, stackTrace: s);
      return null;
    }
  }
}