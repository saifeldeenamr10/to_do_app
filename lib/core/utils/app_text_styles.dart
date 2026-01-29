import 'package:flutter/painting.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static const String fontFamily = 'Lexend Deca';

  static final TextStyle s10w600 = const TextStyle(
    color: AppColors.black,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle s14w300 = const TextStyle(
    color: AppColors.black,
    fontSize: 14,
    fontWeight: FontWeight.w300,
  );
  static final TextStyle s14w200 = const TextStyle(
    color: AppColors.black,
    fontSize: 14,
    fontWeight: FontWeight.w200,
  );

  static final TextStyle s14w400 = const TextStyle(
    color: AppColors.white,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static final TextStyle s14w500 = const TextStyle(
    color: AppColors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle s12w300 = const TextStyle(
    color: AppColors.white,
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );
  static final TextStyle s12w400 = const TextStyle(
    color: AppColors.white,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  static final TextStyle s12w600 = const TextStyle(
    color: AppColors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle s40w500 = const TextStyle(
    color: AppColors.white,
    fontSize: 40,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle s15w400 = const TextStyle(
    color: AppColors.primaryColor,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );
}
