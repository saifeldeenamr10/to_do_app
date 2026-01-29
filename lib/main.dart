import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'core/helper/app_logger.dart';
import 'core/cache/cache_data.dart';
import 'core/translation/translation_helper.dart';
import 'core/cache/cache_helper.dart';
import 'core/utils/app_text_styles.dart';
import 'core/utils/app_colors.dart';
import 'features/home/manager/user_cubit/user_cubit.dart';
import 'features/onboarding/views/on_boarding_page.dart';
import 'features/onboarding/views/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize cache first
  await CacheHelper.init();
  AppLogger.bgGreen('Running App .......');
  // Set up language
  await TranslationHelper.setLanguage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(),
      child: Builder(
        builder: (context) {
          return GetMaterialApp(
            locale: CacheData.lang != null
                ? Locale(CacheData.lang!)
                : const Locale('en'),
            translations: TranslationHelper(),
            title: 'To-Do',
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            getPages: [
              GetPage(name: '/', page: () => const SplashPage()),
              GetPage(
                  name: '/OnBoardingPage', page: () => const OnBoardingPage()),
            ],
            theme: ThemeData(
              fontFamily: AppTextStyles.fontFamily,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              scaffoldBackgroundColor: AppColors.scaffoldBackground,
            ),
          );
        },
      ),
    );
  }
}
