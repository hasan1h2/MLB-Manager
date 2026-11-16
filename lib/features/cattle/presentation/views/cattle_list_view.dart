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
import '../controllers/cattle_controller.dart';

class CattleListView extends GetView<CattleController> {
  const CattleListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('cattle_management'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.cattleList.isEmpty) {
          return AppEmptyState(
            message: 'খামারে কোন গরু নিবন্ধিত নেই',
            actionText: 'add_cattle'.tr,
            onAction: () => Get.toNamed(AppRoutes.addCattle),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: controller.cattleList.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
          itemBuilder: (context, index) {
            final c = controller.cattleList[index];
            final isSold = c.status == 'sold';

            return Card(
              child: ListTile(
                leading: AppImage(
                  imagePath: c.photoPath,
                  width: 46,
                  height: 46,
                  borderRadius: AppSizes.rFull,
                  fallbackIcon: AppIcons.cattle,
                  fallbackColor: isSold ? Colors.white : AppColors.tagBull,
                  backgroundColor: isSold ? AppColors.textMutedLight : AppColors.tagBull.withValues(alpha: 0.15),
                ),
                title: Text(
                  '${c.tagNumber} ${c.name?.isNotEmpty == true ? '(${c.name})' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  '${c.breed ?? 'জাত নেই'} • ${c.gender?.toUpperCase()} • ${c.weightKg ?? 0} কেজি',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyUtils.format(c.purchasePriceMinor),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSold ? AppColors.incomeGreenLight : AppColors.secondaryElectric.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isSold ? 'বিক্রিত' : 'সক্রিয়',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSold ? AppColors.incomeGreenDark : AppColors.secondaryElectric,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  controller.loadCattleDetails(c);
                  Get.toNamed(AppRoutes.cattleDetails);
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addCattle),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
