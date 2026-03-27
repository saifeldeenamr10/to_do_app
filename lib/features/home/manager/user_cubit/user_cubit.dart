import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/data/repo/user_repo.dart';
import '../../../auth/data/models/user_model.dart';
import 'user_state.dart';
import '../../../../core/cache/cache_data.dart';
import '../../../../core/helper/get_helper.dart';
import '../../../auth/views/login_page.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial()) {
    _initializeUserData();
  }

  static UserCubit get(context) => BlocProvider.of(context);
  UserModel? userModel;

  void _initializeUserData() {
    if (CacheData.userModel != null) {
      userModel = CacheData.userModel;
      emit(UserDataSuccessState(userModel: userModel!));
    }
  }

  void getUser(UserModel user) {
    userModel = user;
    emit(UserDataSuccessState(userModel: user));
  }

  Future<void> logout() async {
    await UserRepo().logout();
    GetHelper.pushReplaceAll(() => const LoginPage());
  }

  // Update these when profile update is implemented in UserRepo
  void updateUserName(String name, XFile? image) async {
    // To be implemented with Firestore
  }
}
