import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/summary_card.dart';
import '../controllers/business_controller.dart';

class BusinessDashboardView extends GetView<BusinessController> {
  const BusinessDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.selectedBusiness.value?.name ?? 'ব্যবসা ব্যবস্থাপনা',
              style: const TextStyle(fontWeight: FontWeight.w700),
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'ব্যবসার সেটিংস',
            onPressed: () => Get.toNamed(AppRoutes.businessSettings),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.businesses.isEmpty) {
          return AppEmptyState(
            message: 'কোন ব্যবসা যুক্ত নেই',
            actionText: 'নতুন ব্যবসা যোগ করুন',
            onAction: () => Get.toNamed(AppRoutes.addBusiness),
          );
        }

        final b = controller.selectedBusiness.value;
        final m = controller.currentMetrics.value;

        if (b == null) {
          return const AppLoadingIndicator();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.calculateMetrics(b.id);
            await controller.loadRecentTransactions(b.id);
            await controller.checkCashSession(b.id);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBusinessSelectorAndBanner(b, isDark),
                const SizedBox(height: AppSizes.p16),
                _buildPeriodFilterChips(),
                const SizedBox(height: AppSizes.p16),
                _buildCashSessionBanner(isDark),
                const SizedBox(height: AppSizes.p16),
                if (m != null) _buildMetricsSection(m, isDark),
                const SizedBox(height: AppSizes.p24),
                _buildQuickActionGrid(context),
                const SizedBox(height: AppSizes.p24),
                _buildRecentSalesSection(isDark),
                const SizedBox(height: AppSizes.p32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBusinessSelectorAndBanner(dynamic b, bool isDark) {
    String typeLabel;
    Color typeBadgeBg;
    switch (b.businessType) {
      case 'wholesale':
        typeLabel = 'পাইকারি ব্যবসা (Wholesale)';
        typeBadgeBg = AppColors.warningAmberDark;
        break;
      case 'hybrid':
        typeLabel = 'খুচরা + পাইকারি (Hybrid)';
        typeBadgeBg = AppColors.secondaryElectric;
        break;
      case 'cattle':
        typeLabel = 'গরুর খামার (Cattle)';
        typeBadgeBg = AppColors.incomeGreen;
        break;
      case 'retail':
      default:
        typeLabel = 'মুদি ও খুচরা (Retail)';
        typeBadgeBg = AppColors.infoBlue;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  b.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeBadgeBg,
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
                child: Text(
                  typeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p8),
          Row(
            children: [
              if (b.location != null && b.location!.isNotEmpty) ...[
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.secondaryElectricLight),
                const SizedBox(width: 4),
                Text(
                  b.location!,
                  style: const TextStyle(
                      color: AppColors.secondaryElectricLight, fontSize: 13),
                ),
                const SizedBox(width: 12),
              ],
              if (b.phone != null && b.phone!.isNotEmpty) ...[
                const Icon(Icons.phone_outlined,
                    size: 14, color: AppColors.secondaryElectricLight),
                const SizedBox(width: 4),
                Text(
                  b.phone!,
                  style: const TextStyle(
                      color: AppColors.secondaryElectricLight, fontSize: 13),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilterChips() {
    final periods = [
      {'key': 'today', 'label': 'আজ'},
      {'key': 'last_7_days', 'label': 'গত ৭ দিন'},
      {'key': 'this_month', 'label': 'চলতি মাস'},
      {'key': 'this_year', 'label': 'চলতি বছর'},
      {'key': 'all', 'label': 'সব সময়'},
    ];

    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: periods.map((p) {
            final isSelected = controller.selectedPeriod.value == p['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(p['label']!),
                selected: isSelected,
                selectedColor: AppColors.secondaryElectric,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                onSelected: (val) {
                  if (val) controller.setFilterPeriod(p['key']!);
                },
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildCashSessionBanner(bool isDark) {
    final session = controller.activeCashSession.value;
    final isOpen = session != null && session.status == 'open';

    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.cashbook),
      borderRadius: BorderRadius.circular(AppSizes.r12),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p12),
        decoration: BoxDecoration(
          color: isOpen
              ? AppColors.incomeGreen.withValues(alpha: isDark ? 0.2 : 0.1)
              : AppColors.warningAmber.withValues(alpha: isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(AppSizes.r12),
          border: Border.all(
            color: isOpen ? AppColors.incomeGreen : AppColors.warningAmber,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isOpen ? Icons.check_circle_outline : Icons.lock_clock_outlined,
              color: isOpen ? AppColors.incomeGreen : AppColors.warningAmber,
              size: 24,
            ),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOpen
                        ? 'আজকের ক্যাশ খাতা চালু আছে'
                        : 'আজকের ক্যাশ খাতা এখনও চালু হয়নি',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Text(
                    isOpen
                        ? 'প্রারম্ভিক ক্যাশ: ${CurrencyUtils.format(session.openingCashMinor)} • হিসাব দেখতে ট্যাপ করুন'
                        : 'দৈনিক ক্যাশ ক্লোজিং ও ব্যালেন্স মেলাতে ট্যাপ করুন',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(dynamic m, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'আর্থিক পরিসংখ্যান (Financials)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            Text(
              'গ্রস প্রফিট = বিক্রয় - COGS',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSizes.p12,
          mainAxisSpacing: AppSizes.p12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.45,
          children: [
            SummaryCard(
              title: 'মোট বিক্রয় (Net Sales)',
              amountMinor: m.totalSalesMinor,
              icon: Icons.trending_up_rounded,
              iconColor: AppColors.incomeGreen,
            ),
            SummaryCard(
              title: 'বিক্রিত পণ্যের ব্যয় (COGS)',
              amountMinor: m.cogsMinor,
              icon: Icons.inventory_2_outlined,
              iconColor: AppColors.warningAmber,
            ),
            SummaryCard(
              title: 'মোট লাভ (Gross Profit)',
              amountMinor: m.grossProfitMinor,
              icon: Icons.monetization_on_outlined,
              iconColor: m.grossProfitMinor >= 0
                  ? AppColors.incomeGreen
                  : AppColors.expenseRed,
            ),
            SummaryCard(
              title: 'পরিচালন ব্যয় (Expenses)',
              amountMinor: m.operatingExpensesMinor,
              icon: Icons.receipt_long_rounded,
              iconColor: AppColors.expenseRed,
            ),
            SummaryCard(
              title: 'নিট লাভ (Net Profit)',
              amountMinor: m.netProfitMinor,
              icon: AppIcons.business,
              iconColor: m.netProfitMinor >= 0
                  ? AppColors.incomeGreen
                  : AppColors.expenseRed,
            ),
            SummaryCard(
              title: 'বর্তমান মজুদ মূল্য',
              amountMinor: m.inventoryValueMinor,
              icon: AppIcons.inventory,
              iconColor: AppColors.secondaryElectric,
            ),
            SummaryCard(
              title: 'গ্রাহকের নিকট বাকি পাওনা',
              amountMinor: m.customerReceivablesMinor,
              icon: AppIcons.customers,
              iconColor: AppColors.infoBlue,
            ),
            SummaryCard(
              title: 'মহাজনের বকেয়া দেনা',
              amountMinor: m.supplierPayablesMinor,
              icon: AppIcons.suppliers,
              iconColor: AppColors.warningAmberDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    final actions = [
      {
        'title': 'নতুন বিক্রয় (POS)',
        'subtitle': 'খুচরা বিক্রয় কাউন্টার',
        'icon': Icons.point_of_sale_rounded,
        'color': AppColors.incomeGreen,
        'route': AppRoutes.businessSale,
        'arg': 'retail',
      },
      {
        'title': 'পাইকারি বিক্রয়',
        'subtitle': 'বাল্ক / পাইকারি রেট',
        'icon': Icons.local_shipping_outlined,
        'color': AppColors.warningAmberDark,
        'route': AppRoutes.businessSale,
        'arg': 'wholesale',
      },
      {
        'title': 'পণ্য ক্রয় (Purchase)',
        'subtitle': 'মহাজনের মেমো এন্ট্রি',
        'icon': Icons.shopping_cart_checkout_rounded,
        'color': AppColors.secondaryElectric,
        'route': AppRoutes.businessPurchase,
        'arg': null,
      },
      {
        'title': 'মজুদ ও ইনভেন্টরি',
        'subtitle': 'পণ্য ও স্টক পরিচালনা',
        'icon': AppIcons.inventory,
        'color': AppColors.infoBlue,
        'route': AppRoutes.productList,
        'arg': null,
      },
      {
        'title': 'কাস্টমার / বাকি খাতা',
        'subtitle': 'গ্রাহক ও পাওনা টাকা',
        'icon': AppIcons.customers,
        'color': AppColors.incomeGreen,
        'route': AppRoutes.customerList,
        'arg': null,
      },
      {
        'title': 'সাপ্লায়ার / মহাজন',
        'subtitle': 'সাপ্লায়ার ও দেনা টাকা',
        'icon': AppIcons.suppliers,
        'color': AppColors.warningAmber,
        'route': AppRoutes.supplierList,
        'arg': null,
      },
      {
        'title': 'দৈনিক ক্যাশ খাতা',
        'subtitle': 'ক্যাশ ক্লোজিং ও নোট কাউন্ট',
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppColors.secondaryElectricLight,
        'route': AppRoutes.cashbook,
        'arg': null,
      },
      {
        'title': 'পণ্য ইমপোর্ট (OCR)',
        'subtitle': 'Excel, CSV, ক্যামেরা স্ক্যান',
        'icon': Icons.document_scanner_outlined,
        'color': AppColors.infoBlue,
        'route': AppRoutes.productImport,
        'arg': null,
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'কার্যক্রম (Quick Actions)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSizes.p12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSizes.p12,
            mainAxisSpacing: AppSizes.p12,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final a = actions[index];
            return Material(
              color: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.r12),
                side: BorderSide(color: borderColor),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSizes.r12),
                onTap: () {
                  if (a['arg'] != null && a['route'] == AppRoutes.businessSale) {
                    Get.toNamed(a['route'] as String, arguments: a['arg']);
                  } else {
                    Get.toNamed(a['route'] as String);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p12, vertical: AppSizes.p8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            (a['color'] as Color).withValues(alpha: 0.15),
                        child: Icon(a['icon'] as IconData,
                            color: a['color'] as Color, size: 20),
                      ),
                      const SizedBox(width: AppSizes.p10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a['title'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              a['subtitle'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentSalesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'সাম্প্রতিক বিক্রয় (Recent Sales)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.businessSale),
              child: const Text('নতুন বিক্রয় +'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p8),
        Obx(() {
          if (controller.recentSales.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              alignment: Alignment.center,
              child: Text(
                'কোন সাম্প্রতিক বিক্রয় পাওয়া যায়নি',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 13,
                ),
              ),
            );
          }

          return Column(
            children: controller.recentSales.map((sale) {
              return Card(
                margin: const EdgeInsets.only(bottom: AppSizes.p8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: sale.saleType == 'wholesale'
                        ? AppColors.warningAmber.withValues(alpha: 0.15)
                        : AppColors.incomeGreen.withValues(alpha: 0.15),
                    child: Icon(
                      sale.saleType == 'wholesale'
                          ? Icons.local_shipping_outlined
                          : Icons.receipt_outlined,
                      color: sale.saleType == 'wholesale'
                          ? AppColors.warningAmberDark
                          : AppColors.incomeGreen,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'ইনভয়েস #${sale.invoiceNumber ?? sale.id.substring(0, 6)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${sale.saleTime ?? ''} • ${sale.saleType.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyUtils.format(sale.totalMinor),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.incomeGreen,
                        ),
                      ),
                      if (sale.dueMinor > 0)
                        Text(
                          'বাকি: ${CurrencyUtils.format(sale.dueMinor)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.expenseRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.businessTransactionDetails,
                        arguments: {'type': 'sale', 'id': sale.id});
                  },
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
