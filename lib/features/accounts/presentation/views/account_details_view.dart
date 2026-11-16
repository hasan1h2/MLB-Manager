import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../controllers/account_controller.dart';

class AccountDetailsView extends StatelessWidget {
  const AccountDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as AccountItemWithBalance?;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('হিসাবের বিবরণ')),
        body: const Center(child: Text('হিসাব খুঁজে পাওয়া যায়নি')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(item.account.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p20),
                child: Column(
                  children: [
                    Text(
                      'current_balance'.tr,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      CurrencyUtils.format(item.balanceMinor),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                    const Divider(),
                    const SizedBox(height: AppSizes.p8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('opening_balance'.tr, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                        Text(CurrencyUtils.format(item.account.openingBalanceMinor), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('account_type'.tr, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                        Text(item.account.accountType.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p20),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.r8),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              tileColor: Colors.white,
              leading: const Icon(AppIcons.transfer, color: AppColors.secondaryElectric),
              title: const Text('এই হিসাব থেকে স্থানান্তর করুন'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Get.toNamed(AppRoutes.addTransfer);
              },
            ),
          ],
        ),
      ),
    );
  }
}
