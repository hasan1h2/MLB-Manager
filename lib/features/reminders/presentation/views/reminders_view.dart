import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/reminder_controller.dart';

class RemindersView extends GetView<ReminderController> {
  const RemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('upcoming_payments'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.reminders.isEmpty) {
          return AppEmptyState(
            message: 'কোন সতর্কবার্তা বা রিমাইন্ডার নেই',
            actionText: 'নতুন রিমাইন্ডার',
            onAction: () => _showAddReminderDialog(context),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: controller.reminders.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
          itemBuilder: (context, index) {
            final r = controller.reminders[index];
            final isDone = r.isCompleted == 1;

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (isDone ? AppColors.textMutedLight : AppColors.warningAmber).withValues(alpha: 0.15),
                  child: Icon(
                    AppIcons.notifications,
                    color: isDone ? Colors.grey : AppColors.warningAmberDark,
                  ),
                ),
                title: Text(
                  r.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  'নির্ধারিত তারিখ: ${AppDateUtils.formatTimestamp(r.scheduledAt)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                trailing: isDone
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.incomeGreen)
                    : IconButton(
                        icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.secondaryElectric),
                        onPressed: () => controller.markCompleted(r.id),
                      ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r12)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('নতুন রিমাইন্ডার যোগ করুন', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 16),
              AppTextField(label: 'শিরোনাম / বিষয়', controller: controller.titleController, hint: 'যেমন: বিদ্যুৎ বিল, ঋণের কিস্তি'),
              const SizedBox(height: 12),
              AppTextField(label: 'বিবরণ (ঐচ্ছিক)', controller: controller.descController),
              const SizedBox(height: 24),
              AppButton(
                text: 'save'.tr,
                onPressed: () async {
                  final ok = await controller.saveReminder();
                  if (ok) {
                    Get.back();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
