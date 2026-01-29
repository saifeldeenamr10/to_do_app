import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/helper/get_helper.dart';
import '../../../core/translation/translation_keys.dart';
import 'Update_password_page.dart';
import 'language_page.dart';
import 'update_username_page.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/widgets/home_appbar.dart';
import 'widgets/option_container.dart';
import '../../../core/cache/cache_helper.dart';
import '../../../core/cache/cache_keys.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  Future<void> _handleLogout() async {
    try {
      // Clear all user-related data from cache
      await CacheHelper.removeData(key: CacheKeys.userModel);
      await CacheHelper.removeData(key: CacheKeys.loggedIn);
      await CacheHelper.removeData(key: CacheKeys.accessToken);
      await CacheHelper.removeData(key: CacheKeys.refreshToken);

      // Navigate to login screen and clear all previous routes
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: HomeAppBar.build(
          action: false,
          onProfilePressed: () {
            GetHelper.pop();
          },
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              OptionContainer(
                title: TranslationKeys.updateProfile.tr,
                icon: AppAssets.profile,
                onTap: () {
                  GetHelper.push(() => const UpdateUsernamePage());
                },
              ),
              OptionContainer(
                title: TranslationKeys.changePassword.tr,
                icon: AppAssets.lock,
                onTap: () {
                  GetHelper.push(() => const UpdatePasswordPage());
                },
              ),
              OptionContainer(
                title: TranslationKeys.settings.tr,
                icon: AppAssets.settings,
                onTap: () {
                  GetHelper.push(() => const LanguagePage());
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Logout',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
