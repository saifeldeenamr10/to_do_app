// ignore_for_file: file_names

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../core/helper/get_helper.dart';
import '../../../features/home/manager/user_cubit/user_cubit.dart';
import '../../../features/options/manager/update_password_cubit/update_password_cubit.dart';
import '../../../core/translation/translation_keys.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/widgets/main_image.dart';
import '../../../core/widgets/my_custom_button.dart';
import '../../../core/widgets/my_text_form_field.dart';
import '../manager/update_password_cubit/update_password_state.dart';

class UpdatePasswordPage extends StatelessWidget {
  const UpdatePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdatePasswordCubit(),
      child: Builder(
        builder: (context) {
          var cubit = UpdatePasswordCubit.get(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  MainImage(
                    image: Image.network(
                      UserCubit.get(context).userModel?.imagePath ??
                          AppAssets.logo,
                    ),
                  ),
                  BlocConsumer<UpdatePasswordCubit, UpdatePasswordState>(
                    listener: (context, state) {
                      if (state is UpdatePasswordSuccess) {
                        log(state.message);
                        GetHelper.pop();
                      } else if (state is UpdatePasswordError) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.error)));
                        log(state.error);
                      }
                    },
                    builder: (context, state) {
                      return Form(
                        key: cubit.formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: [
                              MyTextFormField(
                                fieldType: TextFieldType.password,
                                controller: cubit.currentPass,
                                onSuffixPressed: cubit.changeVisibality,
                                obsecureText: cubit.obsecure,
                              ),
                              SizedBox(height: 30),
                              MyTextFormField(
                                fieldType: TextFieldType.password,
                                controller: cubit.newPass,
                                onSuffixPressed: cubit.changeVisibality,
                                obsecureText: cubit.obsecure,
                              ),
                              SizedBox(height: 30),
                              MyTextFormField(
                                fieldType: TextFieldType.confirmPasword,
                                controller: cubit.confirmPass,
                                onSuffixPressed: cubit.changeVisibality,
                                obsecureText: cubit.obsecure,
                                passController: cubit.newPass,
                              ),
                              SizedBox(height: 30),
                              MyCustomeButton(
                                text: TranslationKeys.update.tr,
                                isLoading: state is UpdatePasswordLoading,
                                onPressed: () {
                                  cubit.updatePassword();
                                },
                              ),
                              SizedBox(height: 25),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
