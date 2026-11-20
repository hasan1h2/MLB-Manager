import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/account_controller.dart';

class AddAccountView extends GetView<AccountController> {
  const AddAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_account'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'হিসাবের নাম',
              hint: 'যেমন: ডাচ-বাংলা ব্যাংক, বিকাশ পার্সোনাল, নগদ ক্যাশ',
              controller: controller.nameController,
              prefixIcon: Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildTypeDropdown(),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'opening_balance'.tr,
              controller: controller.openingBalanceController,
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveAccount();
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
          Text('account_type'.tr,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p4),
          DropdownButtonFormField<String>(
            value: controller.selectedType.value,
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('ক্যাশ (Cash)')),
              DropdownMenuItem(
                  value: 'bank', child: Text('ব্যাংক অ্যাকাউন্ট (Bank)')),
              DropdownMenuItem(value: 'bkash', child: Text('বিকাশ (bKash)')),
              DropdownMenuItem(value: 'nagad', child: Text('নগদ (Nagad)')),
              DropdownMenuItem(value: 'rocket', child: Text('রকেট (Rocket)')),
              DropdownMenuItem(
                  value: 'other_wallet',
                  child: Text('অন্যান্য মোবাইল ওয়ালেট')),
              DropdownMenuItem(
                  value: 'custom', child: Text('কাস্টম অ্যাকাউন্ট')),
            ],
            onChanged: (val) {
              if (val != null) controller.selectedType.value = val;
            },
          ),
        ],
      );
    });
  }
}
