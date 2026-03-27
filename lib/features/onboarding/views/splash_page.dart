import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/views/login_page.dart';
import '../../home/manager/user_cubit/user_cubit.dart';
import '../../home/views/home_page.dart';
import '../../../core/helper/get_helper.dart';
import '../../../core/cache/cache_data.dart';
import '../../../core/cache/cache_helper.dart';
import '../../../core/cache/cache_keys.dart';
import 'on_boarding_page.dart';
import '../../../core/utils/app_assets.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/data/repo/user_repo.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/services/firestore_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Check Onboarding
      CacheData.firstTime = await CacheHelper.getData(key: CacheKeys.firstTime);
      if (CacheData.firstTime == null) {
        GetHelper.pushReplace(() => const OnBoardingPage());
        return;
      }

      // 2. Check Auth Status
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 3. Fetch User Data
        final doc = await FirestoreService().getDocument(
          collection: FirebaseConstants.usersCollection,
          docId: user.uid,
        );

        if (doc.exists) {
          final userModel = UserModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
          CacheData.userModel = userModel;
          if (mounted) {
            UserCubit.get(context).getUser(userModel);
            GetHelper.pushReplace(() => const HomePage());
          }
        } else {
          await UserRepo().logout();
          GetHelper.pushReplace(() => const LoginPage());
        }
      } else {
        GetHelper.pushReplace(() => const LoginPage());
      }
    } catch (e) {
      if (mounted) GetHelper.pushReplace(() => const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: SvgPicture.asset(AppAssets.splash, fit: BoxFit.fill)),
    );
  }
}
