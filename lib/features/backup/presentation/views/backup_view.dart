import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/backup_controller.dart';

class BackupView extends GetView<BackupController> {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('backup_restore'.tr),
      ),
      body: Obx(() {
        if (controller.isOperating.value) {
          return const AppLoadingIndicator(message: 'প্রসেসিং হচ্ছে...');
        }

        return Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p20),
                  child: Column(
                    children: [
                      const Icon(AppIcons.backup, size: 56, color: AppColors.secondaryElectric),
                      const SizedBox(height: AppSizes.p16),
                      Text(
                        'create_backup'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      const Text(
                        'আপনার সম্পূর্ণ আর্থিক ডাটাবেজ, পারিবারিক খরচ ও ব্যবসার রেকর্ডসমূহ সুরক্ষিত JSON ফাইলে ব্যাকআপ নিন।',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: AppSizes.p20),
                      AppButton(
                        text: 'create_backup'.tr,
                        onPressed: () => controller.createJsonBackup(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p20),
                  child: Column(
                    children: [
                      const Icon(Icons.settings_backup_restore_rounded, size: 56, color: AppColors.warningAmberDark),
                      const SizedBox(height: AppSizes.p16),
                      Text(
                        'restore_backup'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      const Text(
                        'পূর্বে সংরক্ষিত ব্যাকআপ ফাইল সিলেক্ট করে ডাটা রিস্টোর করুন। রিস্টোর করার আগে ব্যাকআপের অখণ্ডতা যাচাই করা হবে।',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: AppSizes.p20),
                      AppButton(
                        text: 'restore_backup'.tr,
                        backgroundColor: AppColors.warningAmberDark,
                        onPressed: () {
                          AppConfirmDialog.show(
                            title: 'রিস্টোর সতর্কতা',
                            message: 'ব্যাকআপ রিস্টোর করার সময় বর্তমান ডাটার সাথে সমন্বয় করা হবে। আপনি কি নিশ্চিত?',
                            onConfirm: () => controller.restoreBackup(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
