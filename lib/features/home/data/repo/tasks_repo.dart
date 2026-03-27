import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/firebase_storage_service.dart';
import '../models/task_model.dart';
import '../../manager/get_tasks/get_tasks_cubit.dart';
import '../../manager/today_tasks_cubit/today_tasks_cubit.dart';

class TasksRepo {
  TasksRepo._internal();
  static final TasksRepo _instance = TasksRepo._internal();
  factory TasksRepo() => _instance;

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TaskModel> tasks = [];

  // Notify all cubits about task updates
  void _notifyTaskUpdates() {
    try {
      if (Get.isRegistered<GetTasksCubit>()) {
        final cubit = Get.find<GetTasksCubit>();
        if (!cubit.isClosed) cubit.getTasks();
      }
      if (Get.isRegistered<TodayTasksCubit>()) {
        final cubit = Get.find<TodayTasksCubit>();
        if (!cubit.isClosed) cubit.getTasks();
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
        // Update in Firestore
        await _firestoreService.updateDocument(
          collection: FirebaseConstants.tasksCollection,
          docId: task.id,
          data: {FirebaseConstants.taskState: TaskStatus.missed.name},
        );
      }
    }

    if (hasChanges) {
      _notifyTaskUpdates();
    }
  }

  Future<Either<String, String>> getTasks() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const Left('User not logged in');

      final snapshot = await _firestoreService.getCollection(
        collection: FirebaseConstants.tasksCollection,
        queryBuilder: (query) => query.where(FirebaseConstants.userId, isEqualTo: user.uid),
      );

      tasks = snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      await checkMissedTasks();
      _notifyTaskUpdates();
      return const Right('Tasks fetched successfully');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> addTask({required TaskModel task}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const Left('User not logged in');

      String? imageUrl;
      if (task.imageFile != null) {
        imageUrl = await _storageService.uploadImage(
          path: 'task_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}',
          file: task.imageFile!,
        );
      }

      final newTask = task;
      if (imageUrl != null) newTask.imagePath = imageUrl;
      newTask.createdAt = DateTime.now();

      final docRef = await _firestoreService.addDocument(
        collection: FirebaseConstants.tasksCollection,
        data: newTask.toMap(userId: user.uid),
      );

      newTask.id = docRef.id;
      tasks.add(newTask);
      _notifyTaskUpdates();

      return const Right('Task added successfully');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> deleteTask({required String id}) async {
    try {
      final task = tasks.firstWhere((t) => t.id == id);
      if (task.imagePath != null) {
        await _storageService.deleteImage(url: task.imagePath!);
      }

      await _firestoreService.deleteDocument(
        collection: FirebaseConstants.tasksCollection,
        docId: id,
      );

      tasks.removeWhere((t) => t.id == id);
      _notifyTaskUpdates();
      return const Right('Task deleted successfully');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> editTask({
    required String id,
    required String title,
    required String description,
    bool isDone = false,
    TaskGroup? taskType,
    DateTime? endTime,
  }) async {
    try {
      final taskIndex = tasks.indexWhere((t) => t.id == id);
      if (taskIndex == -1) return const Left('Task not found');

      final existingTask = tasks[taskIndex];
      final updatedStatus = isDone ? TaskStatus.done : existingTask.taskState;

      final data = {
        FirebaseConstants.title: title,
        FirebaseConstants.description: description,
        FirebaseConstants.taskState: updatedStatus.name,
        if (taskType != null) FirebaseConstants.taskType: taskType.name,
        if (endTime != null) FirebaseConstants.endTime: endTime.toIso8601String(),
      };

      await _firestoreService.updateDocument(
        collection: FirebaseConstants.tasksCollection,
        docId: id,
        data: data,
      );

      tasks[taskIndex] = TaskModel(
        id: id,
        title: title,
        description: description,
        taskState: updatedStatus,
        taskType: taskType ?? existingTask.taskType,
        imagePath: existingTask.imagePath,
        endTime: endTime ?? existingTask.endTime,
        createdAt: existingTask.createdAt,
      );

      _notifyTaskUpdates();
      return const Right('Task updated successfully');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
