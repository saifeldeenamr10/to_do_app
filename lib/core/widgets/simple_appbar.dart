import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart'; // Add this import for `.tr`

import '../translation/translation_keys.dart';
import '../utils/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../wrapper/svg_wrapper.dart';

class SimpleAppBar {
  static AppBar build({
    required String title,
    void Function()? onBack,
    bool isDelete = false,
    void Function()? onDelete,
  }) {
    return AppBar(
      leading: IconButton(
        icon: SvgPicture.asset(AppAssets.arrowLeft),
        onPressed: onBack,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w300,
          color: AppColors.black,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.scaffoldBackground,

      actions:
          isDelete
              ? [
                InkWell(
                  onTap: onDelete,
                  child: Container(
                    margin: EdgeInsetsDirectional.only(end: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.lightRed,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        SvgWrappe(assetName: AppAssets.delete),
                        SizedBox(width: 5),
                        Text(
                          TranslationKeys.delete.tr, // Replaced string
                          style: AppTextStyles.s12w300.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
              : [],
    );
  }
}
