import 'package:image_picker/image_picker.dart';

class TaskModel {
  int id;
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
}

enum TaskStatus { all, inProgress, done, missed }

enum TaskGroup { all, personal, work, home }
