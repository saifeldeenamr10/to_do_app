import 'package:flutter/material.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/wrapper/svg_wrapper.dart';
import '../../data/models/task_model.dart';

class InProgressTaskCard extends StatelessWidget {
  const InProgressTaskCard({super.key, required this.taskModel, this.onTapped});
  final TaskModel taskModel;
  final double width = 230;
  final double height = 90;
  final void Function(int id)? onTapped;

  @override
  Widget build(BuildContext context) {
    switch (taskModel.taskType) {
      case TaskGroup.personal:
        return _personalTaskCard();
      case TaskGroup.work:
        return _workTaskCard();
      case TaskGroup.home:
        return _homeTaskCard();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _personalTaskCard() {
    return _generalTaskCard(
      icon: AppAssets.personalVector,
      outerColor: AppColors.primaryColor,
      innerColor: AppColors.lightGreen,
      backGroundColor: AppColors.lightGreen,
      typeTextStyle: AppTextStyles.s14w300.copyWith(color: AppColors.grey),
      descriptionTextStyle: AppTextStyles.s14w300,
    );
  }

  Widget _workTaskCard() {
    return _generalTaskCard(
      icon: AppAssets.workVector,
      outerColor: AppColors.primaryColor,
      innerColor: AppColors.white,
      backGroundColor: AppColors.black,
      typeTextStyle: AppTextStyles.s12w400.copyWith(color: AppColors.white),
      descriptionTextStyle: AppTextStyles.s14w300.copyWith(
        color: AppColors.white,
      ),
    );
  }

  Widget _homeTaskCard() {
    return _generalTaskCard(
      icon: AppAssets.homeVector,
      outerColor: AppColors.darkPink,
      innerColor: AppColors.lightPink,
      backGroundColor: AppColors.lightPink,
      typeTextStyle: AppTextStyles.s14w300.copyWith(color: AppColors.grey),
      descriptionTextStyle: AppTextStyles.s14w500.copyWith(
        color: AppColors.black,
      ),
    );
  }

  Widget _generalTaskCard({
    String? icon,
    Color? outerColor,
    Color? innerColor,
    Color? backGroundColor,
    TextStyle? typeTextStyle,
    TextStyle? descriptionTextStyle,
  }) {
    return InkWell(
      onTap: () => onTapped!(taskModel.id),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsetsDirectional.only(end: 10),
        decoration: BoxDecoration(
          color: backGroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${taskModel.taskType.name} Task', style: typeTextStyle),
                Container(
                  height: 20,
                  width: 20,
                  padding: const EdgeInsets.all(4),

                  decoration: BoxDecoration(
                    color: outerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: SvgWrappe(assetName: icon ?? '', color: innerColor),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              taskModel.description,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: descriptionTextStyle,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
