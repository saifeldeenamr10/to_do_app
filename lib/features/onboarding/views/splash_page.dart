import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../auth/views/login_page.dart';
import '../../home/manager/user_cubit/user_cubit.dart';
import '../../home/views/home_page.dart';
import '../../../core/helper/get_helper.dart';
import '../../../core/cache/cache_data.dart';
import '../../../core/cache/cache_helper.dart';
import '../../../core/cache/cache_keys.dart';
import 'on_boarding_page.dart';
import 'dart:async';
import '../../../core/utils/app_assets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    _initializeApp();
    super.initState();
  }

  Future<void> _initializeApp() async {
    try {
      CacheData.firstTime = await CacheHelper.getData(key: CacheKeys.firstTime);

      // check if first time
      if (CacheData.firstTime != null) {
        CacheData.accessToken =
            await CacheHelper.getData(key: CacheKeys.accessToken);
        CacheData.refreshToken =
            await CacheHelper.getData(key: CacheKeys.refreshToken);

        // check if the user is logged in using access token
        if (CacheData.accessToken != null && CacheData.refreshToken != null) {
          // call the api to get user data
          bool result = await UserCubit.get(context).getUserFromApi();
          if (!mounted) return;

          if (result) {
            // if succeeded to fetch user data then go home
            GetHelper.pushReplace(() => HomePage());
          } else {
            // if failed for any reason go to login
            await UserCubit.get(context).logout();
          }
        } else {
          // No tokens available, go to login
          GetHelper.pushReplace(() => LoginPage());
        }
      } else {
        // first time
        GetHelper.pushReplace(() => OnBoardingPage());
      }
    } catch (e) {
      if (!mounted) return;
      // If any error occurs, go to login
      GetHelper.pushReplace(() => LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: SvgPicture.asset(AppAssets.splash, fit: BoxFit.fill)),
    );
  }
}
