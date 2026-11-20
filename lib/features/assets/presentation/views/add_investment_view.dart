import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/asset_controller.dart';

class AddInvestmentView extends GetView<AssetController> {
  const AddInvestmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_investment'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'বিনিয়োগের নাম / খাত',
              hint: 'যেমন: শেয়ার মার্কেট, সঞ্চয়পত্র, নতুন পার্টনারশিপ',
              controller: controller.investmentNameController,
              prefixIcon: Icons.trending_up_rounded,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildTypeDropdown(),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'প্রাথমিক বিনিয়োগের পরিমাণ',
              controller: controller.investmentAmountController,
            ),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'বর্তমান আনুমানিক মূল্য',
              controller: controller.investmentValueController,
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveInvestment();
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

  Widget _buildTypeDropdown() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('বিনিয়োগের ধরণ',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p4),
          DropdownButtonFormField<String>(
            value: controller.selectedInvestmentType.value,
            items: const [
              DropdownMenuItem(
                  value: 'business', child: Text('ব্যবসা ও মূলধন (Business)')),
              DropdownMenuItem(
                  value: 'shares',
                  child: Text('শেয়ার মার্কেট (Shares/Stocks)')),
              DropdownMenuItem(
                  value: 'savings_cert',
                  child: Text('সঞ্চয়পত্র (Savings Certificate)')),
              DropdownMenuItem(
                  value: 'agriculture',
                  child: Text('কৃষি ও খামার বিনিয়োগ (Agri)')),
              DropdownMenuItem(value: 'other', child: Text('অন্যান্য (Other)')),
            ],
            onChanged: (val) {
              if (val != null) controller.selectedInvestmentType.value = val;
            },
          ),
        ],
      );
    });
  }
}
