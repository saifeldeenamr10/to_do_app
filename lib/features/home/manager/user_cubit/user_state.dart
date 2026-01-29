import '../../../auth/data/models/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoadingState extends UserState {}

class UserDataSuccessState extends UserState {
  final UserModel userModel;

  UserDataSuccessState({required this.userModel});
}

class UserErrorState extends UserState {
  final String errorMes;

  UserErrorState({required this.errorMes});
}

class UserUpdateSuccessState extends UserState {
  final String message;

  UserUpdateSuccessState({required this.message});
}

class UpdateUserNameState extends UserState {}

class UpdateUserImageState extends UserState {}

class UserAddTaskState extends UserState {}

class UserEditTaskState extends UserState {}

class RefreshTokenState extends UserState {}

class RefreshTokenLoading extends UserState {}

class RefreshTokenSuccess extends UserState {}

class RefreshTokenError extends UserState {
  final String errorMessage;
  RefreshTokenError({required this.errorMessage});
}
