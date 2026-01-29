import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/translation/translation_keys.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../home/data/models/task_model.dart';

class EditTaskHeader extends StatelessWidget {
  const EditTaskHeader({
    super.key,
    this.taskStatus = TaskStatus.inProgress,
    required this.image,
  });
  final TaskStatus taskStatus;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 100,
      width: double.infinity,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withAlpha((.25 * 255).toInt()),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              child: ClipOval(
                child: image != null
                    ? Image.network(
                        image!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            AppAssets.logo,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        AppAssets.logo,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: AppTextStyles.s14w300.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 5),
                Text(
                  _subTitle,
                  //overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.s14w300.copyWith(color: AppColors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _title {
    switch (taskStatus) {
      case TaskStatus.inProgress:
        return TranslationKeys.InProgress.tr;
      case TaskStatus.done:
        return TranslationKeys.Done.tr;
      case TaskStatus.missed:
        return TranslationKeys.MissedTask.tr;
      default:
        return TranslationKeys.InProgress.tr;
    }
  }

  String get _subTitle {
    switch (taskStatus) {
      case TaskStatus.inProgress:
        return TranslationKeys.Believeyouanandyourehalfwaythere.tr;
      case TaskStatus.done:
        return TranslationKeys.Congrats.tr;
      case TaskStatus.missed:
        return TranslationKeys.ThereisAlwaysanotherchance.tr;
      default:
        return TranslationKeys.Believeyouanandyourehalfwaythere.tr;
    }
  }
}
