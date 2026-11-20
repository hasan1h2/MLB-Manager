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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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

            final dateStr = AppDateUtils.standardDateFormat.format(
                DateTime.fromMillisecondsSinceEpoch(tx.transactionDate));
            final timeStr =
                tx.purchaseTime != null && tx.purchaseTime!.isNotEmpty
                    ? ' • ${tx.purchaseTime}'
                    : '';

            return Card(
              elevation: 0,
              color: isDark ? AppColors.cardDark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.r12),
                side: BorderSide(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: ListTile(
                onTap: () =>
                    Get.toNamed(AppRoutes.transactionDetails, arguments: tx),
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, color: color, size: 20),
                ),
                title: Text(
                  tx.description?.isNotEmpty == true
                      ? tx.description!
                      : tx.transactionNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          '$dateStr$timeStr',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: AppSizes.p8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.dividerLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                          ),
                          child: Text(
                            tx.scopeType.tr,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (tx.sourceType == 'shopping' && tx.sourceId != null) ...[
                      const SizedBox(height: 4),
                      FutureBuilder<String?>(
                        future: controller.getShoppingSummary(tx.sourceId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data != null &&
                              snapshot.data!.isNotEmpty) {
                            return Row(
                              children: [
                                const Icon(Icons.shopping_bag_outlined,
                                    size: 12,
                                    color: AppColors.secondaryElectric),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    snapshot.data!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.secondaryElectric,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
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
                      icon: Icon(
                        AppIcons.delete,
                        size: 18,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
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
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('filter'.tr,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.p16),
            const Text('Transaction Type',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
            const Text('Scope',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
