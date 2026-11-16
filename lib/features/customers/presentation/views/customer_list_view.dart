import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/party_controller.dart';

class CustomerListView extends GetView<PartyController> {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('customers'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.customersWithDue.isEmpty) {
          return AppEmptyState(
            message: 'কোন কাস্টমার যুক্ত নেই',
            actionText: 'add_customer'.tr,
            onAction: () => Get.toNamed(AppRoutes.addCustomer),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadParties,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: controller.customersWithDue.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
            itemBuilder: (context, index) {
              final item = controller.customersWithDue[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.infoBlue.withValues(alpha: 0.12),
                    child: const Icon(AppIcons.customers, color: AppColors.infoBlue),
                  ),
                  title: Text(item.customer.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text(
                    item.customer.phone ?? 'ফোন নম্বর নেই',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyUtils.format(item.dueMinor),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: item.dueMinor > 0 ? AppColors.expenseRed : AppColors.incomeGreen,
                        ),
                      ),
                      Text(
                        item.dueMinor > 0 ? 'বাকি পাওনা' : 'পরিশোধিত',
                        style: TextStyle(
                          fontSize: 10,
                          color: item.dueMinor > 0 ? AppColors.expenseRed : AppColors.incomeGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.customerLedger, arguments: item);
                  },
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addCustomer),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
