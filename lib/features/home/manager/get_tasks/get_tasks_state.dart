import '../../data/models/task_model.dart';

abstract class GetTasksState {}

class GetTasksInitialState extends GetTasksState {}

class GetTasksStopLoading extends GetTasksState {}

class GetTasksSuccess extends GetTasksState {
  final List<TaskModel> tasks;
  GetTasksSuccess({required this.tasks});
}

class GetTasksError extends GetTasksState {
  final String error;
  GetTasksError({required this.error});
}
