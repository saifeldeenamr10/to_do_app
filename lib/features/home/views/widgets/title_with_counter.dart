import 'package:flutter/cupertino.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';

class TitleWithCounter extends StatelessWidget {
  const TitleWithCounter({
    super.key,
    required this.counter,
    required this.title,
  });
  final int counter;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.s14w300),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 20),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: AppColors.lightGreen,
          ),
          child: Text(
            counter.toString(),
            style: AppTextStyles.s14w400.copyWith(
              color: AppColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
