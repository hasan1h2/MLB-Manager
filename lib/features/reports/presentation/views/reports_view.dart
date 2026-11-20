import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/report_controller.dart';

class ReportsView extends GetView<ReportController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('reports'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'পণ্যসহ বিস্তারিত CSV',
            onPressed: () => controller.exportDetailedCsv(),
          ),
          IconButton(
            icon: const Icon(AppIcons.exportPdf),
            tooltip: 'export_pdf'.tr,
            onPressed: () => controller.exportPdf(),
          ),
          IconButton(
            icon: const Icon(AppIcons.exportExcel),
            tooltip: 'export_excel'.tr,
            onPressed: () => controller.exportExcel(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        final data = controller.summaryData.value;
        if (data == null) {
          return const Center(child: Text('কোন তথ্য পাওয়া যায়নি'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Filter Chips
              _buildFilterChips(isDark),
              const SizedBox(height: AppSizes.p16),

              // Summary Card (Income, Expense, Net Profit)
              _buildProfitLossCard(data, isDark),
              const SizedBox(height: AppSizes.p16),

              // Tab Selector: [ লেনদেনের বিবরণী | পণ্যভিত্তিক বাজার খরচ ]
              _buildTabSelector(isDark),
              const SizedBox(height: AppSizes.p12),

              // Tab Content
              Obx(() {
                if (controller.selectedReportTab.value == 0) {
                  return _buildTransactionsSection(data, isDark);
                } else {
                  return _buildMarketSpendSection(isDark);
                }
              }),

              const SizedBox(height: AppSizes.p32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = [
      'filter_this_month',
      'filter_last_month',
      'filter_last_7_days',
      'filter_this_year',
    ];

    final selectedBg =
        isDark ? AppColors.secondaryElectric : AppColors.primaryNavy;
    final unselectedBg = isDark ? AppColors.surfaceDark : Colors.white;
    final unselectedText =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = controller.selectedFilter.value == f;
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.p8),
            child: ChoiceChip(
              label: Text(f.tr),
              selected: isSelected,
              selectedColor: selectedBg,
              backgroundColor: unselectedBg,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : unselectedText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? selectedBg : borderColor,
              ),
              onSelected: (_) => controller.setFilter(f),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProfitLossCard(ReportSummaryData data, bool isDark) {
    final labelColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Card(
      elevation: 0,
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
        side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('total_income'.tr,
                    style: TextStyle(fontSize: 14, color: labelColor)),
                Text(
                  CurrencyUtils.format(data.totalIncomeMinor),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.incomeGreen),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('total_expenses'.tr,
                    style: TextStyle(fontSize: 14, color: labelColor)),
                Text(
                  CurrencyUtils.format(data.totalExpenseMinor),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.expenseRed),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
                color: isDark ? AppColors.borderDark : AppColors.borderLight),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'নিট লাভ / উদ্বৃত্ত',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: titleColor),
                ),
                Text(
                  CurrencyUtils.format(data.netProfitMinor),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: data.netProfitMinor >= 0
                        ? AppColors.incomeGreen
                        : AppColors.expenseRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    return Obx(() {
      final tab = controller.selectedReportTab.value;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSizes.r8),
                onTap: () => controller.selectedReportTab.value = 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: tab == 0
                        ? (isDark
                            ? AppColors.secondaryElectric
                            : AppColors.primaryNavy)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  child: Center(
                    child: Text(
                      'লেনদেনের বিবরণী',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            tab == 0 ? FontWeight.w700 : FontWeight.w500,
                        color: tab == 0
                            ? Colors.white
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSizes.r8),
                onTap: () => controller.selectedReportTab.value = 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: tab == 1
                        ? (isDark
                            ? AppColors.secondaryElectric
                            : AppColors.primaryNavy)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  child: Center(
                    child: Text(
                      'পণ্যভিত্তিক বাজার খরচ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            tab == 1 ? FontWeight.w700 : FontWeight.w500,
                        color: tab == 1
                            ? Colors.white
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // --- Transactions Section (Clickable rows leading to details) ---
  Widget _buildTransactionsSection(ReportSummaryData data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'লেনদেনের তালিকা (${data.transactions.length})',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('সাধারণ CSV'),
              onPressed: () => controller.exportCsv(),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p8),
        if (data.transactions.isEmpty)
          const AppEmptyState(message: 'এই সময়ের মধ্যে কোনো লেনদেন নেই')
        else
          Card(
            elevation: 0,
            color: isDark ? AppColors.cardDark : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.r12),
              side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.transactions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 64,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              itemBuilder: (context, index) {
                final tx = data.transactions[index];
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

                final dateStr =
                    AppDateUtils.formatTimestamp(tx.transactionDate);
                final timeStr =
                    tx.purchaseTime != null && tx.purchaseTime!.isNotEmpty
                        ? ' • ${tx.purchaseTime}'
                        : '';

                return ListTile(
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
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  subtitle: Text(
                    '$dateStr$timeStr',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${isIncome ? '+' : (isTransfer ? '' : '-')}${CurrencyUtils.format(tx.amountMinor)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // --- Market Product Spend Section ---
  Widget _buildMarketSpendSection(bool isDark) {
    final list = controller.marketProductSpend;

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_cart_outlined,
                  size: 44,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight),
              const SizedBox(height: AppSizes.p12),
              Text(
                'এই সময়ের মধ্যে পণ্যভিত্তিক কোনো বাজার খরচ নেই',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'পণ্যভিত্তিক খরচ (${list.length} টি পণ্য)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.table_view_rounded, size: 16),
              label: const Text('পণ্যসহ CSV'),
              onPressed: () => controller.exportDetailedCsv(),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
          itemBuilder: (context, index) {
            final p = list[index];
            final unitLabel = _formatUnit(p.unit);
            final qtyStr = p.totalQuantity > 0
                ? '${p.totalQuantity.toStringAsFixed(p.totalQuantity.truncateToDouble() == p.totalQuantity ? 0 : 2)} $unitLabel'
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
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p12),
                child: Row(
                  children: [
                    AppImage(
                      imagePath: p.imagePath,
                      width: 40,
                      height: 40,
                      borderRadius: AppSizes.r8,
                      fallbackIcon: Icons.fastfood_outlined,
                      fallbackColor: AppColors.secondaryElectric,
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.productName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (qtyStr.isNotEmpty)
                                Text(
                                  'পরিমাণ: $qtyStr',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              if (qtyStr.isNotEmpty)
                                const SizedBox(width: 8),
                              Text(
                                '• ${p.purchaseCount} বার',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                          if (p.avgPriceMinor > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              'গড় দর: ${CurrencyUtils.format(p.avgPriceMinor)} / $unitLabel',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryElectric,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      CurrencyUtils.format(p.totalAmountMinor),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.expenseRed,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatUnit(String unit) {
    switch (unit) {
      case 'kg':
        return 'কেজি';
      case 'liter':
        return 'লিটার';
      case 'piece':
        return 'পিস';
      case 'packet':
        return 'প্যাকেট';
      case 'g':
        return 'গ্রাম';
      case 'ml':
        return 'মিলি';
      case 'dozen':
        return 'ডজন';
      case 'box':
        return 'বক্স';
      case 'bottle':
        return 'বোতল';
      case 'carton':
        return 'কার্টন';
      default:
        return unit;
    }
  }
}
