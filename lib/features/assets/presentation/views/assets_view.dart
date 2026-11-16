import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/asset_controller.dart';

class AssetsView extends GetView<AssetController> {
  const AssetsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('assets'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.assets.isEmpty) {
          return AppEmptyState(
            message: 'কোন সম্পদ যুক্ত নেই',
            actionText: 'add_asset'.tr,
            onAction: () => Get.toNamed(AppRoutes.addAsset),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: controller.assets.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
          itemBuilder: (context, index) {
            final a = controller.assets[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                  child: const Icon(AppIcons.assets, color: AppColors.primaryNavy),
                ),
                title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(
                  'ক্যাটাগরি: ${a.category.toUpperCase()}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                trailing: Text(
                  CurrencyUtils.format(a.currentValueMinor),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryNavy),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addAsset),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
