import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/unit_conversion_utils.dart';
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
                    fallbackColor: isLowStock
                        ? AppColors.warningAmberDark
                        : AppColors.secondaryElectric,
                    backgroundColor: isLowStock
                        ? AppColors.warningAmberLight
                        : (isDark
                            ? AppColors.surfaceDark
                            : AppColors.secondaryElectric
                                .withValues(alpha: 0.12)),
                  ),
                  title: Text(item.product.nameBn ?? item.product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text(
                    'ক্রয়: ${CurrencyUtils.format(item.product.purchasePriceMinor)} • খুচরা: ${CurrencyUtils.format(item.product.sellingPriceMinor)}${item.product.wholesalePriceMinor > 0 ? ' • পাইকারি: ${CurrencyUtils.format(item.product.wholesalePriceMinor)}' : ''}${item.product.packageUnit != null && item.product.packageQuantity > 1 ? '\nপ্যাকেজিং: ১ ${item.product.packageUnit} = ${item.product.packageQuantity.toInt()} ${item.product.unit}' : ''}',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
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
                          color: isLowStock
                              ? AppColors.expenseRed
                              : AppColors.primaryNavy,
                        ),
                      ),
                      if (isLowStock)
                        const Text(
                          'কম স্টক!',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.expenseRed,
                              fontWeight: FontWeight.w700),
                        ),
                    ],
                  ),
                  onTap: () {
                    _showProductDetailsModal(context, item);
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

  void _showProductDetailsModal(BuildContext context, ProductWithStock item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final p = item.product;
    final isLowStock = item.currentStock <= p.minimumStock;

    final cat = controller.businessCategories
        .firstWhereOrNull((c) => c.id == p.categoryId);
    final hasPackage = p.packageUnit != null &&
        p.packageUnit!.isNotEmpty &&
        p.packageQuantity > 1;

    final pkgCostMinor = (hasPackage && p.purchasePriceMinor > 0)
        ? (p.purchasePriceMinor * p.packageQuantity).round()
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      p.nameBn ?? p.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              if (p.nameEn != null && p.nameEn!.isNotEmpty)
                Text(
                  p.nameEn!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              const SizedBox(height: 12),

              // Stock Status Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isLowStock
                      ? AppColors.expenseRed.withValues(alpha: isDark ? 0.2 : 0.1)
                      : AppColors.incomeGreen.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isLowStock ? AppColors.expenseRed : AppColors.incomeGreen,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: isLowStock ? AppColors.expenseRed : AppColors.incomeGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLowStock ? 'সতর্কতা: স্টক কম!' : 'স্টক সক্রিয় রয়েছে',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isLowStock ? AppColors.expenseRed : AppColors.incomeGreen,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${item.currentStock % 1 == 0 ? item.currentStock.toInt() : item.currentStock} ${p.unit}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isLowStock ? AppColors.expenseRed : AppColors.incomeGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text('পণ্যের বিবরণ ও প্যাকেজিং তথ্য',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const Divider(),

              _buildDetailRow('ক্যাটাগরি:', cat?.nameBn ?? 'সাধারণ পণ্য'),
              _buildDetailRow('বেস স্টক একক:', UnitConversionUtils.getUnitLabel(p.unit)),

              if (hasPackage) ...[
                _buildDetailRow('প্যাকেজিং ধরণ:', UnitConversionUtils.getUnitLabel(p.packageUnit!)),
                _buildDetailRow(
                  'প্যাকেজের ভেতরের পরিমাণ:',
                  '${p.packageQuantity % 1 == 0 ? p.packageQuantity.toInt() : p.packageQuantity} ${UnitConversionUtils.getShortUnitLabel(p.unit)}',
                ),
                _buildDetailRow(
                  'প্যাকেজ রূপান্তর অনুপাত:',
                  '১ ${UnitConversionUtils.getShortUnitLabel(p.packageUnit!)} = ${p.packageQuantity % 1 == 0 ? p.packageQuantity.toInt() : p.packageQuantity} ${UnitConversionUtils.getShortUnitLabel(p.unit)}',
                ),
                if (pkgCostMinor != null)
                  _buildDetailRow(
                    'প্রতি প্যাকেজ ক্রয় দর:',
                    CurrencyUtils.format(pkgCostMinor),
                  ),
              ],

              _buildDetailRow(
                'প্রতি একক ক্রয় দর:',
                '${CurrencyUtils.format(p.purchasePriceMinor)} / ${UnitConversionUtils.getShortUnitLabel(p.unit)}',
              ),
              _buildDetailRow(
                'খুচরা বিক্রয় মূল্য:',
                '${CurrencyUtils.format(p.sellingPriceMinor)} / ${UnitConversionUtils.getShortUnitLabel(p.unit)}',
              ),
              if (p.wholesalePriceMinor > 0)
                _buildDetailRow(
                  'পাইকারি বিক্রয় মূল্য:',
                  '${CurrencyUtils.format(p.wholesalePriceMinor)} / ${UnitConversionUtils.getShortUnitLabel(p.unit)}',
                ),
              _buildDetailRow(
                'সর্বনিম্ন স্টক সীমা:',
                '${p.minimumStock % 1 == 0 ? p.minimumStock.toInt() : p.minimumStock} ${p.unit}',
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryElectric,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('স্টক আপডেট ও হিস্ট্রি', style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Get.toNamed(AppRoutes.inventoryMovement, arguments: item);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
