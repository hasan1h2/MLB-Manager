import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/loan_controller.dart';

class AddLoanView extends GetView<LoanController> {
  const AddLoanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('add_loan'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            _buildTypeToggle(),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'ব্যক্তি বা প্রতিষ্ঠানের নাম',
              hint: 'কার কাছে পাওনা বা কার কাছ থেকে নেওয়া',
              controller: controller.partyNameController,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'মোবাইল নম্বর',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'principal_amount'.tr,
              controller: controller.principalController,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildDatePicker(context),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'notes'.tr,
              controller: controller.notesController,
              maxLines: 2,
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveLoan();
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

  Widget _buildTypeToggle() {
    return Obx(() {
      return SegmentedButton<String>(
        segments: [
          ButtonSegment(value: 'receivable', label: Text('loan_receivable'.tr)),
          ButtonSegment(value: 'payable', label: Text('loan_payable'.tr)),
        ],
        selected: {controller.loanType.value},
        onSelectionChanged: (set) => controller.loanType.value = set.first,
      );
    });
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
        title: Text('due_date'.tr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
        subtitle: Text(
          AppDateUtils.standardDateFormat.format(controller.dueDate.value),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: controller.dueDate.value,
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.dueDate.value = picked;
          }
        },
      );
    });
  }
}
