import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/asset_controller.dart';

class SavingsGoalsView extends GetView<AssetController> {
  const SavingsGoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('savings_goals'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.savingsGoals.isEmpty) {
          return AppEmptyState(
            message: 'কোন সঞ্চয় লক্ষ্য যুক্ত নেই',
            actionText: 'add_savings_goal'.tr,
            onAction: () => Get.toNamed(AppRoutes.addSavingsGoal),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: controller.savingsGoals.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
          itemBuilder: (context, index) {
            final g = controller.savingsGoals[index];
            final percent = g.targetAmountMinor > 0
                ? (g.currentAmountMinor / g.targetAmountMinor).clamp(0.0, 1.0)
                : 0.0;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(
                          '${(percent * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.incomeGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 8,
                        backgroundColor: AppColors.dividerLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.incomeGreen),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('জমা: ${CurrencyUtils.format(g.currentAmountMinor)}', style: const TextStyle(fontSize: 12)),
                        Text('লক্ষ্য: ${CurrencyUtils.format(g.targetAmountMinor)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'টার্গেট তারিখ: ${AppDateUtils.formatTimestamp(g.targetDate)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addSavingsGoal),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
