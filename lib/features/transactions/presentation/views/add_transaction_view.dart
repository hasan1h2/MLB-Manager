import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/transaction_controller.dart';

class AddTransactionView extends GetView<TransactionController> {
  final String initialType;
  const AddTransactionView({super.key, this.initialType = 'expense'});

  @override
  Widget build(BuildContext context) {
    controller.transactionType.value = initialType;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Obx(() => Text(
              controller.transactionType.value == 'income'
                  ? 'add_income'.tr
                  : (controller.transactionType.value == 'transfer' ? 'transfer'.tr : 'add_expense'.tr),
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeToggle(),
            const SizedBox(height: AppSizes.p16),
            _buildScopeSelector(),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'amount'.tr,
              controller: controller.amountController,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildAccountDropdown(),
            const SizedBox(height: AppSizes.p16),
            Obx(() {
              if (controller.transactionType.value == 'transfer') {
                return _buildToAccountDropdown();
              }
              return _buildCategoryDropdown();
            }),
            const SizedBox(height: AppSizes.p16),
            _buildDatePicker(context),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'description'.tr,
              controller: controller.descriptionController,
              hint: 'notes'.tr,
              prefixIcon: Icons.notes_rounded,
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveTransaction();
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
      final current = controller.transactionType.value;
      return SegmentedButton<String>(
        segments: [
          ButtonSegment(
            value: 'expense',
            label: Text('add_expense'.tr),
            icon: const Icon(AppIcons.expense, size: 16),
          ),
          ButtonSegment(
            value: 'income',
            label: Text('add_income'.tr),
            icon: const Icon(AppIcons.income, size: 16),
          ),
          ButtonSegment(
            value: 'transfer',
            label: Text('transfer'.tr),
            icon: const Icon(AppIcons.transfer, size: 16),
          ),
        ],
        selected: {current},
        onSelectionChanged: (set) {
          controller.transactionType.value = set.first;
        },
      );
    });
  }

  Widget _buildScopeSelector() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('scope'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p4),
          Row(
            children: [
              _scopeRadio('personal', 'personal'),
              const SizedBox(width: AppSizes.p16),
              _scopeRadio('family', 'family'),
              const SizedBox(width: AppSizes.p16),
              _scopeRadio('business', 'business'),
            ],
          ),
          if (controller.scopeType.value == 'business' && controller.businesses.isNotEmpty) ...[
            const SizedBox(height: AppSizes.p8),
            DropdownButtonFormField<String>(
              value: controller.selectedBusinessId.value ?? controller.businesses.first.id,
              decoration: const InputDecoration(labelText: 'ব্যবসা নির্বাচন করুন'),
              items: controller.businesses.map((b) {
                return DropdownMenuItem(value: b.id, child: Text(b.name));
              }).toList(),
              onChanged: (val) => controller.selectedBusinessId.value = val,
            ),
          ],
        ],
      );
    });
  }

  Widget _scopeRadio(String value, String labelKey) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: controller.scopeType.value,
          onChanged: (val) {
            if (val != null) controller.scopeType.value = val;
          },
        ),
        Text(labelKey.tr, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildAccountDropdown() {
    return Obx(() {
      final accounts = controller.accounts;
      if (accounts.isEmpty) {
        return Text('no_data_found'.tr);
      }
      return DropdownButtonFormField<String>(
        value: controller.selectedAccountId.value ?? accounts.first.id,
        decoration: InputDecoration(
          labelText: controller.transactionType.value == 'transfer' ? 'from_account'.tr : 'account'.tr,
          prefixIcon: const Icon(AppIcons.accounts),
        ),
        items: accounts.map((acc) {
          return DropdownMenuItem(value: acc.id, child: Text(acc.name));
        }).toList(),
        onChanged: (val) => controller.selectedAccountId.value = val,
      );
    });
  }

  Widget _buildToAccountDropdown() {
    return Obx(() {
      final accounts = controller.accounts.where((a) => a.id != controller.selectedAccountId.value).toList();
      return DropdownButtonFormField<String>(
        value: controller.toAccountId.value ?? (accounts.isNotEmpty ? accounts.first.id : null),
        decoration: InputDecoration(
          labelText: 'to_account'.tr,
          prefixIcon: const Icon(AppIcons.accounts),
        ),
        items: accounts.map((acc) {
          return DropdownMenuItem(value: acc.id, child: Text(acc.name));
        }).toList(),
        onChanged: (val) => controller.toAccountId.value = val,
      );
    });
  }

  Widget _buildCategoryDropdown() {
    return Obx(() {
      final cats = controller.categoriesForCurrentType;
      if (cats.isEmpty) {
        return const SizedBox();
      }
      return DropdownButtonFormField<String>(
        value: controller.selectedCategoryId.value ?? cats.first.id,
        decoration: InputDecoration(
          labelText: 'category'.tr,
          prefixIcon: const Icon(Icons.category_rounded),
        ),
        items: cats.map((c) {
          final isBn = Get.locale?.languageCode == 'bn';
          return DropdownMenuItem(value: c.id, child: Text(isBn ? c.nameBn : c.nameEn));
        }).toList(),
        onChanged: (val) => controller.selectedCategoryId.value = val,
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
        title: Text('date'.tr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
        subtitle: Text(
          AppDateUtils.standardDateFormat.format(controller.transactionDate.value),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: controller.transactionDate.value,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.transactionDate.value = picked;
          }
        },
      );
    });
  }
}
