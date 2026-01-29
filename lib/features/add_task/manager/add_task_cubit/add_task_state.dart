abstract class AddTaskState {}

class AddTaskInitial extends AddTaskState {}

class AddTaskLoading extends AddTaskState {}

class AddTaskSuccess extends AddTaskState {}

class AddTaskError extends AddTaskState {
  final String errorMessage;
  AddTaskError({required this.errorMessage});
}

class AddTaskChangeGroup extends AddTaskState {}

class AddTaskChangeDate extends AddTaskState {}

class AddTaskChangeImage extends AddTaskState {}
