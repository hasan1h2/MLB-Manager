import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/summary_card.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'app_short_name'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              'app_tagline'.tr,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.notifications),
            onPressed: () => Get.toNamed(AppRoutes.reminders),
          ),
          IconButton(
            icon: const Icon(AppIcons.settings),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        return RefreshIndicator(
          onRefresh: controller.loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateFilters(),
                const SizedBox(height: AppSizes.p16),
                _buildAvailableBalanceCard(),
                const SizedBox(height: AppSizes.p16),
                _buildSummaryGrid(),
                const SizedBox(height: AppSizes.p20),
                _buildIncomeVsExpenseBar(),
                const SizedBox(height: AppSizes.p20),
                _buildFinancialInsightCard(),
                const SizedBox(height: AppSizes.p20),
                _buildRecentTransactionsHeader(),
                const SizedBox(height: AppSizes.p8),
                _buildRecentTransactionsList(),
                if (controller.lowStockProducts.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.p20),
                  _buildLowStockSection(),
                ],
                const SizedBox(height: AppSizes.p32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateFilters() {
    final filters = [
      'filter_today',
      'filter_yesterday',
      'filter_last_7_days',
      'filter_this_month',
      'filter_last_month',
      'filter_this_year',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filterKey) {
          final isSelected = controller.selectedFilter.value == filterKey;
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.p8),
            child: ChoiceChip(
              label: Text(filterKey.tr),
              selected: isSelected,
              selectedColor: AppColors.primaryNavy,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryNavy : AppColors.borderLight,
              ),
              onSelected: (_) => controller.setDateFilter(filterKey),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAvailableBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryNavy, AppColors.primaryNavyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.r16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total_available_balance'.tr,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.secondaryElectricLight),
            ],
          ),
          const SizedBox(height: AppSizes.p12),
          Text(
            CurrencyUtils.format(controller.totalAvailableBalanceMinor.value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSizes.p12,
      mainAxisSpacing: AppSizes.p12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: [
        SummaryCard(
          title: 'total_income'.tr,
          amountMinor: controller.totalIncomeMinor.value,
          icon: AppIcons.income,
          iconColor: AppColors.incomeGreen,
        ),
        SummaryCard(
          title: 'total_expenses'.tr,
          amountMinor: controller.totalExpensesMinor.value,
          icon: AppIcons.expense,
          iconColor: AppColors.expenseRed,
        ),
        SummaryCard(
          title: 'business_profit'.tr,
          amountMinor: controller.businessProfitMinor.value,
          icon: AppIcons.business,
          iconColor: AppColors.secondaryElectric,
        ),
        SummaryCard(
          title: 'money_receivable'.tr,
          amountMinor: controller.moneyReceivableMinor.value,
          icon: Icons.call_received_rounded,
          iconColor: AppColors.infoBlue,
        ),
        SummaryCard(
          title: 'money_payable'.tr,
          amountMinor: controller.moneyPayableMinor.value,
          icon: Icons.call_made_rounded,
          iconColor: AppColors.warningAmber,
        ),
        SummaryCard(
          title: 'total_savings'.tr,
          amountMinor: controller.totalSavingsMinor.value,
          icon: AppIcons.savings,
          iconColor: AppColors.incomeGreenDark,
        ),
      ],
    );
  }

  Widget _buildIncomeVsExpenseBar() {
    final income = controller.totalIncomeMinor.value;
    final expense = controller.totalExpensesMinor.value;
    final total = income + expense;

    final incomePercent = total > 0 ? (income / total) : 0.5;
    final expensePercent = total > 0 ? (expense / total) : 0.5;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'income_vs_expense'.tr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.p12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.r8),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    Expanded(
                      flex: (incomePercent * 100).toInt().clamp(1, 100),
                      child: Container(color: AppColors.incomeGreen),
                    ),
                    Expanded(
                      flex: (expensePercent * 100).toInt().clamp(1, 100),
                      child: Container(color: AppColors.expenseRed),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.incomeGreen, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('${'total_income'.tr}: ${(incomePercent * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11)),
                  ],
                ),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.expenseRed, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('${'total_expenses'.tr}: ${(expensePercent * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialInsightCard() {
    return Card(
      color: AppColors.infoBlueLight,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.ai, color: AppColors.secondaryElectric, size: 24),
            ),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'financial_insights'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryNavy),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.totalExpensesMinor.value > controller.totalIncomeMinor.value
                        ? 'আপনার বর্তমান খরচ আয়ের চেয়ে বেশি হচ্ছে। বাজেট নিয়ন্ত্রণে রাখুন।'
                        : 'আপনার আয়ের অনুপাত ইতিবাচক রয়েছে। সঞ্চয় লক্ষ্য পূরণ করুন।',
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimaryLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'recent_transactions'.tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.transactionList),
          child: Text('view_all'.tr),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsList() {
    if (controller.recentTransactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Center(
            child: Text(
              'no_data_found'.tr,
              style: const TextStyle(color: AppColors.textSecondaryLight),
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentTransactions.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
        itemBuilder: (context, index) {
          final tx = controller.recentTransactions[index];
          final isIncome = tx.transactionType == 'income';
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? AppColors.incomeGreenLight : AppColors.expenseRedLight,
              child: Icon(
                isIncome ? AppIcons.income : AppIcons.expense,
                color: isIncome ? AppColors.incomeGreen : AppColors.expenseRed,
                size: 20,
              ),
            ),
            title: Text(
              tx.description?.isNotEmpty == true ? tx.description! : tx.transactionNumber,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              AppDateUtils.formatTimestamp(tx.transactionDate),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}${CurrencyUtils.format(tx.amountMinor)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isIncome ? AppColors.incomeGreen : AppColors.expenseRed,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLowStockSection() {
    return Card(
      color: AppColors.warningAmberLight,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.warningAmberDark),
                const SizedBox(width: AppSizes.p8),
                Text(
                  'low_stock_alerts'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.warningAmberDark),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p8),
            for (var p in controller.lowStockProducts.take(3))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• ${p.name} (ন্যূনতম সীমা: ${p.minimumStock} ${p.unit})'),
              ),
          ],
        ),
      ),
    );
  }
}
