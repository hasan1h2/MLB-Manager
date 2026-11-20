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
      appBar: AppBar(
        title: Obx(() => Text(
              controller.transactionType.value == 'income'
                  ? 'add_income'.tr
                  : (controller.transactionType.value == 'transfer'
                      ? 'transfer'.tr
                      : 'add_expense'.tr),
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeToggle(),
            const SizedBox(height: AppSizes.p16),
            _buildScopeSelector(context),
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
            Row(
              children: [
                Expanded(child: _buildDatePicker(context)),
                const SizedBox(width: AppSizes.p12),
                Expanded(child: _buildTimePicker(context)),
              ],
            ),
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
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    return Obx(() {
      final current = controller.transactionType.value;
      return SizedBox(
        width: double.infinity,
        child: SegmentedButton<String>(
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
                  color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
          segments: [
            ButtonSegment(
              value: 'expense',
              label: Text('expense'.tr),
              icon: const Icon(AppIcons.expense, size: 16),
            ),
            ButtonSegment(
              value: 'income',
              label: Text('income'.tr),
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
        ),
      );
    });
  }

  Widget _buildScopeSelector(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'scope'.tr,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.p4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _scopeRadio(context, 'personal', 'personal'),
                const SizedBox(width: AppSizes.p12),
                _scopeRadio(context, 'family', 'family'),
                const SizedBox(width: AppSizes.p12),
                _scopeRadio(context, 'business', 'business'),
              ],
            ),
          ),
          if (controller.scopeType.value == 'business' &&
              controller.businesses.isNotEmpty) ...[
            const SizedBox(height: AppSizes.p8),
            DropdownButtonFormField<String>(
              value: controller.selectedBusinessId.value ??
                  controller.businesses.first.id,
              decoration:
                  const InputDecoration(labelText: 'ব্যবসা নির্বাচন করুন'),
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

  Widget _scopeRadio(BuildContext context, String value, String labelKey) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

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
        Text(
          labelKey.tr,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
        ),
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
          labelText: controller.transactionType.value == 'transfer'
              ? 'from_account'.tr
              : 'account'.tr,
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
      final accounts = controller.accounts
          .where((a) => a.id != controller.selectedAccountId.value)
          .toList();
      return DropdownButtonFormField<String>(
        value: controller.toAccountId.value ??
            (accounts.isNotEmpty ? accounts.first.id : null),
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
      final categories = controller.categories
          .where((c) => c.categoryType == controller.transactionType.value)
          .toList();
      if (categories.isEmpty) {
        return const SizedBox.shrink();
      }
      return DropdownButtonFormField<String>(
        value: controller.selectedCategoryId.value ?? categories.first.id,
        decoration: InputDecoration(
          labelText: 'category'.tr,
          prefixIcon: const Icon(Icons.category_outlined),
        ),
        items: categories.map((cat) {
          final isBn = Get.locale?.languageCode == 'bn';
          return DropdownMenuItem(
              value: cat.id, child: Text(isBn ? cat.nameBn : cat.nameEn));
        }).toList(),
        onChanged: (val) => controller.selectedCategoryId.value = val,
      );
    });
  }

  Widget _buildDatePicker(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      return InkWell(
        borderRadius: BorderRadius.circular(AppSizes.r8),
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
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p12, vertical: AppSizes.p10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.r8),
            border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          child: Row(
            children: [
              const Icon(AppIcons.calendar,
                  color: AppColors.secondaryElectric, size: 20),
              const SizedBox(width: AppSizes.p8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'date'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      AppDateUtils.standardDateFormat
                          .format(controller.transactionDate.value),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTimePicker(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final time = controller.transactionTime.value;
      final timeStr = controller.formatTime(time);

      return InkWell(
        borderRadius: BorderRadius.circular(AppSizes.r8),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time ?? TimeOfDay.now(),
          );
          if (picked != null) {
            controller.transactionTime.value = picked;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p12, vertical: AppSizes.p10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.r8),
            border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  color: AppColors.infoBlue, size: 20),
              const SizedBox(width: AppSizes.p8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'সময় (ঐচ্ছিক)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      timeStr ?? 'সময় নির্বাচন',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: timeStr != null
                            ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight)
                            : (isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight),
                      ),
                    ),
                  ],
                ),
              ),
              if (time != null)
                InkWell(
                  onTap: () => controller.transactionTime.value = null,
                  child: Icon(Icons.close_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight),
                ),
            ],
          ),
        ),
      );
    });
  }
}
