import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';

class MoreMenuView extends StatelessWidget {
  const MoreMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final menuItems = [
      {'title': 'family_management'.tr, 'icon': AppIcons.family, 'color': Colors.blue, 'route': AppRoutes.familyList},
      {'title': 'household_shopping'.tr, 'icon': AppIcons.shopping, 'color': Colors.teal, 'route': AppRoutes.householdShopping},
      {'title': 'cattle_management'.tr, 'icon': AppIcons.cattle, 'color': Colors.brown, 'route': AppRoutes.cattleList},
      {'title': 'inventory_management'.tr, 'icon': AppIcons.inventory, 'color': Colors.indigo, 'route': AppRoutes.productList},
      {'title': 'customers'.tr, 'icon': AppIcons.customers, 'color': Colors.cyan, 'route': AppRoutes.customerList},
      {'title': 'suppliers'.tr, 'icon': AppIcons.suppliers, 'color': Colors.deepOrange, 'route': AppRoutes.supplierList},
      {'title': 'loan_management'.tr, 'icon': AppIcons.loans, 'color': Colors.amber.shade800, 'route': AppRoutes.loanList},
      {'title': 'accounts_wallets'.tr, 'icon': AppIcons.accounts, 'color': Colors.green, 'route': AppRoutes.accountList},
      {'title': 'assets'.tr, 'icon': AppIcons.assets, 'color': Colors.deepPurple, 'route': AppRoutes.assetsList},
      {'title': 'savings_goals'.tr, 'icon': AppIcons.savings, 'color': Colors.pink, 'route': AppRoutes.savingsGoals},
      {'title': 'investments'.tr, 'icon': AppIcons.investments, 'color': Colors.blueGrey, 'route': AppRoutes.investmentsList},
      {'title': 'budget_management'.tr, 'icon': AppIcons.budgets, 'color': Colors.orange, 'route': AppRoutes.budgetList},
      {'title': 'ai_assistant'.tr, 'icon': AppIcons.ai, 'color': AppColors.secondaryElectric, 'route': AppRoutes.aiAssistant},
      {'title': 'voice_entry'.tr, 'icon': AppIcons.mic, 'color': Colors.redAccent, 'route': AppRoutes.voiceEntry},
      {'title': 'ocr_receipt_scanner'.tr, 'icon': AppIcons.ocr, 'color': Colors.purple, 'route': AppRoutes.receiptScanner},
      {'title': 'upcoming_payments'.tr, 'icon': AppIcons.notifications, 'color': Colors.blue, 'route': AppRoutes.reminders},
      {'title': 'documents'.tr, 'icon': AppIcons.documents, 'color': Colors.blueGrey, 'route': AppRoutes.documents},
      {'title': 'backup_restore'.tr, 'icon': AppIcons.backup, 'color': Colors.teal, 'route': AppRoutes.backup},
      {'title': 'settings'.tr, 'icon': AppIcons.settings, 'color': Colors.grey.shade600, 'route': AppRoutes.settings},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('nav_more'.tr),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 3;
          double aspectRatio = 0.88;

          if (constraints.maxWidth >= 900) {
            crossAxisCount = 6;
            aspectRatio = 1.0;
          } else if (constraints.maxWidth >= 600) {
            crossAxisCount = 4;
            aspectRatio = 0.95;
          } else if (constraints.maxWidth < 360) {
            crossAxisCount = 2;
            aspectRatio = 1.1;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSizes.p16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppSizes.p12,
              mainAxisSpacing: AppSizes.p12,
              childAspectRatio: aspectRatio,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final color = item['color'] as Color;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                  onTap: () => Get.toNamed(item['route'] as String),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p8, vertical: AppSizes.p10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.p10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item['icon'] as IconData, color: color, size: 26),
                        ),
                        const SizedBox(height: AppSizes.p8),
                        Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
