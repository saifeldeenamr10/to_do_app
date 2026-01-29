import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../core/translation/translation_keys.dart';
import '../../../core/helper/get_helper.dart';

import '../../../core/utils/app_assets.dart';
import '../../home/manager/user_cubit/user_cubit.dart';
import '../../home/views/home_page.dart';
import '../manager/add_task_cubit/add_task_cubit.dart';
import '../../../core/widgets/date_field.dart';
import '../manager/add_task_cubit/add_task_state.dart';
import 'widgets/add_task_image.dart';

import '../../../core/widgets/my_custom_button.dart';
import '../../../core/widgets/my_text_form_field.dart';
import '../../../core/widgets/simple_appbar.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddTaskCubit(),
      child: Builder(
        builder: (context) {
          var cubit = AddTaskCubit.get(context);
          return Scaffold(
            appBar: SimpleAppBar.build(
              title: TranslationKeys.addTask.tr,
              onBack: () {
                Navigator.pop(context);
              },
            ),
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: Form(
                key: cubit.formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      BlocBuilder<AddTaskCubit, AddTaskState>(
                        builder: (context, state) {
                          return AddTaskImage(
                            onTap: () {
                              try {
                                cubit.changeImage();
                              } on Exception catch (e) {
                                log('Image picker error: $e');
                              }
                            },
                            image: cubit.imageFile != null
                                ? Image.file(
                                    File(cubit.imageFile!.path),
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    UserCubit.get(context)
                                            .userModel
                                            ?.imagePath ??
                                        'https://via.placeholder.com/150',
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        AppAssets.logo,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                          );
                        },
                      ),
                      SizedBox(height: 30),
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
                      BlocBuilder<AddTaskCubit, AddTaskState>(
                        buildWhen: (previous, current) {
                          return current is AddTaskChangeGroup;
                        },
                        builder: (context, state) {
                          return MyTextFormField(
                            selectedDropDownValue: cubit.group,
                            fieldType: TextFieldType.group,
                            controller: cubit.groupController,
                            items: cubit.groups,
                            onDropDownChanged: (value) {
                              cubit.changeGroup(value);
                            },
                          );
                        },
                      ),
                      SizedBox(height: 15),
                      BlocBuilder<AddTaskCubit, AddTaskState>(
                        buildWhen: (previous, current) {
                          return current is AddTaskChangeDate;
                        },
                        builder: (context, state) {
                          return DateField(
                            dateTime: cubit.endDate,
                            onDateChanged: (selectedDate) {
                              cubit.changeDate(selectedDate!);
                            },
                          );
                        },
                      ),
                      SizedBox(height: 15),
                      BlocConsumer<AddTaskCubit, AddTaskState>(
                        listener: (context, state) {
                          if (state is AddTaskSuccess) {
                            GetHelper.pushReplaceAll(() => HomePage());
                          } else if (state is AddTaskError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.errorMessage),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          return MyCustomeButton(
                            text: TranslationKeys.addTask.tr,
                            isLoading: state is AddTaskLoading,
                            onPressed: () {
                              cubit.addTaskApi();
                            },
                          );
                        },
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
