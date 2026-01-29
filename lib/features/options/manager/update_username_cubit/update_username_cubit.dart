import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../home/manager/user_cubit/user_cubit.dart';
import 'update_username._state.dart';

class UpdateUsernameCubit extends Cubit<UpdateUsernameState> {
  UpdateUsernameCubit() : super(UpdateUsernameInitial());

  static UpdateUsernameCubit get(context) => BlocProvider.of(context);

  TextEditingController usernameController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  XFile? imageFile;
  void changeImage() async {
    final ImagePicker picker = ImagePicker();
    imageFile = await picker.pickImage(source: ImageSource.gallery);

    emit(UpdateUsernameImageSuccess());
  }

  void updateUsername(UserCubit userCubit) {
    emit(UpdateUsernameLoading());
    log('name from UpdateUsernameCubit: ${usernameController.text}');
    Future.delayed(const Duration(seconds: 2), () {
      if (formKey.currentState!.validate()) {
        userCubit.updateUserName(usernameController.text, imageFile);

        // Check if imageFile is not null before updating the user image
        // -------> user didn't change the image <-------
        // if (imageFile != null) {
        //   userCubit.updateUserImage(imageFile!);
        // }

        emit(UpdateUsernameSuccess(usernameController.text));
      } else {
        emit(UpdateUsernameError('Invalid username'));
      }
    });
  }
}
