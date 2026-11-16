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
import '../controllers/household_controller.dart';

class ShoppingView extends GetView<HouseholdController> {
  const ShoppingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('household_shopping'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist_rounded),
            onPressed: () => Get.toNamed(AppRoutes.shoppingLists),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.shoppingRecords.isEmpty) {
          return AppEmptyState(
            message: 'বাজারের কোন হিসাব যুক্ত নেই',
            actionText: 'add_shopping_entry'.tr,
            onAction: () => Get.toNamed(AppRoutes.shoppingEntry),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: controller.shoppingRecords.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
          itemBuilder: (context, index) {
            final record = controller.shoppingRecords[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                  child: const Icon(AppIcons.shopping, color: AppColors.primaryNavy),
                ),
                title: Text(
                  record.storeName?.isNotEmpty == true ? record.storeName! : 'দৈনিক বাজার',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  AppDateUtils.formatTimestamp(record.shoppingDate),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyUtils.format(record.totalMinor),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.expenseRed),
                    ),
                    if (record.dueMinor > 0)
                      Text(
                        'বকেয়া: ${CurrencyUtils.format(record.dueMinor)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.warningAmberDark, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.shoppingEntry),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
