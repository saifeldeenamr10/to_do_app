abstract class UpdateUsernameState {}

class UpdateUsernameInitial extends UpdateUsernameState {}

class UpdateUsernameLoading extends UpdateUsernameState {}

class UpdateUsernameSuccess extends UpdateUsernameState {
  final String username;

  UpdateUsernameSuccess(this.username);
}

class UpdateUsernameError extends UpdateUsernameState {
  final String error;

  UpdateUsernameError(this.error);
}

class UpdateUsernameImageSuccess extends UpdateUsernameState {}
