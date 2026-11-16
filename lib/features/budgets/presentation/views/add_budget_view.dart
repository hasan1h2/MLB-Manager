import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/budget_controller.dart';

class AddBudgetView extends GetView<BudgetController> {
  const AddBudgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('add_budget'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'বাজেটের নাম / খাত',
              hint: 'যেমন: মাসিক পারিবারিক বাজেট, মুদি খরচ সীমা',
              controller: controller.nameController,
              prefixIcon: Icons.pie_chart_outline_rounded,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildScopeDropdown(),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'spending_limit'.tr,
              controller: controller.limitController,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'সতর্কতা শতকরা হার (%)',
              hint: '80',
              controller: controller.alertPercentController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveBudget();
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

  Widget _buildScopeDropdown() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('বাজেট স্কোপ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p4),
          DropdownButtonFormField<String>(
            value: controller.selectedScope.value,
            items: const [
              DropdownMenuItem(value: 'family', child: Text('পারিবারিক (Family)')),
              DropdownMenuItem(value: 'personal', child: Text('ব্যক্তিগত (Personal)')),
              DropdownMenuItem(value: 'business', child: Text('ব্যবসায়িক (Business)')),
            ],
            onChanged: (val) {
              if (val != null) controller.selectedScope.value = val;
            },
          ),
        ],
      );
    });
  }
}
