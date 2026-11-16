import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/account_controller.dart';

class AccountListView extends GetView<AccountController> {
  const AccountListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('accounts_wallets'.tr),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.transfer),
            onPressed: () => Get.toNamed(AppRoutes.addTransfer),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.accountsWithBalance.isEmpty) {
          return AppEmptyState(
            message: 'কোন হিসাব বা ওয়ালেট যুক্ত নেই',
            actionText: 'add_account'.tr,
            onAction: () => Get.toNamed(AppRoutes.addAccount),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadAccountsWithBalances,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: controller.accountsWithBalance.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
            itemBuilder: (context, index) {
              final item = controller.accountsWithBalance[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondaryElectric.withValues(alpha: 0.12),
                    child: const Icon(AppIcons.accounts, color: AppColors.secondaryElectric),
                  ),
                  title: Text(item.account.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text(
                    item.account.accountType.toUpperCase(),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  trailing: Text(
                    CurrencyUtils.format(item.balanceMinor),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: item.balanceMinor < 0 ? AppColors.expenseRed : AppColors.primaryNavy,
                    ),
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.accountDetails, arguments: item);
                  },
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addAccount),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
