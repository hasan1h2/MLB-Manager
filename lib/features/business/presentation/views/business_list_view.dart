import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/business_controller.dart';

class BusinessListView extends GetView<BusinessController> {
  const BusinessListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('nav_business'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.businesses.isEmpty) {
          return AppEmptyState(
            message: 'কোন ব্যবসা যুক্ত নেই',
            actionText: 'add_business'.tr,
            onAction: () => Get.toNamed(AppRoutes.addBusiness),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: controller.businesses.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
          itemBuilder: (context, index) {
            final b = controller.businesses[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      AppColors.secondaryElectric.withValues(alpha: 0.12),
                  child: const Icon(AppIcons.business,
                      color: AppColors.secondaryElectric),
                ),
                title: Text(b.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(
                  '${b.businessType.toUpperCase()} • ${b.location ?? 'লোকেশন নেই'}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  controller.selectBusinessForDashboard(b);
                  Get.toNamed(AppRoutes.businessDashboard);
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addBusiness),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
