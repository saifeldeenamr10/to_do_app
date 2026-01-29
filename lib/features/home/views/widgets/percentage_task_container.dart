// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../core/translation/translation_keys.dart';
// import '../../../../core/utils/app_colors.dart';
// import '../../../../core/utils/app_text_styles.dart';
// import '../../data/models/task_model.dart';

// class OverallTaskContainer extends StatelessWidget {
//   const OverallTaskContainer({
//     super.key,
//     required this.tasks,
//     this.onViewTasksPressed,
//   });
//   final List<TaskModel> tasks;
//   final void Function()? onViewTasksPressed;

//   @override
//   Widget build(BuildContext context) {
//     // Calculate the percentage of completed tasks
//     int completedTasks =
//         tasks.where((task) => task.taskState == TaskStatus.done).length;
//     int totalTasks = tasks.length;
//     double completionPercentage =
//         totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

//     return Container(
//       width: double.infinity,
//       height: 135,
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
//       decoration: BoxDecoration(
//         color: AppColors.primaryColor,
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             TranslationKeys.yourTodaysTasksAlmostDone.tr,
//             style: AppTextStyles.s14w400,
//           ),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     completionPercentage.toStringAsFixed(1),
//                     style: AppTextStyles.s40w500,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     '%',
//                     style: AppTextStyles.s40w500.copyWith(fontSize: 20),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 width: 130,
//                 height: 36,
//                 child: ElevatedButton(
//                   onPressed: onViewTasksPressed,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: Text(
//                     TranslationKeys.viewTasks.tr,
//                     textAlign: TextAlign.center,
//                     style: AppTextStyles.s15w400,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
