import '../../data/models/task_model.dart';

abstract class TodayTasksState {}

class TodayTasksInitial extends TodayTasksState {}

class GetTasksLoading extends TodayTasksState {}

class GroupFilterChangedState extends TodayTasksState {}

class StatusFilterChangedState extends TodayTasksState {}

class DateSelectedState extends TodayTasksState {}

class GetTasksSuccess extends TodayTasksState {
  final List<TaskModel> tasks;

  GetTasksSuccess({this.tasks = const []});
}

class GetTasksError extends TodayTasksState {
  final String errorMessage;

  GetTasksError(this.errorMessage);
}

class FilterTasksState extends TodayTasksState {}
