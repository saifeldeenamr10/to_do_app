import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class GetTasksResponseModel {
  bool? status;
  List<TaskModelApi>? tasks;

  GetTasksResponseModel({this.status, this.tasks});

  GetTasksResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['tasks'] != null) {
      tasks = <TaskModelApi>[];
      json['tasks'].forEach((v) {
        tasks!.add(TaskModelApi.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (tasks != null) {
      data['tasks'] = tasks!.map((v) => v.toJsonSync()).toList();
    }
    return data;
  }
}

class TaskModelApi {
  String? createdAt;
  String? description;
  int? id;
  String? imagePath;
  String? title;
  String? taskType;
  bool? isDone;
  String? endTime;
  XFile? image;

  TaskModelApi({
    this.createdAt,
    this.description,
    this.id,
    this.imagePath,
    this.title,
    this.taskType,
    this.isDone,
    this.endTime,
    this.image,
  });

  TaskModelApi.fromJson(Map<String, dynamic> json) {
    createdAt = _parseDate(json['created_at']);
    description = json['description'];
    id = json['id'];
    imagePath = json['image_path'];
    title = json['title'];
    taskType = json['task_type'];
    isDone = json['is_done'];
    endTime = _parseDate(json['end_time']);
  }

  String? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      // Parse the date string in the format "Thu, 22 May 2025 23:12:47 GMT"
      final inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
      final date = inputFormat.parse(dateStr);
      // Convert to ISO 8601 format
      return date.toIso8601String();
    } catch (e) {
      print('Error parsing date: $dateStr');
      return null;
    }
  }

  // Synchronous version for serialization
  Map<String, dynamic> toJsonSync() {
    final Map<String, dynamic> data = {};
    data['description'] = description;
    data['title'] = title;
    data['image_path'] = imagePath;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['task_type'] = taskType;
    data['is_done'] = isDone;
    data['end_time'] = endTime;
    return data;
  }

  // Asynchronous version for API requests
  Future<Map<String, dynamic>> toJson() async {
    final Map<String, dynamic> data = toJsonSync();
    if (image != null) {
      data['image'] =
          await MultipartFile.fromFile(image!.path, filename: image!.name);
    }
    return data;
  }
}
