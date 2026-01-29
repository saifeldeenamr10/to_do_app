import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../home/data/repo/tasks_repo.dart';
import '../../../home/data/models/task_model.dart';

import '../../data/models/group_model.dart';
import 'edit_task_state.dart';

class EditTaskCubit extends Cubit<EditTaskState> {
  EditTaskCubit() : super(EditTaskInitialState()) {
    // Set default group when cubit is created
    group = groups.first;
    groupController.text = group!.name;
  }
  EditTaskCubit get(context) => BlocProvider.of(context);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController groupController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  GroupModel? group;
  String? imagePath;
  DateTime? endDate;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<GroupModel> groups = [
    GroupModel(name: 'Work', iconPath: AppAssets.work),
    GroupModel(name: 'Personal', iconPath: AppAssets.personal),
    GroupModel(name: 'Home', iconPath: AppAssets.home),
  ];

  void changeGroup(GroupModel group) {
    this.group = group;
    groupController.text = group.name;
    emit(EditTaskChangeGroup());
  }

  void changeDate(DateTime date) {
    endDate = date;
    dateController.text = date.toString();
    emit(EditTaskChangeDate());
  }

  void displayTask(int id) {
    var task = TasksRepo().tasks.firstWhere((element) => element.id == id);
    imagePath = task.imagePath;
    log('task: ${task.title}');
    titleController.text = task.title;
    descriptionController.text = task.description;

    // Set the group based on task type
    group = groups.firstWhere(
      (g) => g.name.toLowerCase() == task.taskType.name.toLowerCase(),
      orElse: () => groups.first,
    );
    groupController.text = group!.name;

    // Set the end date
    endDate = task.endTime;
    dateController.text = task.endTime?.toString() ?? '';

    emit(EditTaskDisplayState());
  }

  void editTask(int id) async {
    emit(EditTaskLoadingState());

    if (formKey.currentState!.validate()) {
      if (group == null) {
        emit(EditTaskErrorState("Please select a group"));
        return;
      }

      try {
        TaskGroup taskGroup = _getTaskGroupFromName(group!.name);

        var result = await TasksRepo().editTask(
          id: id,
          title: titleController.text,
          description: descriptionController.text,
          taskType: taskGroup,
          endTime: endDate,
        );
        result.fold(
          (error) {
            emit(EditTaskErrorState(error));
          },
          (message) {
            // Refresh the tasks list after successful edit
            TasksRepo().getTasks();
            emit(EditTaskSuccessState(message));
          },
        );
      } catch (e) {
        emit(EditTaskErrorState("Failed to edit task"));
      }
    }
  }

  void deleteTask(int id) async {
    emit(EditTaskLoadingState());
    try {
      var result = await TasksRepo().deleteTask(id: id);
      result.fold(
        (error) {
          emit(EditTaskErrorState(error));
        },
        (message) {
          emit(DeleteTaskSuccessState(message));
        },
      );
    } catch (e) {
      emit(EditTaskErrorState("Failed to delete task"));
    }
  }

  void markTaskAsDone(int id) async {
    emit(EditTaskLoadingState());
    try {
      if (group == null) {
        emit(EditTaskErrorState("Please select a group"));
        return;
      }

      TaskGroup taskGroup = _getTaskGroupFromName(group!.name);

      var result = await TasksRepo().editTask(
        id: id,
        title: titleController.text,
        description: descriptionController.text,
        isDone: true,
        taskType: taskGroup,
        endTime: endDate,
      );
      result.fold(
        (error) {
          emit(EditTaskErrorState(error));
        },
        (message) {
          emit(EditTaskSuccessState(message));
        },
      );
    } catch (e) {
      emit(EditTaskErrorState("Failed to mark task as done"));
    }
  }

  TaskGroup _getTaskGroupFromName(String name) {
    switch (name.toLowerCase()) {
      case 'work':
        return TaskGroup.work;
      case 'personal':
        return TaskGroup.personal;
      case 'home':
        return TaskGroup.home;
      default:
        return TaskGroup.work;
    }
  }
}
