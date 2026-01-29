import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../home/data/repo/tasks_repo.dart';
import 'add_task_state.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../home/data/models/task_model.dart';
import '../../data/models/group_model.dart';

class AddTaskCubit extends Cubit<AddTaskState> {
  AddTaskCubit() : super(AddTaskInitial()) {
    // Set default group when cubit is created
    group = groups.firstWhere((g) => g.name == 'Personal');
    groupController.text = group!.name;
  }
  static AddTaskCubit get(context) => BlocProvider.of<AddTaskCubit>(context);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController groupController = TextEditingController();
  DateTime? endDate;
  GroupModel? group;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<GroupModel> groups = [
    GroupModel(name: 'Work', iconPath: AppAssets.work),
    GroupModel(name: 'Personal', iconPath: AppAssets.personal),
    GroupModel(name: 'Home', iconPath: AppAssets.home),
  ];

  void changeGroup(GroupModel group) {
    this.group = group;
    groupController.text = group.name;
    // Force UI update by emitting state
    emit(AddTaskInitial());
    emit(AddTaskChangeGroup());
  }

  void changeDate(DateTime endDate) {
    this.endDate = endDate;
    emit(AddTaskChangeDate());
  }

  XFile? imageFile;
  void changeImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      imageFile = await picker.pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        emit(AddTaskChangeImage());
      }
    } catch (e) {
      emit(AddTaskError(errorMessage: 'Failed to pick image: $e'));
    }
  }

  void addTaskApi() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      emit(AddTaskError(errorMessage: 'Please fill all fields'));
      return;
    }

    if (group == null) {
      emit(AddTaskError(errorMessage: 'Please select a group'));
      return;
    }

    emit(AddTaskLoading());
    try {
      TasksRepo tasksRepo = TasksRepo();
      TaskGroup taskGroup = _getTaskGroupFromName(group!.name);

      var result = await tasksRepo.addTask(
        task: TaskModel(
          title: titleController.text,
          description: descriptionController.text,
          id: DateTime.now().millisecondsSinceEpoch,
          taskState: TaskStatus.inProgress,
          taskType: taskGroup,
          endTime: endDate,
          imageFile: imageFile,
        ),
      );

      result.fold(
        (error) {
          emit(AddTaskError(errorMessage: error));
        },
        (success) {
          tasksRepo.tasks.add(
            TaskModel(
              title: titleController.text,
              description: descriptionController.text,
              id: DateTime.now().millisecondsSinceEpoch,
              taskState: TaskStatus.inProgress,
              taskType: taskGroup,
              endTime: endDate,
              imageFile: imageFile,
            ),
          );
          emit(AddTaskSuccess());
        },
      );
    } catch (e) {
      emit(AddTaskError(errorMessage: 'Failed to add task: $e'));
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

  @override
  Future<void> close() {
    titleController.dispose();
    descriptionController.dispose();
    groupController.dispose();
    return super.close();
  }
}
