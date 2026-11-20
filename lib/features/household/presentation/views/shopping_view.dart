import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart' hide DateTimeRange;
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/household_controller.dart';

class ShoppingView extends GetView<HouseholdController> {
  const ShoppingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('household_shopping'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist_rounded),
            tooltip: 'shopping_lists'.tr,
            onPressed: () => Get.toNamed(AppRoutes.shoppingLists),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Date Filter Bar
          _buildSearchAndFilterBar(context, isDark),

          // Tab Bar: [ কেনাকাটার ইতিহাস | পণ্যভিত্তিক সারাংশ ]
          _buildTabSelector(isDark),

          // Tab Contents
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoadingIndicator();
              }

              if (controller.selectedViewTab.value == 0) {
                return _buildHistoryTab(context, isDark);
              } else {
                return _buildProductSummaryTab(context, isDark);
              }
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.shoppingEntry),
        backgroundColor: AppColors.secondaryElectric,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16, vertical: AppSizes.p10),
      color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      child: Column(
        children: [
          Row(
            children: [
              // Search Input
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'দোকান, পণ্যের নাম বা নোট খুঁজুন...',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 18, color: AppColors.secondaryElectric),
                      suffixIcon: Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () => controller.searchQuery.value = '',
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.p8),

              // Date Filter Button
              Obx(() {
                final range = controller.selectedDateRange.value;
                final hasFilter = range != null;

                return InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  onTap: () async {
                    if (hasFilter) {
                      controller.selectedDateRange.value = null;
                      return;
                    }
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDateRange: range ??
                          DateTimeRange(
                            start: DateTime.now()
                                .subtract(const Duration(days: 30)),
                            end: DateTime.now(),
                          ),
                    );
                    if (picked != null) {
                      controller.selectedDateRange.value = picked;
                    }
                  },
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: hasFilter
                          ? AppColors.secondaryElectric.withValues(alpha: 0.15)
                          : (isDark ? AppColors.cardDark : Colors.white),
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                      border: Border.all(
                        color: hasFilter
                            ? AppColors.secondaryElectric
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.calendar,
                          size: 16,
                          color: hasFilter
                              ? AppColors.secondaryElectric
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                        if (hasFilter) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.close_rounded,
                              size: 14, color: AppColors.expenseRed),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    return Obx(() {
      final tab = controller.selectedViewTab.value;
      return Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSizes.p16, vertical: AppSizes.p8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSizes.r8),
                onTap: () => controller.selectedViewTab.value = 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: tab == 0
                        ? (isDark
                            ? AppColors.secondaryElectric
                            : AppColors.primaryNavy)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 16,
                        color: tab == 0
                            ? Colors.white
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'কেনাকাটার ইতিহাস',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              tab == 0 ? FontWeight.w700 : FontWeight.w500,
                          color: tab == 0
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSizes.r8),
                onTap: () {
                  controller.selectedViewTab.value = 1;
                  controller.loadProductSummaries();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: tab == 1
                        ? (isDark
                            ? AppColors.secondaryElectric
                            : AppColors.primaryNavy)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 16,
                        color: tab == 1
                            ? Colors.white
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'পণ্যভিত্তিক সারাংশ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              tab == 1 ? FontWeight.w700 : FontWeight.w500,
                          color: tab == 1
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // --- TAB 1: HISTORY TAB ---
  Widget _buildHistoryTab(BuildContext context, bool isDark) {
    final list = controller.filteredShoppingRecords;

    if (list.isEmpty) {
      return AppEmptyState(
        message: controller.searchQuery.value.isNotEmpty ||
                controller.selectedDateRange.value != null
            ? 'খুঁজে পাওয়া যায়নি'
            : 'বাজারের কোন হিসাব যুক্ত নেই',
        actionText: 'add_shopping_entry'.tr,
        onAction: () => Get.toNamed(AppRoutes.shoppingEntry),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.p16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p10),
      itemBuilder: (context, index) {
        final record = list[index];
        final isDirect = record.entryMode == 'direct_total';
        final dateStr = AppDateUtils.standardDateFormat
            .format(DateTime.fromMillisecondsSinceEpoch(record.shoppingDate));
        final timeStr =
            record.purchaseTime != null && record.purchaseTime!.isNotEmpty
                ? ' • ${record.purchaseTime}'
                : '';

        return Card(
          elevation: 0,
          color: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
            side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.r12),
            onTap: () => Get.toNamed(
              AppRoutes.transactionDetails,
              arguments: record,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Store Name, Badges, Total Amount
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: (isDark
                                ? AppColors.secondaryElectric
                                : AppColors.primaryNavy)
                            .withValues(alpha: 0.15),
                        child: Icon(AppIcons.shopping,
                            size: 18,
                            color: isDark
                                ? AppColors.secondaryElectric
                                : AppColors.primaryNavy),
                      ),
                      const SizedBox(width: AppSizes.p10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.storeName?.isNotEmpty == true
                                  ? record.storeName!
                                  : 'দৈনিক বাজার',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$dateStr$timeStr',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyUtils.format(record.totalMinor),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.expenseRed,
                            ),
                          ),
                          if (record.dueMinor > 0)
                            Text(
                              'বকেয়া: ${CurrencyUtils.format(record.dueMinor)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.warningAmberDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      // More Popup Menu (Delete)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        padding: EdgeInsets.zero,
                        onSelected: (val) {
                          if (val == 'view') {
                            Get.toNamed(AppRoutes.transactionDetails,
                                arguments: record);
                          } else if (val == 'delete') {
                            AppConfirmDialog.show(
                              title: 'হিসাব মুছুন',
                              message:
                                  'আপনি কি নিশ্চিত যে এই বাজারের হিসাব এবং সংশ্লিষ্ট লেনদেন স্থায়ীভাবে মুছে ফেলতে চান?',
                              isDestructive: true,
                              onConfirm: () =>
                                  controller.deleteShoppingRecord(record.id),
                            );
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('বিস্তারিত দেখুন'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded,
                                    size: 18, color: AppColors.expenseRed),
                                SizedBox(width: 8),
                                Text('মুছুন',
                                    style:
                                        TextStyle(color: AppColors.expenseRed)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p8),

                  // Bottom Row: Purchased Items Summary / Direct Mode Badge
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.dividerLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isDirect
                              ? Icons.payments_outlined
                              : Icons.shopping_basket_outlined,
                          size: 14,
                          color: AppColors.secondaryElectric,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: FutureBuilder<String>(
                            future: controller.getShortSummary(record.id),
                            builder: (context, snapshot) {
                              final text = snapshot.data ?? 'লোড হচ্ছে...';
                              return Text(
                                text,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 11, color: AppColors.secondaryElectric),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- TAB 2: PRODUCT-WISE SUMMARY TAB ---
  Widget _buildProductSummaryTab(BuildContext context, bool isDark) {
    if (controller.isSummaryLoading.value) {
      return const Center(child: AppLoadingIndicator());
    }

    final products = controller.productSummaries;

    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 48,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight),
              const SizedBox(height: AppSizes.p12),
              Text(
                'কোনো পণ্যের বিবরণ পাওয়া যায়নি',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'পণ্যের তালিকা সহ বাজার এন্ট্রি করলে এখানে পণ্যভিত্তিক মোট পরিমাণ ও খরচ প্রদর্শিত হবে।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.p16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
      itemBuilder: (context, index) {
        final p = products[index];
        final unitLabel = _formatUnit(p.unit);
        final qtyStr = p.totalQuantity > 0
            ? '${p.totalQuantity.toStringAsFixed(p.totalQuantity.truncateToDouble() == p.totalQuantity ? 0 : 2)} $unitLabel'
            : '';

        return Card(
          elevation: 0,
          color: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
            side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p12),
            child: Row(
              children: [
                // Product Thumbnail
                AppImage(
                  imagePath: p.imagePath,
                  width: 44,
                  height: 44,
                  borderRadius: AppSizes.r8,
                  fallbackIcon: Icons.fastfood_outlined,
                  fallbackColor: AppColors.secondaryElectric,
                ),
                const SizedBox(width: AppSizes.p12),

                // Name & Quantity details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.productName,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (qtyStr.isNotEmpty)
                            Text(
                              'মোট: $qtyStr',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          if (qtyStr.isNotEmpty) const SizedBox(width: 8),
                          Text(
                            '• ${p.purchaseCount} বার কেনা হয়েছে',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                      if (p.avgPriceMinor > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'গড় দর: ${CurrencyUtils.format(p.avgPriceMinor)} / $unitLabel',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryElectric,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Total Spend Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'মোট খরচ',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                    Text(
                      CurrencyUtils.format(p.totalAmountMinor),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.expenseRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatUnit(String unit) {
    switch (unit) {
      case 'kg':
        return 'কেজি';
      case 'liter':
        return 'লিটার';
      case 'piece':
        return 'পিস';
      case 'packet':
        return 'প্যাকেট';
      case 'g':
        return 'গ্রাম';
      case 'ml':
        return 'মিলি';
      case 'dozen':
        return 'ডজন';
      case 'box':
        return 'বক্স';
      case 'bottle':
        return 'বোতল';
      case 'carton':
        return 'কার্টন';
      default:
        return unit;
    }
  }
}
