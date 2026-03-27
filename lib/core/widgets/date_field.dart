import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../wrapper/svg_wrapper.dart';

class DateField extends StatelessWidget {
  const DateField({super.key, this.dateTime, this.onDateChanged});
  final DateTime? dateTime;
  final void Function(DateTime?)? onDateChanged;

  @override
  Widget build(BuildContext context) {
    final initialDate = DateTime.now().add(const Duration(days: 1));
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: TextField(
        readOnly: true,
        onTap: () async {
          try {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: dateTime ?? initialDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: AppColors.primaryColor,
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primaryColor,
                    ),
                    buttonTheme: const ButtonThemeData(
                      textTheme: ButtonTextTheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null && onDateChanged != null) {
              onDateChanged!(pickedDate);
            }
          } catch (e) {
            // Handle any errors that might occur during date picker
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to select date: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        canRequestFocus: false,
        decoration: InputDecoration(
          label: Text(
            DateFormat(
              'd MMMM, y\t h:mm a',
            ).format(dateTime ?? initialDate).toString(),
            style: AppTextStyles.s14w300.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgWrappe(assetName: AppAssets.calender),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}
