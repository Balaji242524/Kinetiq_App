import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/logger.dart';
class FirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = 'poses/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      AppLogger.log('Image uploaded to Firebase Storage. URL: $downloadUrl');
      return downloadUrl;
    } catch (e, s) {
      AppLogger.log('Firebase Storage Error: Failed to upload image', error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> savePoseToFirestore(String keypointsJson, String imageUrl) async {
    try {
      await _firestore.collection('poses').add({
        'keypoints_json': keypointsJson, 
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(), 
      });
      AppLogger.log('Pose data saved to Firestore.');
    } catch (e, s) {
      AppLogger.log('Firestore Error: Failed to save pose data', error: e, stackTrace: s);
      rethrow; 
    }
  }
}