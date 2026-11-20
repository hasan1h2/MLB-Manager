import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText,
    this.cancelText,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    cancelText ?? 'cancel'.tr,
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                AppButton(
                  text: confirmText ?? 'confirm'.tr,
                  backgroundColor: isDestructive
                      ? AppColors.expenseRed
                      : AppColors.primaryNavy,
                  width: 100,
                  height: 38,
                  onPressed: () {
                    Get.back();
                    onConfirm();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) {
    return Get.dialog(
      AppConfirmDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
  }
}
