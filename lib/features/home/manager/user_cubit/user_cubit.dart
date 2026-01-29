import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/data/repo/user_repo.dart';
import '../../data/models/get_tasks_respone_model.dart';
import '../../../auth/data/models/user_model.dart';
import 'user_state.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/cache/cache_keys.dart';
import '../../../../core/cache/cache_data.dart';
import '../../../../core/helper/get_helper.dart';
import '../../../auth/views/login_page.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial()) {
    // Initialize user data if needed
    _initializeUserData();
  }

  static UserCubit get(context) => BlocProvider.of(context);
  UserModel? userModel;

  Future<void> _initializeUserData() async {
    // Check if we have a token before trying to get user data
    final token = await CacheHelper.getData(key: CacheKeys.accessToken);
    if (token != null) {
      await getUserFromApi();
    }
  }

  Future<void> refreshToken() async {
    emit(RefreshTokenLoading());
    var result = await UserRepo().refreshToken();
    result.fold(
      (error) {
        emit(RefreshTokenError(errorMessage: error));
        // If refresh fails, logout the user
        logout();
      },
      (success) {
        emit(RefreshTokenSuccess());
      },
    );
  }

  void getUser(UserModel user) {
    emit(UserDataSuccessState(userModel: user));
  }

  Future<bool> getUserFromApi() async {
    try {
      var result = await UserRepo().getUserData();
      return result.fold(
        (error) async {
          // If error contains token expiration, try to refresh
          if (error.toString().contains('Token has expired')) {
            // Try to refresh token
            var refreshResult = await UserRepo().refreshToken();
            return refreshResult.fold(
              (refreshError) async {
                // If refresh fails, logout immediately
                await logout();
                return false;
              },
              (success) async {
                // If refresh succeeds, try to get user data again
                var retryResult = await UserRepo().getUserData();
                return retryResult.fold(
                  (retryError) async {
                    // If retry fails, logout immediately
                    await logout();
                    return false;
                  },
                  (retryUserModel) {
                    emit(UserDataSuccessState(userModel: retryUserModel));
                    userModel = retryUserModel;
                    return true;
                  },
                );
              },
            );
          } else {
            // For any other error, logout immediately
            await logout();
            return false;
          }
        },
        (userModel) {
          emit(UserDataSuccessState(userModel: userModel));
          this.userModel = userModel;
          return true;
        },
      );
    } catch (e) {
      // For any unexpected error, logout immediately
      await logout();
      return false;
    }
  }

  void updateUserName(String name, XFile? image) async {
    emit(UserLoadingState());
    var result = await UserRepo().updateProfile(name, image);
    result.fold(
      (error) {
        emit(UserErrorState(errorMes: error));
        log('update error: $error');
      },
      (message) {
        getUserFromApi();
        emit(UserUpdateSuccessState(message: message));
      },
    );
    emit(UpdateUserNameState());
  }

  // void changePassword(
  //   String oldPassword,
  //   String newPassword,
  //   String confirmPassword,
  // ) async {
  //   emit(UserUpdateSuccessState(message: 'Password updated successfully'));
  // }

  // void updateUserImage(XFile image) {
  //   if (userModel == null) {
  //     userModel = UserModel(imagePath: image.path);
  //   } else {
  //     userModel?.imagePath = image.path;
  //   }
  //   emit(UpdateUserImageState());
  // }

  void addTask(TaskModelApi task) {
    emit(UserAddTaskState());
  }

  void editTask(TaskModelApi task) {
    emit(UserEditTaskState());
  }

  Future<void> logout() async {
    try {
      // Clear all cached data
      await CacheHelper.removeData(key: CacheKeys.accessToken);
      await CacheHelper.removeData(key: CacheKeys.refreshToken);
      await CacheHelper.removeData(key: CacheKeys.userModel);
      await CacheHelper.removeData(key: CacheKeys.loggedIn);

      // Clear in-memory data
      CacheData.accessToken = null;
      CacheData.refreshToken = null;
      CacheData.userModel = null;
      CacheData.loggedIn = null;
      userModel = null;

      // Navigate to login page
      GetHelper.pushReplaceAll(() => LoginPage());
    } catch (e) {
      // If any error occurs during logout, still try to navigate to login
      GetHelper.pushReplaceAll(() => LoginPage());
    }
  }
}
