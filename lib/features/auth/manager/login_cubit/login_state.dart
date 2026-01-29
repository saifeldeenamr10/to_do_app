import '../../data/models/user_model.dart';

abstract class LoginState {}

class LoginInitState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {
  UserModel userModel;
  LoginSuccessState({required this.userModel});
}

class LoginErrorState extends LoginState {
  String errorMessage;
  LoginErrorState({required this.errorMessage});
}

class LoginShowPassState extends LoginState {}
