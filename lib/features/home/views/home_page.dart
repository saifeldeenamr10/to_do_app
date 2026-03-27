import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../data/repo/tasks_repo.dart';
import '../manager/get_tasks/get_tasks_cubit.dart';
import '../manager/get_tasks/get_tasks_state.dart';
import '../manager/today_tasks_cubit/today_tasks_cubit.dart';
import '../../../core/helper/get_helper.dart';
import '../../../core/translation/translation_keys.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../add_task/views/edit_task_page.dart';
import '../../add_task/views/add_task_page.dart';
import 'today_tasks_page.dart';
import 'widgets/floating_button.dart';
import 'widgets/in_progress_task_card.dart';
import 'widgets/overall_task_container.dart';
import 'widgets/task_group_container.dart';
import 'widgets/title_with_counter.dart';
import '../../../core/wrapper/svg_wrapper.dart';
import '../data/models/task_model.dart';
import '../../options/views/options._page.dart';

import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/home_appbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  ///////////////____Functions___/////////////////
  void _onAppBartapped(BuildContext context) {
    for (var element in TasksRepo().tasks) {
      log('element: ${element.title}');
      log('element: ${element.id}');
    }
    GetHelper.push(() => const OptionsPage());
  }

  void _onViewTasksPressed(BuildContext context) {
    GetHelper.push(() => const TodayTasksPage());
  }

  void _onTaskTapped(BuildContext context, String id) async {
    await GetHelper.push(() => EditTaskPage(id: id));
    // Refresh tasks after returning from edit screen
    if (context.mounted) {
      context.read<GetTasksCubit>().getTasks();
    }
  }

  void _onGroupTapped(BuildContext context, TaskGroup group) {
    final cubit = context.read<TodayTasksCubit>();
    // Set the group filter before showing the dialog
    cubit.onGroupFilterChanged(group);
    GetHelper.push(() => const TodayTasksPage());
  }

  void _onaddTaskPressed(BuildContext context) async {
    await GetHelper.push(() => const AddTaskPage());
    // Refresh tasks after returning from add screen
    if (context.mounted) {
      context.read<GetTasksCubit>().getTasks();
    }
  }
  ///////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    ///////////////____Variables___/////////////////

    ////////////////////////////////////
    return SafeArea(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => GetTasksCubit()..getTasks()),
          BlocProvider(create: (context) => TodayTasksCubit()),
        ],
        child: Builder(
          builder: (context) {
            return BlocConsumer<GetTasksCubit, GetTasksState>(
              listener: (context, state) {
                if (state is GetTasksSuccess) {
                  log('Tasks loaded successfully: ${state.tasks.length}');
                }
              },
              builder: (context, state) {
                return Scaffold(
                  floatingActionButton: MyFloatingButton(
                    assetName: AppAssets.paperPlus,
                    onPressed: () => _onaddTaskPressed(context),
                  ),
                  appBar: HomeAppBar.build(
                    onProfilePressed: () => _onAppBartapped(context),
                  ),
                  body: (state is GetTasksSuccess && state.tasks.isNotEmpty)
                      ? _normalBody(context, state)
                      : (state is GetTasksStopLoading
                          ? _emptyBody()
                          : Center(
                              child: const CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            )),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _emptyBody() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Text(
            TranslationKeys.TherearenotasksyetnPressthebuttonnToaddNewTask.tr,
            // UserRepo().userModel.aToken ?? 'gg',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          SvgWrappe(assetName: AppAssets.emptyHome),
        ],
      ),
    );
  }

  Widget _normalBody(BuildContext context, state) {
    List<TaskModel> inProgressTasks = state.tasks
        .where((task) => task.taskState == TaskStatus.inProgress)
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              OverallTaskContainer(
                tasks: state is GetTasksSuccess ? state.tasks : [],
                onViewTasksPressed: () => _onViewTasksPressed(context),
              ),
              TitleWithCounter(
                counter: inProgressTasks.length,
                title: TranslationKeys.InProgress.tr,
              ),
              const SizedBox(height: 23),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: inProgressTasks.length,
                  itemBuilder: (_, index) {
                    return InProgressTaskCard(
                      taskModel: inProgressTasks[index],
                      onTapped: (String id) => _onTaskTapped(context, id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 26),
              Text(TranslationKeys.TaskGroups.tr, style: AppTextStyles.s14w300),
              const SizedBox(height: 23),
              Column(
                children: [
                  TaskGroupContainer(
                    taskGroup: TaskGroup.personal,
                    tasks: state.tasks,
                    onTapped: () => _onGroupTapped(context, TaskGroup.personal),
                  ),
                  const SizedBox(height: 10),
                  TaskGroupContainer(
                    taskGroup: TaskGroup.home,
                    tasks: state.tasks,
                    onTapped: () => _onGroupTapped(context, TaskGroup.home),
                  ),
                  const SizedBox(height: 10),
                  TaskGroupContainer(
                    taskGroup: TaskGroup.work,
                    tasks: state.tasks,
                    onTapped: () => _onGroupTapped(context, TaskGroup.work),
                  ),
                  SizedBox(height: 70),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
