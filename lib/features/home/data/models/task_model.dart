import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/firebase_constants.dart';

class TaskModel {
  String id;
  String title;
  String description;
  TaskStatus taskState;
  TaskGroup taskType;
  DateTime? endTime;
  DateTime? createdAt;
  XFile? imageFile;
  String? imagePath;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.taskState = TaskStatus.inProgress,
    this.taskType = TaskGroup.personal,
    this.endTime,
    this.imageFile,
    this.createdAt,
    this.imagePath,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      title: map[FirebaseConstants.title] ?? '',
      description: map[FirebaseConstants.description] ?? '',
      taskState: TaskStatus.values.firstWhere(
        (e) => e.name == map[FirebaseConstants.taskState],
        orElse: () => TaskStatus.inProgress,
      ),
      taskType: TaskGroup.values.firstWhere(
        (e) => e.name == map[FirebaseConstants.taskType],
        orElse: () => TaskGroup.personal,
      ),
      endTime: map[FirebaseConstants.endTime] != null
          ? DateTime.parse(map[FirebaseConstants.endTime])
          : null,
      createdAt: map[FirebaseConstants.createdAt] != null
          ? DateTime.parse(map[FirebaseConstants.createdAt])
          : null,
      imagePath: map[FirebaseConstants.imagePath],
    );
  }

  Map<String, dynamic> toMap({required String userId}) {
    return {
      FirebaseConstants.title: title,
      FirebaseConstants.description: description,
      FirebaseConstants.taskState: taskState.name,
      FirebaseConstants.taskType: taskType.name,
      FirebaseConstants.endTime: endTime?.toIso8601String(),
      FirebaseConstants.createdAt: createdAt?.toIso8601String(),
      FirebaseConstants.imagePath: imagePath,
      FirebaseConstants.userId: userId,
    };
  }
}

enum TaskStatus { all, inProgress, done, missed }

enum TaskGroup { all, personal, work, home }
