import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/transaction_controller.dart';

class TransactionListView extends GetView<TransactionController> {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('nav_transactions'.tr),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.filter),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.category_rounded),
            onPressed: () => Get.toNamed(AppRoutes.categories),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        final list = controller.filteredTransactions;
        if (list.isEmpty) {
          return AppEmptyState(
            message: 'no_data_found'.tr,
            actionText: 'add_transaction'.tr,
            onAction: () => Get.toNamed(AppRoutes.addExpense),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
          itemBuilder: (context, index) {
            final tx = list[index];
            final isIncome = tx.transactionType == 'income';
            final isTransfer = tx.transactionType == 'transfer';

            Color color = AppColors.expenseRed;
            IconData icon = AppIcons.expense;
            if (isIncome) {
              color = AppColors.incomeGreen;
              icon = AppIcons.income;
            } else if (isTransfer) {
              color = AppColors.secondaryElectric;
              icon = AppIcons.transfer;
            }

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, color: color, size: 20),
                ),
                title: Text(
                  tx.description?.isNotEmpty == true ? tx.description! : tx.transactionNumber,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      AppDateUtils.formatTimestamp(tx.transactionDate),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(width: AppSizes.p8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.dividerLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tx.scopeType.tr,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isIncome ? '+' : (isTransfer ? '' : '-')}${CurrencyUtils.format(tx.amountMinor)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(AppIcons.delete, size: 18, color: AppColors.textMutedLight),
                      onPressed: () {
                        AppConfirmDialog.show(
                          title: 'delete'.tr,
                          message: 'delete_transaction_confirm'.tr,
                          isDestructive: true,
                          onConfirm: () => controller.deleteTransaction(tx.id),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addExpense),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.p20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('filter'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.p16),
            const Text('Transaction Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: AppSizes.p8),
            Obx(() => Wrap(
                  spacing: 8,
                  children: [
                    _filterChip('all', 'all'),
                    _filterChip('income', 'add_income'),
                    _filterChip('expense', 'add_expense'),
                    _filterChip('transfer', 'transfer'),
                  ],
                )),
            const SizedBox(height: AppSizes.p16),
            const Text('Scope', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: AppSizes.p8),
            Obx(() => Wrap(
                  spacing: 8,
                  children: [
                    _scopeChip('all', 'all'),
                    _scopeChip('personal', 'personal'),
                    _scopeChip('family', 'family'),
                    _scopeChip('business', 'business'),
                  ],
                )),
            const SizedBox(height: AppSizes.p24),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String key, String labelKey) {
    final isSelected = controller.selectedTypeFilter.value == key;
    return ChoiceChip(
      label: Text(labelKey.tr),
      selected: isSelected,
      onSelected: (_) => controller.selectedTypeFilter.value = key,
    );
  }

  Widget _scopeChip(String key, String labelKey) {
    final isSelected = controller.selectedScopeFilter.value == key;
    return ChoiceChip(
      label: Text(labelKey.tr),
      selected: isSelected,
      onSelected: (_) => controller.selectedScopeFilter.value = key,
    );
  }
}
