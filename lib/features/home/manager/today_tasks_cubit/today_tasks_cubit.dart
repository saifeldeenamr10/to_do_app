import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../data/repo/tasks_repo.dart';
import '../../data/models/task_model.dart';
import 'today_tasks_state.dart';

class TodayTasksCubit extends Cubit<TodayTasksState> {
  static TodayTasksCubit get(context) => BlocProvider.of(context);

  TodayTasksCubit() : super(TodayTasksInitial());

  DateTime selectedDate = DateTime.now();
  List<TaskModel> allTasks = [];
  List<TaskModel> filteredTasks = [];
  bool _isClosed = false;

  Map<TaskGroup, bool> groupFilters = {
    TaskGroup.all: true,
    TaskGroup.home: false,
    TaskGroup.work: false,
    TaskGroup.personal: false,
  };
  Map<TaskStatus, bool> statusFilters = {
    TaskStatus.all: true,
    TaskStatus.inProgress: false,
    TaskStatus.done: false,
    TaskStatus.missed: false,
  };

  void onGroupFilterChanged(TaskGroup group) {
    if (_isClosed) return;
    groupFilters.updateAll((_, __) => false);
    groupFilters[group] = true;
    _applyFilters();
    emit(GroupFilterChangedState());
  }

  void onStatusFilterChanged(TaskStatus status) {
    if (_isClosed) return;
    statusFilters.updateAll((_, __) => false);
    statusFilters[status] = true;
    _applyFilters();
    emit(StatusFilterChangedState());
  }

  void onDateSelected(DateTime date) {
    if (_isClosed) return;
    selectedDate = date;
    _applyFilters();
    emit(DateSelectedState());
  }

  void getTasks() async {
    if (_isClosed) return;
    emit(GetTasksLoading());
    try {
      final TasksRepo tasksRepo = TasksRepo();
      var result = await tasksRepo.getTasks();
      if (_isClosed) return;

      result.fold(
        (error) {
          if (_isClosed) return;
          if (error.contains('Session expired') || error.contains('Token')) {
            Get.offAllNamed('/login');
          } else {
            emit(GetTasksError(error));
          }
        },
        (success) {
          if (_isClosed) return;
          allTasks = tasksRepo.tasks;
          _applyFilters();
          emit(GetTasksSuccess(tasks: filteredTasks));
        },
      );
    } catch (e) {
      if (_isClosed) return;
      if (e.toString().contains('Session expired') ||
          e.toString().contains('Token')) {
        Get.offAllNamed('/login');
      } else {
        emit(GetTasksError(e.toString()));
      }
    }
  }

  void _applyFilters() {
    if (_isClosed) return;
    filteredTasks = allTasks.where((task) {
      // Check if task is for selected date
      bool isForSelectedDate = true; // Show all tasks by default
      if (task.endTime != null) {
        isForSelectedDate = task.endTime!.year == selectedDate.year &&
            task.endTime!.month == selectedDate.month &&
            task.endTime!.day == selectedDate.day;
      }

      // Check group filter
      bool matchesGroup = true;
      if (groupFilters[TaskGroup.all] == false) {
        matchesGroup = groupFilters[task.taskType] == true;
      }

      // Check status filter
      bool matchesStatus = true;
      if (statusFilters[TaskStatus.all] == false) {
        matchesStatus = statusFilters[task.taskState] == true;
      }

      return isForSelectedDate && matchesGroup && matchesStatus;
    }).toList();

    // Sort tasks by end time
    filteredTasks.sort((a, b) {
      if (a.endTime == null) return 1;
      if (b.endTime == null) return -1;
      return a.endTime!.compareTo(b.endTime!);
    });
  }

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }
}
