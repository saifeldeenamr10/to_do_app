abstract class UpdatePasswordState {}

class UpdatePasswordInitial extends UpdatePasswordState {}

class UpdatePasswordLoading extends UpdatePasswordState {}

class UpdatePasswordSuccess extends UpdatePasswordState {
  final String message;

  UpdatePasswordSuccess(this.message);
}

class UpdatePasswordError extends UpdatePasswordState {
  final String error;

  UpdatePasswordError(this.error);
}

class ShowPassState extends UpdatePasswordState {}
