import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/budget_controller.dart';

class BudgetListView extends GetView<BudgetController> {
  const BudgetListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('budget_management'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.budgetsWithSpending.isEmpty) {
          return AppEmptyState(
            message: 'কোন বাজেট পরিকল্পনা যুক্ত নেই',
            actionText: 'add_budget'.tr,
            onAction: () => Get.toNamed(AppRoutes.addBudget),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadBudgets,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: controller.budgetsWithSpending.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p12),
            itemBuilder: (context, index) {
              final b = controller.budgetsWithSpending[index];
              Color barColor = AppColors.incomeGreen;
              if (b.isOverBudget) {
                barColor = AppColors.expenseRed;
              } else if (b.isWarning) {
                barColor = AppColors.warningAmber;
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(b.budget.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: barColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${(b.utilizationPercent * 100).toStringAsFixed(0)}% ব্যবহৃত',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: barColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: b.utilizationPercent.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: AppColors.dividerLight,
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'খরচ: ${CurrencyUtils.format(b.actualSpendingMinor)}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight),
                          ),
                          Text(
                            'বাজেট সীমা: ${CurrencyUtils.format(b.budget.limitMinor)}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            b.isOverBudget
                                ? 'বাজেট অতিক্রম করেছে!'
                                : 'অবশিষ্ট: ${CurrencyUtils.format(b.remainingMinor)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: b.isOverBudget
                                  ? AppColors.expenseRed
                                  : AppColors.incomeGreenDark,
                            ),
                          ),
                          Text(
                            'স্কোপ: ${b.budget.scopeType.toUpperCase()}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMutedLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addBudget),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
