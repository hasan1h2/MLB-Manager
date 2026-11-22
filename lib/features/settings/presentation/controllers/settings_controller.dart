import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_locales.dart';
import '../../../../core/security/pin_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_theme_controller.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class SettingsController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final PinService pinService = Get.find<PinService>();
  final AppThemeController themeController = Get.find<AppThemeController>();

  final Rx<Locale> currentLocale = AppLocales.bengali.obs;

  @override
  void onInit() {
    super.onInit();
    final savedLang = _storage.getString(AppConstants.keyLanguage);
    if (savedLang == 'en') {
      currentLocale.value = AppLocales.english;
    } else {
      currentLocale.value = AppLocales.bengali;
    }
  }

  Future<void> changeLanguage(Locale locale) async {
    currentLocale.value = locale;
    await Get.updateLocale(locale);
    await _storage.setString(AppConstants.keyLanguage, locale.languageCode);
    AppSnackbar.success(locale.languageCode == 'bn' ? 'ভাষা সফলভাবে পরিবর্তন করা হয়েছে' : 'Language updated successfully');
  }

  void toggleTheme(ThemeMode mode) {
    themeController.setThemeMode(mode);
    AppSnackbar.success('থিম সফলভাবে আপডেট হয়েছে');
  }

  void openPinSetup() {
    Get.toNamed(AppRoutes.pinSetup);
  }

  void showPinSetupDialog(BuildContext context) {
    openPinSetup();
  }

  Future<void> removePin() async {
    await pinService.removePin();
    AppSnackbar.success('পিন লক নিষ্ক্রিয় করা হয়েছে');
  }

  Future<void> toggleBiometric(bool value) async {
    await pinService.setBiometricEnabled(value);
    AppSnackbar.success(value ? 'বায়োমেট্রিক লক চালু হয়েছে' : 'বায়োমেট্রিক লক বন্ধ হয়েছে');
  }

  Future<void> toggleBiometrics(bool value) async {
    await toggleBiometric(value);
  }
}
