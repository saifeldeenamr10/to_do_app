abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterError extends RegisterState {
  final String? errorMessage;
  const RegisterError({this.errorMessage});
}

class RegisterShowPassState extends RegisterState {}

class RegisterChangeImageState extends RegisterState {}
