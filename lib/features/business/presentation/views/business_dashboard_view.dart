import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/summary_card.dart';
import '../controllers/business_controller.dart';

class BusinessDashboardView extends GetView<BusinessController> {
  const BusinessDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Obx(() => Text(controller.selectedBusiness.value?.name ?? 'business_dashboard'.tr)),
      ),
      body: Obx(() {
        final b = controller.selectedBusiness.value;
        final m = controller.currentMetrics.value;

        if (b == null || m == null) {
          return const AppLoadingIndicator();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBusinessInfoCard(b),
              const SizedBox(height: AppSizes.p16),
              _buildMetricsGrid(m),
              const SizedBox(height: AppSizes.p24),
              _buildQuickActionButtons(),
              const SizedBox(height: AppSizes.p32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBusinessInfoCard(dynamic b) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            b.name,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSizes.p4),
          Text(
            '${b.businessType.toUpperCase()} • ${b.location ?? ''}',
            style: const TextStyle(color: AppColors.secondaryElectricLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BusinessDashboardMetrics m) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSizes.p12,
      mainAxisSpacing: AppSizes.p12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: [
        SummaryCard(
          title: 'total_sales'.tr,
          amountMinor: m.totalSalesMinor,
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.incomeGreen,
        ),
        SummaryCard(
          title: 'total_purchases'.tr,
          amountMinor: m.totalPurchasesMinor,
          icon: Icons.shopping_bag_outlined,
          iconColor: AppColors.expenseRed,
        ),
        SummaryCard(
          title: 'operating_expenses'.tr,
          amountMinor: m.operatingExpensesMinor,
          icon: Icons.receipt_long_rounded,
          iconColor: AppColors.warningAmber,
        ),
        SummaryCard(
          title: 'net_profit'.tr,
          amountMinor: m.netProfitMinor,
          icon: AppIcons.business,
          iconColor: m.netProfitMinor >= 0 ? AppColors.incomeGreen : AppColors.expenseRed,
        ),
        SummaryCard(
          title: 'inventory_value'.tr,
          amountMinor: m.inventoryValueMinor,
          icon: AppIcons.inventory,
          iconColor: AppColors.secondaryElectric,
        ),
        SummaryCard(
          title: 'outstanding_due'.tr,
          amountMinor: m.customerReceivablesMinor,
          icon: AppIcons.customers,
          iconColor: AppColors.infoBlue,
        ),
        SummaryCard(
          title: 'outstanding_payable'.tr,
          amountMinor: m.supplierPayablesMinor,
          icon: AppIcons.suppliers,
          iconColor: AppColors.warningAmberDark,
        ),
      ],
    );
  }

  Widget _buildQuickActionButtons() {
    return Column(
      children: [
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r8),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          tileColor: Colors.white,
          leading: const Icon(AppIcons.inventory, color: AppColors.secondaryElectric),
          title: Text('inventory_management'.tr),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () => Get.toNamed(AppRoutes.productList),
        ),
        const SizedBox(height: AppSizes.p8),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r8),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          tileColor: Colors.white,
          leading: const Icon(AppIcons.customers, color: AppColors.infoBlue),
          title: Text('customers'.tr),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () => Get.toNamed(AppRoutes.customerList),
        ),
        const SizedBox(height: AppSizes.p8),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r8),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          tileColor: Colors.white,
          leading: const Icon(AppIcons.suppliers, color: AppColors.warningAmber),
          title: Text('suppliers'.tr),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () => Get.toNamed(AppRoutes.supplierList),
        ),
      ],
    );
  }
}
