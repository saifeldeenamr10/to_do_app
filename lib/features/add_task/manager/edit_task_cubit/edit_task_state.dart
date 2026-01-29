abstract class EditTaskState {}

class EditTaskInitialState extends EditTaskState {}

class EditTaskLoadingState extends EditTaskState {}

class EditTaskChangeGroup extends EditTaskState {}

class EditTaskChangeDate extends EditTaskState {}

class DeleteTaskSuccessState extends EditTaskState {
  final String message;
  DeleteTaskSuccessState(this.message);
}

class EditTaskSuccessState extends EditTaskState {
  final String message;
  EditTaskSuccessState(this.message);
}

class EditTaskErrorState extends EditTaskState {
  final String error;
  EditTaskErrorState(this.error);
}

class EditTaskDisplayState extends EditTaskState {
  EditTaskDisplayState();
}
