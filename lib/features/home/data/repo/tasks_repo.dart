import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../core/network/api_response.dart';
import '../../../../core/models/default_respons_model.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/network/end_points.dart';
import '../models/get_tasks_respone_model.dart';
import '../models/task_model.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/cache/cache_keys.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../manager/get_tasks/get_tasks_cubit.dart';
import '../../manager/today_tasks_cubit/today_tasks_cubit.dart';

class TasksRepo {
  // private named constructor
  // prevent anyone from taking objects outside the class
  TasksRepo._internal();
  // make it static to access it in factory
  static final TasksRepo _instance = TasksRepo._internal();
  // add factory to control what the constructors return every time it's used
  factory TasksRepo() {
    return _instance;
  }
  List<TaskModel> tasks = [];
  // List<TaskModel> get tasks => _tasks;
  // void addTask(TaskModel task) {
  //   tasks.add(task);
  // }

  ApiHelper apiHelper = ApiHelper();
  bool isRefreshing = false;

  // Notify all cubits about task updates
  void _notifyTaskUpdates() {
    try {
      // Notify GetTasksCubit
      if (Get.isRegistered<GetTasksCubit>()) {
        final cubit = Get.find<GetTasksCubit>();
        if (cubit.isClosed == false) {
          cubit.getTasks();
        }
      }
      // Notify TodayTasksCubit
      if (Get.isRegistered<TodayTasksCubit>()) {
        final cubit = Get.find<TodayTasksCubit>();
        if (cubit.isClosed == false) {
          cubit.getTasks();
        }
      }
    } catch (e) {
      // Ignore errors during notification
    }
  }

  // Check and update missed tasks
  Future<void> checkMissedTasks() async {
    final now = DateTime.now();
    bool hasChanges = false;

    for (var task in tasks) {
      if (task.endTime != null &&
          task.endTime!.isBefore(now) &&
          task.taskState != TaskStatus.done) {
        task.taskState = TaskStatus.missed;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await saveTaskStates();
      _notifyTaskUpdates();
    }
  }

  // Save task states to SharedPreferences
  Future<void> saveTaskStates() async {
    Map<String, String> taskStates = {};
    for (var task in tasks) {
      taskStates[task.id.toString()] = task.taskState.toString();
    }
    await CacheHelper.saveData(
      key: CacheKeys.taskStates,
      value: jsonEncode(taskStates),
    );
  }

  // Load task states from SharedPreferences
  Future<void> loadTaskStates() async {
    String? statesJson = CacheHelper.getData(key: CacheKeys.taskStates);
    if (statesJson != null) {
      Map<String, dynamic> taskStates = jsonDecode(statesJson);
      for (var task in tasks) {
        String? state = taskStates[task.id.toString()];
        if (state != null) {
          task.taskState = TaskStatus.values.firstWhere(
            (e) => e.toString() == state,
            orElse: () => TaskStatus.inProgress,
          );
        }
      }
    }
    // Check for missed tasks after loading states
    await checkMissedTasks();
  }

  // Save task groups to SharedPreferences
  Future<void> saveTaskGroups() async {
    Map<String, String> taskGroups = {};
    for (var task in tasks) {
      taskGroups[task.id.toString()] = task.taskType.toString();
    }
    await CacheHelper.saveData(
      key: CacheKeys.taskGroups,
      value: jsonEncode(taskGroups),
    );
  }

  // Load task groups from SharedPreferences
  Future<void> loadTaskGroups() async {
    String? groupsJson = CacheHelper.getData(key: CacheKeys.taskGroups);
    if (groupsJson != null) {
      Map<String, dynamic> taskGroups = jsonDecode(groupsJson);
      for (var task in tasks) {
        String? group = taskGroups[task.id.toString()];
        if (group != null) {
          task.taskType = TaskGroup.values.firstWhere(
            (e) => e.toString() == group,
            orElse: () => TaskGroup.personal,
          );
        }
      }
    }
  }

  Future<Either<String, String>> _handleTokenRefresh() async {
    if (isRefreshing) {
      return Left("Token refresh in progress");
    }

    isRefreshing = true;
    try {
      final refreshToken =
          await CacheHelper.getData(key: CacheKeys.refreshToken);
      if (refreshToken == null) {
        isRefreshing = false;
        _handleLogout("Session expired. Please login again.");
        return Left("Session expired. Please login again.");
      }

      var refreshResponse = await apiHelper.postRequest(
        endPoint: EndPoints.refreshToken,
        isProtected: true,
        sendRefreshToken: true,
      );

      if (refreshResponse.status &&
          refreshResponse.data['access_token'] != null) {
        await CacheHelper.saveData(
          key: CacheKeys.accessToken,
          value: refreshResponse.data['access_token'],
        );
        isRefreshing = false;
        return Right("Token refreshed successfully");
      } else {
        isRefreshing = false;
        _handleLogout("Session expired. Please login again.");
        return Left("Session expired. Please login again.");
      }
    } catch (e) {
      isRefreshing = false;
      _handleLogout("Session expired. Please login again.");
      return Left("Session expired. Please login again.");
    }
  }

  void _handleLogout(String message) {
    try {
      CacheHelper.removeData(key: CacheKeys.accessToken);
      CacheHelper.removeData(key: CacheKeys.refreshToken);
      Get.offAllNamed('/login');
      Get.snackbar(
        'Session Expired',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // If Get.offAllNamed fails, try to navigate using GetX
      Get.until((route) => route.settings.name == '/login');
    }
  }

  Future<Either<String, String>> getTasks() async {
    try {
      var response = await apiHelper.getRequest(
        endPoint: EndPoints.getTasks,
        isProtected: true,
      );
      GetTasksResponseModel responseModel = GetTasksResponseModel.fromJson(
        response.data,
      );

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (apiResponse.status) {
        tasks.clear();
        for (TaskModelApi task in responseModel.tasks ?? []) {
          tasks.add(
            TaskModel(
              id: task.id!,
              title: task.title!,
              description: task.description!,
              imagePath: task.imagePath,
              taskType: _getTaskGroupFromString(task.taskType ?? 'personal'),
              taskState:
                  task.isDone == true ? TaskStatus.done : TaskStatus.inProgress,
              endTime:
                  task.endTime != null ? DateTime.parse(task.endTime!) : null,
              createdAt: task.createdAt != null
                  ? DateTime.parse(task.createdAt!)
                  : null,
            ),
          );
        }
        // Load saved states and groups after fetching tasks
        await loadTaskStates();
        await loadTaskGroups();
        // Check for missed tasks
        await checkMissedTasks();
        // Notify cubits about the update
        _notifyTaskUpdates();
        return Right('tasks fetched successfully');
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      if (e is DioException &&
          (e.response?.data['message']?.toString().contains('Token') == true ||
              e.response?.statusCode == 401)) {
        var refreshResult = await _handleTokenRefresh();
        return refreshResult.fold(
          (error) => Left(error),
          (success) async {
            try {
              var retryResponse = await apiHelper.getRequest(
                endPoint: EndPoints.getTasks,
                isProtected: true,
              );

              GetTasksResponseModel responseModel =
                  GetTasksResponseModel.fromJson(
                retryResponse.data,
              );

              ApiResponse apiResponse = ApiResponse.fromResponse(retryResponse);

              if (apiResponse.status) {
                tasks.clear();
                for (TaskModelApi task in responseModel.tasks ?? []) {
                  tasks.add(
                    TaskModel(
                      id: task.id!,
                      title: task.title!,
                      description: task.description!,
                      imagePath: task.imagePath,
                      taskType:
                          _getTaskGroupFromString(task.taskType ?? 'personal'),
                      taskState: task.isDone == true
                          ? TaskStatus.done
                          : TaskStatus.inProgress,
                      endTime: task.endTime != null
                          ? DateTime.parse(task.endTime!)
                          : null,
                      createdAt: task.createdAt != null
                          ? DateTime.parse(task.createdAt!)
                          : null,
                    ),
                  );
                }
                // Load saved states and groups after fetching tasks
                await loadTaskStates();
                await loadTaskGroups();
                // Check for missed tasks
                await checkMissedTasks();
                // Notify cubits about the update
                _notifyTaskUpdates();
                return Right('tasks fetched successfully');
              } else {
                return Left(apiResponse.message);
              }
            } catch (retryError) {
              return Left("Failed to fetch tasks after token refresh");
            }
          },
        );
      }

      ApiResponse apiResponse = ApiResponse.fromError(e);
      return Left(apiResponse.message);
    }
  }

  TaskGroup _getTaskGroupFromString(String type) {
    switch (type.toLowerCase()) {
      case 'work':
        return TaskGroup.work;
      case 'home':
        return TaskGroup.home;
      case 'personal':
        return TaskGroup.personal;
      default:
        return TaskGroup.personal;
    }
  }

  Future<Either<String, String>> addTask({required TaskModel task}) async {
    try {
      TaskModelApi taskModelApi = TaskModelApi(
        title: task.title,
        description: task.description,
        image: task.imageFile,
        taskType: task.taskType.name,
        isDone: task.taskState == TaskStatus.done,
        endTime: task.endTime?.toIso8601String(),
      );
      var response = await apiHelper.postRequest(
        endPoint: EndPoints.newTask,
        isProtected: true,
        data: await taskModelApi.toJson(),
      );
      DefaultResponseModel responseModel = DefaultResponseModel.fromJson(
        response.data,
      );

      if (responseModel.status != null && responseModel.status == true) {
        // Add the task to the local list with the correct group
        tasks.add(task);

        // Save task states and groups immediately
        await saveTaskStates();
        await saveTaskGroups();

        // Check for missed tasks
        await checkMissedTasks();

        // Force refresh tasks from API to ensure consistency
        await getTasks();

        // Notify cubits about the update
        _notifyTaskUpdates();

        return Right(responseModel.message ?? "Task added successfully");
      } else {
        throw Exception("Something went wrong");
      }
    } catch (e) {
      ApiResponse apiResponse = ApiResponse.fromError(e);
      return Left(apiResponse.message);
    }
  }

  Future<Either<String, String>> deleteTask({required int id}) async {
    try {
      var response = await apiHelper.deleteRequest(
        endPoint: '${EndPoints.deleteTask}$id',
        isProtected: true,
      );
      ApiResponse responseModel = ApiResponse.fromResponse(response);

      if (responseModel.status == true) {
        // Remove the task from the local list
        tasks.removeWhere((task) => task.id == id);
        // Save task states and groups
        await saveTaskStates();
        await saveTaskGroups();
        // Notify cubits about the update
        _notifyTaskUpdates();
        return Right(responseModel.message);
      } else {
        throw Exception("Something went wrong");
      }
    } catch (e) {
      ApiResponse apiResponse = ApiResponse.fromError(e);
      return Left(apiResponse.message);
    }
  }

  Future<Either<String, String>> editTask({
    required int id,
    required String title,
    required String description,
    bool isDone = false,
    TaskGroup? taskType,
    DateTime? endTime,
  }) async {
    try {
      var response = await apiHelper.putRequest(
        endPoint: '${EndPoints.updateTask}$id',
        isProtected: true,
        data: {
          'title': title,
          'description': description,
          'is_done': isDone,
          if (taskType != null) 'task_type': taskType.name,
          if (endTime != null) 'end_time': endTime.toIso8601String(),
        },
      );
      ApiResponse responseModel = ApiResponse.fromResponse(response);

      if (responseModel.status == true) {
        final taskIndex = tasks.indexWhere((task) => task.id == id);
        if (taskIndex != -1) {
          final existingTask = tasks[taskIndex];
          tasks[taskIndex] = TaskModel(
            id: id,
            title: title,
            description: description,
            taskState: isDone ? TaskStatus.done : existingTask.taskState,
            taskType: taskType ?? existingTask.taskType,
            imagePath: existingTask.imagePath,
            endTime: endTime ?? existingTask.endTime,
            createdAt: existingTask.createdAt,
          );
          // Save updated states and groups
          await saveTaskStates();
          await saveTaskGroups();
          // Notify cubits about the update
          _notifyTaskUpdates();
        }
        return Right(responseModel.message);
      } else {
        throw Exception("Something went wrong");
      }
    } catch (e) {
      ApiResponse apiResponse = ApiResponse.fromError(e);
      return Left(apiResponse.message);
    }
  }
}
