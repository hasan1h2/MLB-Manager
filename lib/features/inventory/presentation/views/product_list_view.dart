import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/inventory_controller.dart';

class ProductListView extends GetView<InventoryController> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('inventory_management'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.productsWithStock.isEmpty) {
          return AppEmptyState(
            message: 'কোন পণ্য যুক্ত নেই',
            actionText: 'add_product'.tr,
            onAction: () => Get.toNamed(AppRoutes.addProduct),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadProducts,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: controller.productsWithStock.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
            itemBuilder: (context, index) {
              final item = controller.productsWithStock[index];
              final isLowStock = item.currentStock <= item.product.minimumStock;
              final isDark = Theme.of(context).brightness == Brightness.dark;

              return Card(
                child: ListTile(
                  leading: AppImage(
                    imagePath: null,
                    width: 44,
                    height: 44,
                    borderRadius: AppSizes.r8,
                    fallbackIcon: AppIcons.inventory,
                    fallbackColor: isLowStock ? AppColors.warningAmberDark : AppColors.secondaryElectric,
                    backgroundColor: isLowStock
                        ? AppColors.warningAmberLight
                        : (isDark ? AppColors.surfaceDark : AppColors.secondaryElectric.withValues(alpha: 0.12)),
                  ),
                  title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text(
                    'ক্রয়: ${CurrencyUtils.format(item.product.purchasePriceMinor)} • বিক্রয়: ${CurrencyUtils.format(item.product.sellingPriceMinor)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.currentStock} ${item.product.unit}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isLowStock ? AppColors.expenseRed : AppColors.primaryNavy,
                        ),
                      ),
                      if (isLowStock)
                        const Text(
                          'কম স্টক!',
                          style: TextStyle(fontSize: 10, color: AppColors.expenseRed, fontWeight: FontWeight.w700),
                        ),
                    ],
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.inventoryMovement, arguments: item);
                  },
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addProduct),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
