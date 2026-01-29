import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/helper/get_helper.dart';
import '../../../core/translation/translation_keys.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/widgets/image_manager/image_manager_view.dart';
import '../../../core/widgets/my_custom_button.dart';
import '../../../core/widgets/my_text_form_field.dart';
import '../manager/register_cubit/register_cubit.dart';
import '../manager/register_cubit/register_state.dart';
import 'login_page.dart';
import 'widgets/footer.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: Scaffold(
        body: Builder(
          builder: (context) {
            var cubit = RegisterCubit.get(context);
            return SingleChildScrollView(
              child: Column(
                children: [
                  BlocBuilder<RegisterCubit, RegisterState>(
                    builder: (context, state) {
                      return ImageManagerView(
                        onPicked: (XFile image) {
                          cubit.imageFile = image;
                        },
                        pickedBody: (XFile image) {
                          return Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              image: DecorationImage(
                                image: FileImage(File(image.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        unPickedBody: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: Image.asset(
                            AppAssets.logo,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.36,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  Form(
                    key: cubit.formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          MyTextFormField(
                            fieldType: TextFieldType.username,
                            controller: cubit.usernameController,
                          ),
                          SizedBox(height: 15),
                          BlocBuilder<RegisterCubit, RegisterState>(
                            buildWhen: (previous, current) {
                              return current is RegisterShowPassState;
                            },
                            builder: (context, state) {
                              return MyTextFormField(
                                fieldType: TextFieldType.password,
                                onSuffixPressed: cubit.onChangeVisibalityPresed,
                                controller: cubit.passwordController,
                                obsecureText: cubit.visibality,
                              );
                            },
                          ),
                          SizedBox(height: 15),
                          BlocBuilder<RegisterCubit, RegisterState>(
                            buildWhen: (previous, current) {
                              return current is RegisterShowPassState;
                            },
                            builder: (context, state) {
                              return MyTextFormField(
                                fieldType: TextFieldType.confirmPasword,
                                obsecureText: cubit.visibality,
                                passController: cubit.passwordController,
                                onSuffixPressed: cubit.onChangeVisibalityPresed,
                                controller: cubit.confirmPassController,
                              );
                            },
                          ),
                          SizedBox(height: 15),
                          BlocConsumer<RegisterCubit, RegisterState>(
                            listener: (context, state) async {
                              if (state is RegisterError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(state.errorMessage ?? '')),
                                );
                              } else if (state is RegisterSuccess) {
                                GetHelper.pushReplace(() => LoginPage());
                              }
                            },
                            builder: (context, state) {
                              return MyCustomeButton(
                                isLoading: state is RegisterLoading,
                                text: TranslationKeys.register.tr,
                                onPressed: () {
                                  cubit.onSignupPressed();
                                },
                              );
                            },
                          ),
                          SizedBox(height: 25),
                          MyFooter(
                            title: TranslationKeys
                                .alreadyHaveAnAccount.tr, // Replaced string
                            action: TranslationKeys.login.tr, // Replaced string
                            onPressed: () {
                              GetHelper.pushReplace(() => LoginPage());
                            },
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
