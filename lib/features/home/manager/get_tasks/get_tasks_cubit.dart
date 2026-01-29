import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helper/app_logger.dart';
import '../../data/repo/tasks_repo.dart';
import 'get_tasks_state.dart';

class GetTasksCubit extends Cubit<GetTasksState> {
  GetTasksCubit() : super(GetTasksInitialState());

  static GetTasksCubit get(context) => BlocProvider.of(context);

  void getTasks() async {
    TasksRepo tasksRepo = TasksRepo();
    AppLogger.bgMagenta('getTasks called');
    var result = await tasksRepo.getTasks();
    result.fold(
      (error) {
        emit(GetTasksError(error: error));
      },
      (message) {
        if (tasksRepo.tasks.isEmpty) {
          emit(GetTasksStopLoading());
        } else {
          emit(GetTasksSuccess(tasks: tasksRepo.tasks));
        }
      },
    );
  }

  void stopLoading() {
    Future.delayed(const Duration(seconds: 1), () {
      emit(GetTasksStopLoading());
    });
  }
}
