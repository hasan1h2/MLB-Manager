import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  const AppLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryElectric),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSizes.p12),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppSnackbar {
  static void success(String message, {String? title}) {
    Get.snackbar(
      title ?? 'success'.tr,
      message,
      backgroundColor: AppColors.incomeGreen,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppSizes.p16),
      borderRadius: AppSizes.r8,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    );
  }

  static void error(String message, {String? title}) {
    Get.snackbar(
      title ?? 'error'.tr,
      message,
      backgroundColor: AppColors.expenseRed,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppSizes.p16),
      borderRadius: AppSizes.r8,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }

  static void info(String message, {String? title}) {
    Get.snackbar(
      title ?? 'info'.tr,
      message,
      backgroundColor: AppColors.primaryNavy,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppSizes.p16),
      borderRadius: AppSizes.r8,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
    );
  }
}
