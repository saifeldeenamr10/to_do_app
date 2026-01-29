import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helper/get_helper.dart';
import '../../manager/today_tasks_cubit/today_tasks_cubit.dart';
import 'package:get/get.dart'; // Add this import for `.tr`

import '../../../../core/translation/translation_keys.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/my_custom_button.dart';
import '../../data/models/task_model.dart';
import '../../manager/today_tasks_cubit/today_tasks_state.dart';

class FilterDialog extends StatelessWidget {
  const FilterDialog({super.key, required this.cubit});
  final TodayTasksCubit cubit;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      child: BlocProvider.value(
        value: cubit,
        child: Builder(
          builder: (context) {
            return BlocConsumer<TodayTasksCubit, TodayTasksState>(
              listener: (context, state) {
                if (state is GetTasksLoading) {
                  // Show loading indicator if needed
                } else if (state is GetTasksError) {
                  Get.snackbar(
                    'Error',
                    state.errorMessage,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: AppColors.white,
                  );
                } else if (state is GetTasksSuccess) {
                  // Update UI with filtered tasks
                  GetHelper.pop();
                }
              },
              builder: (context, state) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppColors.white,
                  shadowColor: AppColors.black.withAlpha((.25 * 255).toInt()),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 15,
                          runSpacing: 10,
                          children: [
                            ...cubit.groupFilters.entries.map(
                              (entry) => _groupContainer(entry.key, cubit),
                            ),
                          ],
                        ),
                        const SizedBox(height: 37),
                        Wrap(
                          spacing: 15,
                          runSpacing: 10,
                          children: [
                            ...cubit.statusFilters.entries.map(
                              (entry) => _statusContainer(entry.key, cubit),
                            ),
                          ],
                        ),
                        const SizedBox(height: 37),
                        DateField(
                          dateTime: cubit.selectedDate,
                          onDateChanged: (date) {
                            if (date != null) {
                              cubit.onDateSelected(date);
                            }
                          },
                        ),
                        const SizedBox(height: 22),
                        MyCustomeButton(
                          text: TranslationKeys.filter.tr,
                          onPressed: () {
                            cubit.getTasks();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _groupContainer(TaskGroup group, TodayTasksCubit cubit) {
    return _tagContainer(
      tag: _getGroupTag(group),
      selected: cubit.groupFilters[group]!,
      group: group,
      cubit: cubit,
    );
  }

  Widget _statusContainer(TaskStatus status, TodayTasksCubit cubit) {
    return _tagContainer(
      tag: _getStatusTag(status),
      selected: cubit.statusFilters[status]!,
      status: status,
      cubit: cubit,
    );
  }

  Widget _tagContainer({
    required String tag,
    required bool selected,
    TaskGroup? group,
    TaskStatus? status,
    required TodayTasksCubit cubit,
  }) {
    return InkWell(
      onTap: () {
        group != null
            ? cubit.onGroupFilterChanged(group)
            : cubit.onStatusFilterChanged(status!);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 0.5,
            color: selected ? Colors.transparent : AppColors.black,
          ),
        ),
        child: Text(
          tag,
          style: selected
              ? AppTextStyles.s12w600.copyWith(color: AppColors.white)
              : AppTextStyles.s12w300.copyWith(color: AppColors.black),
        ),
      ),
    );
  }

  String _getGroupTag(TaskGroup group) {
    switch (group) {
      case TaskGroup.home:
        return TranslationKeys.home.tr;
      case TaskGroup.work:
        return TranslationKeys.work.tr;
      case TaskGroup.personal:
        return TranslationKeys.personal.tr;
      case TaskGroup.all:
        return TranslationKeys.all.tr;
    }
  }

  String _getStatusTag(TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return TranslationKeys.done.tr;
      case TaskStatus.missed:
        return TranslationKeys.missed.tr;
      case TaskStatus.inProgress:
        return TranslationKeys.inProgress.tr;
      case TaskStatus.all:
        return TranslationKeys.all.tr;
    }
  }
}
