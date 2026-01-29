import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/wrapper/svg_wrapper.dart';

class MyFloatingButton extends StatelessWidget {
  const MyFloatingButton({super.key, this.onPressed, required this.assetName});
  final void Function()? onPressed;
  final String assetName;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppColors.primaryColor,
        elevation: 4,
        shape: CircleBorder(),
        child: SvgWrappe(assetName: assetName),
      ),
    );
  }
}
