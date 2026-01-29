import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/translation/translation_keys.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/wrapper/svg_wrapper.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14,
        ),
        hintText: TranslationKeys.Search.tr,
        hintStyle: AppTextStyles.s14w200.copyWith(color: AppColors.grey),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgWrappe(assetName: AppAssets.search),
        ),
      ),
    );
  }
}
