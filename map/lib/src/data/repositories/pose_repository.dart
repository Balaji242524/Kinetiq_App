import 'dart:io';
import '../models/pose_data_model.dart';
import '../datasources/sqlite_helper.dart';
import '../datasources/api_service.dart';
import '../datasources/firebase_service.dart';
import '../datasources/image_picker_service.dart';
import '../../core/logger.dart';

class PoseRepository {
  final _apiService = ApiService();
  final _localDB = SQLiteHelper();
  final _firebaseService = FirebaseService();
  final _imagePicker = ImagePickerService();

  Future<List<PoseData>> getHistory() async {
    return await _localDB.getPoses();
  }

  Future<bool> captureAndProcessImage() async {
    try {
      final imageFile = await _imagePicker.pickImageFromCamera();
      if (imageFile == null) {
        AppLogger.log('Image capture was cancelled by the user.');
        return false;
      }

      final keypointsJson = await _apiService.getKeypointsFromImage(imageFile);
      if (keypointsJson == null) {
        throw Exception('Failed to get keypoints from the backend API.');
      }

      final poseData = PoseData(
        timestamp: DateTime.now(),
        keypointsJson: keypointsJson,
        localImagePath: imageFile.path,
      );
      await _localDB.insertPose(poseData);
      AppLogger.log('Pose data saved locally.');

      _syncToFirebase(imageFile, poseData);

      return true;
    } catch (e, s) {
      AppLogger.log('Error in the main processing flow', error: e, stackTrace: s);
      return false;
    }
  }

  Future<void> _syncToFirebase(File imageFile, PoseData poseData) async {
    try {
      final imageUrl = await _firebaseService.uploadImage(imageFile);

      final finalImageUrl = imageUrl ?? 'upload_failed';

      await _firebaseService.savePoseToFirestore(poseData.keypointsJson, finalImageUrl);
      
      if(imageUrl != null) {
        AppLogger.log('Sync to Firebase completed successfully.');
      } else {
        AppLogger.log('Sync to Firestore completed, but image upload failed. Used dummy URL.');
      }

    } catch (e, s) {
      AppLogger.log('Sync to Firebase failed.', error: e, stackTrace: s);
    }
  }
}