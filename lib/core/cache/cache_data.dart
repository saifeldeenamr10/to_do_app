import '../../features/auth/data/models/user_model.dart';

abstract class CacheData {
  static bool? firstTime;
  static UserModel? userModel;
  static bool? loggedIn;
  static String? lang;
  static String? accessToken;
  static String? refreshToken;
}
