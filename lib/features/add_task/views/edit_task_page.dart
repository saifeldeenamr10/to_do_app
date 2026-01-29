import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart'; // Add this import for `.tr`
import '../../home/manager/user_cubit/user_cubit.dart';
import '../../../core/helper/get_helper.dart';
import '../manager/edit_task_cubit/edit_task_cubit.dart';
import '../../home/views/home_page.dart';

import '../../../core/translation/translation_keys.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/my_custom_button.dart';
import '../../../core/widgets/my_text_form_field.dart';
import '../../../core/widgets/simple_appbar.dart';
import '../manager/edit_task_cubit/edit_task_state.dart';
import 'widgets/edit_task_header.dart';

class EditTaskPage extends StatelessWidget {
  const EditTaskPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) => EditTaskCubit(),
        child: Builder(
          builder: (context) {
            var cubit = BlocProvider.of<EditTaskCubit>(context);
            cubit.displayTask(id);
            return BlocConsumer<EditTaskCubit, EditTaskState>(
              listener: (context, state) {
                if (state is EditTaskLoadingState) {
                } else if (state is DeleteTaskSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  GetHelper.pushReplaceAll(() => HomePage());
                } else if (state is EditTaskSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  GetHelper.pushReplaceAll(() => HomePage());
                } else if (state is EditTaskErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Scaffold(
                  appBar: SimpleAppBar.build(
                    title: TranslationKeys.editTask.tr, // Replaced string
                    isDelete: true,
                    onBack: () {
                      Navigator.pop(context);
                    },
                    onDelete: () {
                      cubit.deleteTask(id);
                    },
                  ),
                  body: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    child: Form(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 10),
                            EditTaskHeader(
                              image: cubit.imagePath ??
                                  UserCubit.get(context).userModel?.imagePath ??
                                  'https://via.placeholder.com/150',
                            ),
                            SizedBox(height: 20),
                            Form(
                              key: cubit.formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyTextFormField(
                                    selectedDropDownValue: cubit.group,
                                    fieldType: TextFieldType.group,
                                    controller: cubit.groupController,
                                    items: cubit.groups,
                                    onDropDownChanged: (value) {
                                      cubit.changeGroup(value);
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  MyTextFormField(
                                    fieldType: TextFieldType.taskTitle,
                                    controller: cubit.titleController,
                                  ),
                                  SizedBox(height: 15),
                                  MyTextFormField(
                                    fieldType: TextFieldType.taskDescribtion,
                                    controller: cubit.descriptionController,
                                  ),
                                  SizedBox(height: 15),
                                  BlocBuilder<EditTaskCubit, EditTaskState>(
                                    buildWhen: (previous, current) {
                                      return current is EditTaskChangeDate;
                                    },
                                    builder: (context, state) {
                                      return DateField(
                                        dateTime: cubit.endDate,
                                        onDateChanged: (selectedDate) {
                                          if (selectedDate != null) {
                                            cubit.changeDate(selectedDate);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(height: 30),
                                  MyCustomeButton(
                                    text: TranslationKeys
                                        .markAsDone.tr, // Replaced string
                                    onPressed: () {
                                      cubit.markTaskAsDone(id);
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  MyCustomeButton(
                                    text: TranslationKeys
                                        .update.tr, // Replaced string
                                    onPressed: () {
                                      cubit.editTask(id);
                                    },
                                    isOutlinedButton: true,
                                    isLoading: state is EditTaskLoadingState,
                                  ),
                                  SizedBox(height: 50),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
