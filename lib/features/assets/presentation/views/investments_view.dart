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

class InvestmentsView extends GetView<AssetController> {
  const InvestmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('investments'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.investments.isEmpty) {
          return AppEmptyState(
            message: 'কোন বিনিয়োগ রেকর্ড নেই',
            actionText: 'add_investment'.tr,
            onAction: () => Get.toNamed(AppRoutes.addInvestment),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: controller.investments.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
          itemBuilder: (context, index) {
            final inv = controller.investments[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.incomeGreen.withValues(alpha: 0.12),
                  child: const Icon(AppIcons.investments, color: AppColors.incomeGreen),
                ),
                title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(
                  '${inv.investmentType.toUpperCase()} • ${AppDateUtils.formatTimestamp(inv.investmentDate)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                trailing: Text(
                  CurrencyUtils.format(inv.currentValueMinor),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryNavy),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addInvestment),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
