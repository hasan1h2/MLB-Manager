import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_locales.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: [
          _buildLanguageSection(),
          const SizedBox(height: AppSizes.p16),
          _buildThemeSection(),
          const SizedBox(height: AppSizes.p16),
          _buildSecuritySection(),
          const SizedBox(height: AppSizes.p16),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.language_rounded, color: AppColors.secondaryElectric),
                const SizedBox(width: AppSizes.p8),
                Text('language'.tr, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
                      selectedColor: AppColors.primaryNavy,
                      labelStyle: TextStyle(color: isBn ? Colors.white : AppColors.textPrimaryLight),
                      onSelected: (_) => controller.changeLanguage(AppLocales.bengali),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('English (US)')),
                      selected: !isBn,
                      selectedColor: AppColors.primaryNavy,
                      labelStyle: TextStyle(color: !isBn ? Colors.white : AppColors.textPrimaryLight),
                      onSelected: (_) => controller.changeLanguage(AppLocales.english),
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

  Widget _buildThemeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined, color: AppColors.secondaryElectric),
                const SizedBox(width: AppSizes.p8),
                Text('theme'.tr, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            Obx(() {
              final currentMode = controller.themeController.themeMode;
              return SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('সিস্টেম')),
                  ButtonSegment(value: ThemeMode.light, label: Text('লাইট')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('ডার্ক')),
                ],
                selected: {currentMode},
                onSelectionChanged: (set) => controller.toggleTheme(set.first),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(AppIcons.security, color: AppColors.secondaryElectric),
                const SizedBox(width: AppSizes.p8),
                Text('security'.tr, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            Obx(() {
              final hasPin = controller.pinService.hasPin.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(hasPin ? Icons.lock_rounded : Icons.lock_open_rounded, color: hasPin ? AppColors.incomeGreen : AppColors.textMutedLight),
                title: Text(hasPin ? 'অ্যাপ পিন সক্রিয় রয়েছে' : 'নতুন পিন সেট করুন'),
                trailing: TextButton(
                  onPressed: () {
                    if (hasPin) {
                      AppConfirmDialog.show(
                        title: 'পিন অপসারণ',
                        message: 'আপনি কি অ্যাপ সিকিউরিটি পিন বন্ধ করতে চান?',
                        isDestructive: true,
                        onConfirm: () => controller.removePin(),
                      );
                    } else {
                      controller.openPinSetup();
                    }
                  },
                  child: Text(hasPin ? 'বন্ধ করুন' : 'সেট করুন'),
                ),
              );
            }),
            Obx(() {
              final bioAvailable = controller.pinService.isBiometricAvailable.value;
              final bioEnabled = controller.pinService.isBiometricEnabled.value;
              if (!bioAvailable) return const SizedBox();

              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(AppIcons.fingerprint, color: AppColors.secondaryElectric),
                title: Text('biometric_auth'.tr),
                value: bioEnabled,
                onChanged: (val) => controller.toggleBiometric(val),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  child: Image.asset(
                    AppConstants.appIconAsset,
                    width: 36,
                    height: 36,
                    errorBuilder: (_, __, ___) => const Icon(Icons.info_outline_rounded, color: AppColors.secondaryElectric),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                const Text('অ্যাপ সম্পর্কে', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              '${'app_name'.tr} v1.0.0',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 2),
            const Text(
              'ব্যক্তিগত অর্থায়ন, পরিবার ব্যবস্থাপনা ও বহু-ব্যবসা অ্যাকাউন্টিংয়ের সম্পূর্ণ অফলাইন-ফার্স্ট সমাধান।',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }
}
