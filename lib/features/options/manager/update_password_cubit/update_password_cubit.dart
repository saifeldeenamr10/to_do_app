import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/repo/user_repo.dart';
import 'update_password_state.dart';

class UpdatePasswordCubit extends Cubit<UpdatePasswordState> {
  UpdatePasswordCubit() : super(UpdatePasswordInitial());
  static UpdatePasswordCubit get(context) => BlocProvider.of(context);

  final TextEditingController currentPass = TextEditingController();
  final TextEditingController newPass = TextEditingController();
  final TextEditingController confirmPass = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool obsecure = true;

  void updatePassword() async {
    emit(UpdatePasswordLoading());

    Future.delayed(const Duration(seconds: 2), () async {
      if (formKey.currentState!.validate()) {
        var result = await UserRepo().changePassword(
          currentPass.text,
          newPass.text,
          confirmPass.text,
        );
        result.fold(
          (error) {
            emit(UpdatePasswordError(error));
          },
          (message) {
            emit(UpdatePasswordSuccess(message));
          },
        );
      } else {
        emit(UpdatePasswordError('Please fill all fields'));
      }
    });
    // emit(UpdatePasswordError('Something Went Wrong'));
  }

  void changeVisibality() {
    obsecure = !obsecure;
    emit(ShowPassState());
  }
}
