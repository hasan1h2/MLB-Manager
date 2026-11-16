import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/asset_controller.dart';

class AddSavingsGoalView extends GetView<AssetController> {
  const AddSavingsGoalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('add_savings_goal'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'সঞ্চয়ের লক্ষ্য / উদ্দেশ্য',
              hint: 'যেমন: হজ তহবিল, জরুরি ফান্ড, সন্তানের শিক্ষা',
              controller: controller.goalNameController,
              prefixIcon: Icons.savings_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'লক্ষ্যমাত্রা (টার্গেট টাকা)',
              controller: controller.goalTargetAmountController,
            ),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'বর্তমান প্রাথমিক জমা (যদি থাকে)',
              controller: controller.goalCurrentAmountController,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildDatePicker(context),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveSavingsGoal();
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

  Widget _buildDatePicker(BuildContext context) {
    return Obx(() {
      return ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r8),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        tileColor: Colors.white,
        leading: const Icon(AppIcons.calendar, color: AppColors.secondaryElectric),
        title: const Text('টার্গেট সমাপ্তির তারিখ', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
        subtitle: Text(
          AppDateUtils.standardDateFormat.format(controller.goalTargetDate.value),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: controller.goalTargetDate.value,
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.goalTargetDate.value = picked;
          }
        },
      );
    });
  }
}
