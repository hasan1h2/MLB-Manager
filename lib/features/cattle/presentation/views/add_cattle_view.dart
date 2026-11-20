import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/cattle_controller.dart';

class AddCattleView extends GetView<CattleController> {
  const AddCattleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_cattle'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'tag_number'.tr,
              hint: 'যেমন: C-101, B-55',
              controller: controller.tagNumberController,
              prefixIcon: Icons.tag_rounded,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'নাম (যদি থাকে)',
              hint: 'যেমন: লালু, বাহাদুর',
              controller: controller.nameController,
              prefixIcon: Icons.pets_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'breed'.tr,
                    hint: 'শাহীওয়াল, ফ্রিজিয়ান...',
                    controller: controller.breedController,
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: AppTextField(
                    label: 'weight_kg'.tr,
                    hint: 'যেমন: 350',
                    controller: controller.weightController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),
            _buildGenderDropdown(),
            const SizedBox(height: AppSizes.p16),
            _buildPhotoPicker(context),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'purchase_price'.tr,
              controller: controller.purchasePriceController,
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveCattle();
                if (success) {
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final path = controller.photoPath.value;
      return Row(
        children: [
          AppImage(
            imagePath: path,
            width: 56,
            height: 56,
            borderRadius: AppSizes.r8,
            fallbackIcon: AppIcons.cattle,
            fallbackColor: AppColors.tagBull,
            backgroundColor: isDark
                ? AppColors.surfaceDark
                : AppColors.tagBull.withValues(alpha: 0.12),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: Text(
                path != null
                    ? 'গরুর ছবি পরিবর্তন করুন'
                    : 'গরুর ছবি যুক্ত করুন (ঐচ্ছিক)',
                style: const TextStyle(fontSize: 13),
              ),
              onPressed: () async {
                final picker = ImagePicker();
                final img = await picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 70);
                if (img != null) {
                  controller.photoPath.value = img.path;
                }
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildGenderDropdown() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('gender'.tr,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p4),
          DropdownButtonFormField<String>(
            value: controller.selectedGender.value,
            items: const [
              DropdownMenuItem(value: 'bull', child: Text('ষাঁড় (Bull)')),
              DropdownMenuItem(value: 'cow', child: Text('গাভী (Cow)')),
              DropdownMenuItem(
                  value: 'heifer', child: Text('বকনা বাছুর (Heifer)')),
              DropdownMenuItem(value: 'calf', child: Text('বাছুর (Calf)')),
            ],
            onChanged: (val) {
              if (val != null) controller.selectedGender.value = val;
            },
          ),
        ],
      );
    });
  }
}
