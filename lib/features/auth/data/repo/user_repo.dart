import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/end_points.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/cache/cache_keys.dart';
import '../../../../core/network/api_keys.dart';
import '../models/user_model.dart';
import '../../../../core/cache/cache_data.dart';

class UserRepo {
  UserRepo._internal();

  static final UserRepo _instance = UserRepo._internal();

  factory UserRepo() {
    return _instance;
  }

  ApiHelper apiHelper = ApiHelper();

  Future<Either<String, void>> register(
    String username,
    String password,
    XFile? image,
  ) async {
    try {
      await apiHelper.postRequest(
        endPoint: EndPoints.register,
        data: {
          'username': username,
          'password': password,
          'image':
              image != null ? await MultipartFile.fromFile(image.path) : null,
        },
      );
      return const Right(null);
    } catch (e) {
      ApiResponse response = ApiResponse.fromError(e);
      return Left(response.message);
    }
  }

  Future<Either<String, UserModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      // First check if we can reach the API
      try {
        var response = await apiHelper.postRequest(
          endPoint: EndPoints.login,
          data: {
            'username': username,
            'password': password,
          },
        );

        if (response.status) {
          // Save tokens
          if (response.data['access_token'] != null) {
            await CacheHelper.saveData(
              key: CacheKeys.accessToken,
              value: response.data['access_token'],
            );
            CacheData.accessToken = response.data['access_token'];
          } else {
            return const Left('Access token not received from server');
          }

          if (response.data['refresh_token'] != null) {
            await CacheHelper.saveData(
              key: CacheKeys.refreshToken,
              value: response.data['refresh_token'],
            );
            CacheData.refreshToken = response.data['refresh_token'];
          } else {
            return const Left('Refresh token not received from server');
          }

          // Create user model
          if (response.data['user'] != null) {
            UserModel userModel = UserModel.fromJson(response.data['user']);
            // Save user model to cache
            await CacheHelper.saveData(
              key: CacheKeys.userModel,
              value: userModel.toJson().toString(),
            );
            CacheData.userModel = userModel;
            return Right(userModel);
          } else {
            return const Left('User data not received from server');
          }
        } else {
          return Left(response.message);
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          return const Left(
              'Unable to connect to the server. Please check your internet connection and try again.');
        }
        if (e.response?.statusCode == 401) {
          return const Left('Invalid username or password');
        }
        if (e.response?.statusCode == 404) {
          return const Left('API endpoint not found. Please contact support.');
        }
        return Left(e.message ?? 'An error occurred during login');
      }
    } catch (e) {
      ApiResponse apiResponse = ApiResponse.fromError(e);
      return Left(apiResponse.message);
    }
  }

  Future<Either<String, UserModel>> getUserData() async {
    try {
      Response response = await apiHelper.getRequest(
        endPoint: EndPoints.getUserData,
        isProtected: true,
      );
      UserModel userModel = UserModel.fromJson(response.data['user']);
      return Right(userModel);
    } catch (e) {
      ApiResponse response = ApiResponse.fromError(e);
      return Left(response.message);
    }
  }

  Future<Either<String, String>> updateProfile(
    String newUsername,
    XFile? newImage,
  ) async {
    try {
      Response response = await apiHelper.putRequest(
        endPoint: EndPoints.updateProfile,
        data: {
          ApiKeys.username: newUsername,
          ApiKeys.image: newImage != null
              ? await MultipartFile.fromFile(newImage.path)
              : null,
        },
        isProtected: true,
      );
      ApiResponse responseModel = ApiResponse.fromResponse(response);
      if (responseModel.status) {
        return Right(responseModel.message);
      } else {
        throw Exception(responseModel.message);
      }
    } catch (e) {
      ApiResponse response = ApiResponse.fromError(e);
      return Left(response.message);
    }
  }

  Future<Either<String, String>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      ApiResponse response = await apiHelper.postRequest(
        endPoint: EndPoints.changePassword,
        data: {
          ApiKeys.currentPassword: currentPassword,
          ApiKeys.newPassword: newPassword,
          ApiKeys.newPasswordConfirm: confirmPassword,
        },
        isProtected: true,
      );

      if (response.status) {
        return Right(response.message);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      ApiResponse response = ApiResponse.fromError(e);
      return Left(response.message);
    }
  }

  Future<Either<String, String>> refreshToken() async {
    try {
      final refreshToken =
          await CacheHelper.getData(key: CacheKeys.refreshToken);
      if (refreshToken == null) {
        return const Left('No refresh token available');
      }

      ApiResponse response = await apiHelper.postRequest(
        endPoint: EndPoints.refreshToken,
        sendRefreshToken: true,
      );

      if (response.status) {
        // Update the access token in cache
        if (response.data['access_token'] != null) {
          await CacheHelper.saveData(
            key: CacheKeys.accessToken,
            value: response.data['access_token'],
          );
        }
        return const Right('Token refreshed successfully');
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data['message'] != null) {
          return Left(e.response?.data['message']);
        }
      }
      return Left(e.toString());
    }
  }
}
