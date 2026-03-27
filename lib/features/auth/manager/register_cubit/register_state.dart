import '../../data/models/user_model.dart';

abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final UserModel userModel;
  const RegisterSuccess({required this.userModel});
}

class RegisterError extends RegisterState {
  final String? errorMessage;
  const RegisterError({this.errorMessage});
}

class RegisterShowPassState extends RegisterState {}

class RegisterChangeImageState extends RegisterState {}
