import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart'; // Add this import for `.tr`

import '../../features/home/manager/user_cubit/user_cubit.dart';
import '../../features/home/manager/user_cubit/user_state.dart';
import '../translation/translation_keys.dart';
import '../utils/app_assets.dart';
import '../utils/app_colors.dart';

abstract class HomeAppBar {
  static AppBar build({void Function()? onProfilePressed, bool action = true}) {
    return AppBar(
      leading: null,
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      title: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
            child: InkWell(
              onTap: onProfilePressed,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.scaffoldBackground,
                      child: ClipOval(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: state is UserLoadingState
                              ? null
                              : state is UserDataSuccessState &&
                                      state.userModel.imagePath != null
                                  ? Image.network(
                                      state.userModel.imagePath!,
                                      fit: BoxFit.cover,
                                      width: 70,
                                      height: 70,
                                    )
                                  : Image.asset(
                                      AppAssets.logo,
                                      fit: BoxFit.cover,
                                      width: 70,
                                      height: 70,
                                    ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationKeys.hello.tr, // Replaced string
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: AppColors.black,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        state is UserLoadingState
                            ? ''
                            : state is UserDataSuccessState &&
                                    state.userModel.imagePath != null
                                ? state.userModel.username!
                                : TranslationKeys
                                    .adventurer.tr, // Replaced string
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
