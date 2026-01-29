import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../data/models/task_model.dart';
import '../manager/today_tasks_cubit/today_tasks_state.dart';
import '../../../core/helper/get_helper.dart';
import '../../../core/translation/translation_keys.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/widgets/simple_appbar.dart';
import '../manager/today_tasks_cubit/today_tasks_cubit.dart';

import 'widgets/filter_dialog.dart';
import 'widgets/floating_button.dart';
import 'widgets/search_field.dart';
import 'widgets/task_card.dart';
import 'widgets/title_with_counter.dart';

class TodayTasksPage extends StatelessWidget {
  const TodayTasksPage({super.key});

  void onFilterTapped(BuildContext context, cubit) {
    log('Filter tapped');
    showDialog(
      context: context,
      builder: (_) {
        return FilterDialog(cubit: cubit);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) => TodayTasksCubit(),
        child: Builder(
          builder: (context) {
            var cubit = TodayTasksCubit.get(context);
            cubit.getTasks();
            List<TaskModel> tasks = [];
            // cubit.getTasks();
            log('message');
            return Scaffold(
              appBar: SimpleAppBar.build(
                title: TranslationKeys.Tasks.tr,
                onBack: () {
                  GetHelper.pop();
                },
              ),
              floatingActionButton: MyFloatingButton(
                assetName: AppAssets.filter,
                /////// Over Here 👇
                onPressed: () => onFilterTapped(context, cubit),
              ),
              body: BlocBuilder<TodayTasksCubit, TodayTasksState>(
                builder: (context, state) {
                  tasks = cubit.filteredTasks;
                  if (tasks.isEmpty) {
                    return Center(
                      child: Text(
                        TranslationKeys.Notasksavailable.tr,
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SearchField(),
                        const SizedBox(height: 20),
                        TitleWithCounter(
                          counter: tasks.length,
                          title: TranslationKeys.Results.tr,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (_, index) {
                              return index != (tasks.length)
                                  ? (TaskCard(
                                      task: tasks[index],
                                    ))
                                  : SizedBox(height: 80);
                            },
                            itemCount: tasks.length + 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
