import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repo/user_repo.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  int? selectedGender = 0;
  bool visibality = true;
  final formKey = GlobalKey<FormState>();

  static RegisterCubit get(context) => BlocProvider.of(context);

  void onGenderSelected(int? value) {
    selectedGender = value;
  }

  void onChangeVisibalityPresed() {
    visibality = !visibality;
    emit(RegisterShowPassState());
  }

  XFile? imageFile;
  void onChangeImage() async {
    final ImagePicker imagePicker = ImagePicker();
    imageFile = await imagePicker.pickImage(source: ImageSource.gallery);
    emit(RegisterChangeImageState());
  }

  void onSignupPressed() async {
    emit(RegisterLoading());
    Future.delayed(const Duration(seconds: 2), () async {
      if (!formKey.currentState!.validate()) {
        emit(RegisterError());
        return;
      }
      // ######## using API #########
      var result = await UserRepo().register(
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        image: imageFile,
      );
      result.fold(
        (error) {
          // left
          emit(RegisterError(errorMessage: error));
        },
        (r) {
          // right
          emit(RegisterSuccess(userModel: r));
        },
      );
    });
  }
}
