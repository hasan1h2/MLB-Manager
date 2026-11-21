import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/business_controller.dart';

class BusinessSettingsView extends GetView<BusinessController> {
  const BusinessSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ব্যবসায়িক সেটিংস',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ব্যবসার তথ্য ও প্রোফাইল',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.p12),
            AppTextField(
              label: 'ব্যবসার নাম',
              controller: controller.settingsNameController,
              prefixIcon: AppIcons.business,
            ),
            const SizedBox(height: AppSizes.p12),
            AppTextField(
              label: 'ঠিকানা / অবস্থান',
              controller: controller.settingsLocationController,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: AppSizes.p12),
            AppTextField(
              label: 'মোবাইল নম্বর',
              controller: controller.settingsPhoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSizes.p12),
            AppTextField(
              label: 'বিবরণ (ঐচ্ছিক)',
              controller: controller.settingsDescriptionController,
              maxLines: 2,
            ),
            const SizedBox(height: AppSizes.p24),
            const Text(
              'ব্যবসার ধরণ নির্বাচন (Business Type)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.p4),
            Text(
              'ব্যবসার ধরণ পরিবর্তন করলে আগের পণ্য বা লেনদেনের কোন তথ্য মুছে যাবে না।',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.p12),
            Obx(() {
              return Column(
                children: [
                  _buildTypeRadioTile(
                    'retail',
                    'খুচরা ব্যবসা (Retail / মুদি দোকান)',
                    'খুচরা কাউন্টার বিক্রয়, ফাস্ট ক্যাশ এন্ট্রি ও বারকোড সেল।',
                    cardBg,
                    borderColor,
                  ),
                  const SizedBox(height: 8),
                  _buildTypeRadioTile(
                    'wholesale',
                    'পাইকারি ব্যবসা (Wholesale)',
                    'বাল্ক বিক্রয়, পাইকারি দর ও পরিমাণভিত্তিক টিয়ার প্রাইসিং।',
                    cardBg,
                    borderColor,
                  ),
                  const SizedBox(height: 8),
                  _buildTypeRadioTile(
                    'hybrid',
                    'খুচরা + পাইকারি সমন্বিত (Hybrid)',
                    'একই দোকান থেকে খুচরা এবং পাইকারি উভয় ধরণের বিক্রয়।',
                    cardBg,
                    borderColor,
                  ),
                  const SizedBox(height: 8),
                  _buildTypeRadioTile(
                    'cattle',
                    'গরুর খামার (Cattle Farm)',
                    'গরু লালন-পালন, লালন খরচ ও গবাদি পশু বিক্রয়।',
                    cardBg,
                    borderColor,
                  ),
                ],
              );
            }),
            const SizedBox(height: AppSizes.p24),
            const Text(
              'ইনভেন্টরি ও আর্থিক নিয়মাবলী',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.p12),
            Obx(() {
              return SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  side: BorderSide(color: borderColor),
                ),
                tileColor: cardBg,
                title: const Text('স্টক শেষ হলেও বিক্রির অনুমতি (Negative Stock)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: const Text('চালু রাখলে স্টক ০ থাকলেও বিক্রয় রেকর্ড করা যাবে।',
                    style: TextStyle(fontSize: 11)),
                value: controller.settingsAllowNegativeStock.value,
                onChanged: (val) =>
                    controller.settingsAllowNegativeStock.value = val,
              );
            }),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'সেটিংস সংরক্ষণ করুন',
              icon: AppIcons.check,
              onPressed: () async {
                final ok = await controller.updateSettings();
                if (ok) Get.back();
              },
            ),
            const SizedBox(height: AppSizes.p24),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeRadioTile(
      String value, String title, String subtitle, Color cardBg, Color borderColor) {
    final isSelected = controller.settingsType.value == value;
    return InkWell(
      onTap: () => controller.settingsType.value = value,
      borderRadius: BorderRadius.circular(AppSizes.r8),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSizes.r8),
          border: Border.all(
            color: isSelected ? AppColors.secondaryElectric : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: controller.settingsType.value,
              onChanged: (val) {
                if (val != null) controller.settingsType.value = val;
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
