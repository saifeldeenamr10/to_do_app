import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../core/translation/translation_keys.dart';
import '../../../core/helper/get_helper.dart';
import '../../home/manager/user_cubit/user_cubit.dart';
import '../manager/update_username_cubit/update_username_cubit.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/widgets/main_image.dart';
import '../../../core/widgets/my_custom_button.dart';
import '../../../core/widgets/my_text_form_field.dart';
import '../manager/update_username_cubit/update_username._state.dart';

class UpdateUsernamePage extends StatelessWidget {
  const UpdateUsernamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdateUsernameCubit(),
      child: Builder(
        builder: (context) {
          var cubit = UpdateUsernameCubit.get(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  BlocBuilder<UpdateUsernameCubit, UpdateUsernameState>(
                    builder: (context, state) {
                      return MainImage(
                        onTap: () {
                          try {
                            cubit.changeImage();
                          } on Exception catch (e) {
                            log('Image picker error: $e');
                          }
                        },
                        // This whole thing just to avoid null in every way
                        // once we have an initial user model like usual we will minimize this code
                        image: cubit.imageFile == null
                            ? (UserCubit.get(
                                      context,
                                    ).userModel?.imagePath !=
                                    null
                                ? Image.network(
                                    UserCubit.get(
                                          context,
                                        ).userModel?.imagePath ??
                                        '',
                                  )
                                : Image.asset(AppAssets.logo))
                            : Image.file(File(cubit.imageFile!.path)),
                      );
                    },
                  ),
                  Form(
                    key: cubit.formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          MyTextFormField(
                            fieldType: TextFieldType.username,
                            controller: cubit.usernameController,
                          ),
                          SizedBox(height: 30),
                          BlocConsumer<UpdateUsernameCubit,
                              UpdateUsernameState>(
                            listener: (context, state) {
                              if (state is UpdateUsernameSuccess) {
                                GetHelper.pop();
                              } else if (state is UpdateUsernameError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.error)),
                                );
                              }
                            },
                            builder: (context, state) {
                              return MyCustomeButton(
                                text: TranslationKeys.update.tr,
                                isLoading: state is UpdateUsernameLoading,
                                onPressed: () {
                                  // AppLogger.magenta(
                                  //   '${UserCubit.get(context).userModel?.username}',
                                  // );
                                  cubit.updateUsername(UserCubit.get(context));
                                },
                              );
                            },
                          ),
                          SizedBox(height: 25),
                        ],
                      ),
                    ),
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
