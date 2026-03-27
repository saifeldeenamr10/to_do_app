import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/firebase_storage_service.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/cache/cache_keys.dart';
import '../models/user_model.dart';
import '../../../../core/cache/cache_data.dart';

class UserRepo {
  UserRepo._internal();
  static final UserRepo _instance = UserRepo._internal();
  factory UserRepo() => _instance;

  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();

  Future<Either<String, UserModel>> register({
    required String username,
    required String email,
    required String password,
    XFile? image,
  }) async {
    try {
      // 1. Create User in Auth
      final credential = await _authService.signUp(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        String? imageUrl;
        // 2. Upload Image if exists
        if (image != null) {
          imageUrl = await _storageService.uploadImage(
            path: 'profile_images/${credential!.user!.uid}',
            file: image,
          );
        }

        // 3. Create User in Firestore
        final userModel = UserModel(
          id: credential!.user!.uid,
          username: username,
          email: email,
          imagePath: imageUrl,
        );

        await _firestoreService.setDocument(
          collection: FirebaseConstants.usersCollection,
          docId: userModel.id!,
          data: userModel.toMap(),
        );

        // Cache user model for persistence
        await CacheHelper.saveData(
          key: CacheKeys.userModel,
          value: userModel.toJson().toString(),
        );
        CacheData.userModel = userModel;
        return Right(userModel);
      }
      return const Left('Failed to create user');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Auth Login
      final credential = await _authService.login(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        // 2. Fetch User Data from Firestore
        final doc = await _firestoreService.getDocument(
          collection: FirebaseConstants.usersCollection,
          docId: credential!.user!.uid,
        );

        if (doc.exists) {
          final userModel = UserModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );

          // 3. Cache User Data
          await CacheHelper.saveData(
            key: CacheKeys.userModel,
            value: userModel.toJson().toString(),
          );
          await CacheHelper.saveData(key: CacheKeys.loggedIn, value: true);
          CacheData.userModel = userModel;

          return Right(userModel);
        }
        return const Left('User data not found in database');
      }
      return const Left('Login failed');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    await CacheHelper.removeData(key: CacheKeys.userModel);
    await CacheHelper.removeData(key: CacheKeys.loggedIn);
    CacheData.userModel = null;
  }

  Future<Either<String, String>> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return const Left('User not logged in');

      // Re-authenticate if necessary or just update (Firebase might throw error if long time)
      await user.updatePassword(newPassword);
      return const Right('Password updated successfully');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
