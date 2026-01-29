import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class MyCustomeButton extends StatelessWidget {
  const MyCustomeButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlinedButton = false,
  });
  final String text;
  final void Function()? onPressed;
  final bool isLoading;
  final bool isOutlinedButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: isOutlinedButton ? _outlinedButtonStyle() : _filledButtonStyle(),

        child:
            isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                  text,
                  style: TextStyle(
                    color:
                        isOutlinedButton
                            ? AppColors.primaryColor
                            : AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w300,
                  ),
                ),
      ),
    );
  }

  ButtonStyle _filledButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      elevation: 5,

      shadowColor: AppColors.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: AppColors.primaryColor, width: 1),
      ),
    );
  }

  ButtonStyle _outlinedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.white,
      elevation: 5,

      shadowColor: AppColors.primaryColor,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: AppColors.primaryColor, width: 1),
      ),
    );
  }
}
