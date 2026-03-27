import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../data/repo/user_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitState());

  static LoginCubit get(context) => BlocProvider.of(context);

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool visibality = true;

  void onChangeVisibalityPresed() {
    visibality = !visibality;
    emit(LoginShowPassState());
  }

  void onLoginPressed() async {
    if (!formKey.currentState!.validate()) return;

    // Clear any previous error messages
    emit(LoginInitState());

    // Show loading state
    emit(LoginLoadingState());

    UserRepo userRepo = UserRepo();
    var result = await userRepo.login(
      email: emailController.text,
      password: passwordController.text,
    );

    result.fold(
      (error) {
        emit(LoginErrorState(errorMessage: error));
        log('Login error: $error');

        // Show error message to user
        Get.snackbar(
          'Login Failed',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      },
      (userModel) {
        emit(LoginSuccessState(userModel: userModel));
        log('Login success: ${userModel.imagePath ?? ''}');
      },
    );
  }
}
