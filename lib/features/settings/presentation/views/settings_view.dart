import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_locales.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_image.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: [
          _buildLanguageSection(context),
          const SizedBox(height: AppSizes.p16),
          _buildThemeSection(context),
          const SizedBox(height: AppSizes.p16),
          _buildSecuritySection(context),
          const SizedBox(height: AppSizes.p16),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor =
        isDark ? AppColors.secondaryElectric : AppColors.primaryNavy;
    final unselectedTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final unselectedBg = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Card(
      color: isDark ? AppColors.cardDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.language_rounded,
                    color: AppColors.secondaryElectric),
                const SizedBox(width: AppSizes.p8),
                Text('language'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight)),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            Obx(() {
              final isBn = controller.currentLocale.value.languageCode == 'bn';
              return Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('বাংলা (Bengali)')),
                      selected: isBn,
                      selectedColor: selectedColor,
                      backgroundColor: unselectedBg,
                      side:
                          BorderSide(color: isBn ? selectedColor : borderColor),
                      labelStyle: TextStyle(
                        color: isBn ? Colors.white : unselectedTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) =>
                          controller.changeLanguage(AppLocales.bengali),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('English (US)')),
                      selected: !isBn,
                      selectedColor: selectedColor,
                      backgroundColor: unselectedBg,
                      side: BorderSide(
                          color: !isBn ? selectedColor : borderColor),
                      labelStyle: TextStyle(
                        color: !isBn ? Colors.white : unselectedTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) =>
                          controller.changeLanguage(AppLocales.english),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? AppColors.cardDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined,
                    color: AppColors.secondaryElectric),
                const SizedBox(width: AppSizes.p8),
                Text('theme'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight)),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            Obx(() {
              final currentMode = controller.themeController.themeMode;
              return SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return isDark
                            ? AppColors.secondaryElectric
                            : AppColors.primaryNavy;
                      }
                      return isDark ? AppColors.surfaceDark : Colors.white;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight;
                    }),
                    side: WidgetStateProperty.all(
                      BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                    ),
                  ),
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.system, label: Text('সিস্টেম')),
                    ButtonSegment(value: ThemeMode.light, label: Text('লাইট')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('ডার্ক')),
                  ],
                  selected: {currentMode},
                  onSelectionChanged: (set) =>
                      controller.toggleTheme(set.first),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security_rounded,
                    color: AppColors.secondaryElectric),
                const SizedBox(width: AppSizes.p8),
                Text('security_pin'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            Obx(() {
              final hasPin = controller.pinService.hasPin.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    Icon(hasPin ? Icons.lock_rounded : Icons.lock_open_rounded),
                title: Text(hasPin ? 'app_pin_active'.tr : 'set_new_pin'.tr),
                trailing: TextButton(
                  onPressed: () => controller.showPinSetupDialog(context),
                  child: Text(
                    hasPin ? 'change'.tr : 'set_pin'.tr,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.secondaryElectricLight
                          : AppColors.secondaryElectric,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
            Obx(() {
              final bioAvailable =
                  controller.pinService.isBiometricAvailable.value;
              if (!bioAvailable) return const SizedBox.shrink();

              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.fingerprint_rounded),
                title: Text('enable_biometric'.tr),
                value: controller.pinService.isBiometricEnabled.value,
                onChanged: (val) => controller.toggleBiometrics(val),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppImage(
                  imagePath: AppConstants.appIconAsset,
                  width: 36,
                  height: 36,
                  borderRadius: AppSizes.r8,
                  fallbackIcon: Icons.info_outline_rounded,
                ),
                const SizedBox(width: AppSizes.p12),
                const Text('অ্যাপ সম্পর্কে',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: AppSizes.p10),
            Text(
              '${'app_name'.tr} v${AppConstants.appVersion}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'ব্যক্তিগত অর্থায়ন, পরিবার ব্যবস্থাপনা ও বহু-ব্যবসা অ্যাকাউন্টিংয়ের সম্পূর্ণ অফলাইন-ফার্স্ট সমাধান।',
              style: TextStyle(
                  fontSize: 12.5, color: secondaryTextColor, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
