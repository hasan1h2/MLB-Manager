import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import 'package:mlb_manager/features/customers/presentation/controllers/party_controller.dart';

class SupplierListView extends GetView<PartyController> {
  const SupplierListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('suppliers'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.suppliersWithPayable.isEmpty) {
          return AppEmptyState(
            message: 'কোন সাপ্লায়ার যুক্ত নেই',
            actionText: 'add_supplier'.tr,
            onAction: () => Get.toNamed(AppRoutes.addSupplier),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadParties,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: controller.suppliersWithPayable.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
            itemBuilder: (context, index) {
              final item = controller.suppliersWithPayable[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.warningAmber.withValues(alpha: 0.15),
                    child: const Icon(AppIcons.suppliers,
                        color: AppColors.warningAmberDark),
                  ),
                  title: Text(item.supplier.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text(
                    item.supplier.phone ?? 'ফোন নম্বর নেই',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyUtils.format(item.payableMinor),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: item.payableMinor > 0
                              ? AppColors.warningAmberDark
                              : AppColors.incomeGreen,
                        ),
                      ),
                      Text(
                        item.payableMinor > 0 ? 'বকেয়া দেনা' : 'পরিশোধিত',
                        style: TextStyle(
                          fontSize: 10,
                          color: item.payableMinor > 0
                              ? AppColors.warningAmberDark
                              : AppColors.incomeGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.supplierLedger, arguments: item);
                  },
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addSupplier),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
