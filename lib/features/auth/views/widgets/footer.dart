import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

class MyFooter extends StatelessWidget {
  const MyFooter({
    super.key,
    required this.title,
    this.onPressed,
    required this.action,
  });
  final String title;
  final String action;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(width: 15),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.grey,
            shadowColor: Colors.transparent,
            overlayColor: Colors.transparent,
          ),
          child: Text(
            action,
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
