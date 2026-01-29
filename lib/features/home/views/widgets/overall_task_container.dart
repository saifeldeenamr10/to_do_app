import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/translation/translation_keys.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../data/models/task_model.dart';
import '../../manager/today_tasks_cubit/today_tasks_cubit.dart';
import '../../manager/today_tasks_cubit/today_tasks_state.dart';

class OverallTaskContainer extends StatelessWidget {
  const OverallTaskContainer({
    super.key,
    required this.tasks,
    this.onViewTasksPressed,
  });
  final List<TaskModel> tasks;
  final void Function()? onViewTasksPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodayTasksCubit, TodayTasksState>(
      builder: (context, state) {
        // Calculate the percentage of completed tasks
        int completedTasks =
            tasks.where((task) => task.taskState == TaskStatus.done).length;
        int totalTasks = tasks.length;
        double completionPercentage =
            totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

        return Container(
          width: double.infinity,
          height: 135,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TranslationKeys.yourTodaysTasksAlmostDone.tr,
                style: AppTextStyles.s14w400,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          completionPercentage.toStringAsFixed(1),
                          style: AppTextStyles.s40w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '%',
                          style: AppTextStyles.s40w500.copyWith(fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onViewTasksPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            TranslationKeys.viewTasks.tr,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.s15w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
