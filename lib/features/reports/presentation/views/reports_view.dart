import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
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
              _buildFilterChips(isDark),
              const SizedBox(height: AppSizes.p16),
              _buildProfitLossCard(data),
              const SizedBox(height: AppSizes.p20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'লেনদেনের বিবরণী (${data.transactions.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.table_rows_rounded, size: 16),
                    label: Text('export_csv'.tr),
                    onPressed: () => controller.exportCsv(),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p8),
              _buildTransactionsList(data),
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

  Widget _buildProfitLossCard(ReportSummaryData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('total_income'.tr,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondaryLight)),
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
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondaryLight)),
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
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'নিট লাভ / উদ্বৃত্ত',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                Text(
                  CurrencyUtils.format(data.netProfitMinor),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
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

  Widget _buildTransactionsList(ReportSummaryData data) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.transactions.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
        itemBuilder: (context, index) {
          final tx = data.transactions[index];
          final isIncome = tx.transactionType == 'income';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  (isIncome ? AppColors.incomeGreen : AppColors.expenseRed)
                      .withValues(alpha: 0.12),
              child: Icon(
                isIncome ? AppIcons.income : AppIcons.expense,
                color: isIncome ? AppColors.incomeGreen : AppColors.expenseRed,
                size: 20,
              ),
            ),
            title: Text(tx.description?.isNotEmpty == true
                ? tx.description!
                : tx.transactionNumber),
            subtitle: Text(AppDateUtils.formatTimestamp(tx.transactionDate)),
            trailing: Text(
              '${isIncome ? '+' : '-'}${CurrencyUtils.format(tx.amountMinor)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.incomeGreen : AppColors.expenseRed,
              ),
            ),
          );
        },
      ),
    );
  }
}
