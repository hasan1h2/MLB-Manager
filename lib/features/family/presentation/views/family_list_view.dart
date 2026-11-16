import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/family_controller.dart';

class FamilyListView extends GetView<FamilyController> {
  const FamilyListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('family_management'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.security_rounded),
            onPressed: () => Get.toNamed(AppRoutes.familyPermissions),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.members.isEmpty) {
          return AppEmptyState(
            message: 'পরিবারের কোন সদস্য যুক্ত নেই',
            actionText: 'add_family_member'.tr,
            onAction: () => Get.toNamed(AppRoutes.addFamilyMember),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: controller.members.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
          itemBuilder: (context, index) {
            final member = controller.members[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                  child: const Icon(AppIcons.family, color: AppColors.primaryNavy),
                ),
                title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(
                  '${member.relationship ?? 'সদস্য'} • ${member.role.toUpperCase()}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.expenseRed, size: 20),
                  onPressed: () => controller.deactivateMember(member),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addFamilyMember),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
