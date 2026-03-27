import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/helper/app_logger.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload an image to a specific path
  Future<String?> uploadImage({
    required String path,
    required XFile file,
  }) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(File(file.path));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      AppLogger.red('FirebaseStorageService - uploadImage Error: $e');
      return null;
    }
  }

  // Delete an image from a specific path
  Future<void> deleteImage({required String url}) async {
    try {
      Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      AppLogger.red('FirebaseStorageService - deleteImage Error: $e');
      rethrow;
    }
  }
}
