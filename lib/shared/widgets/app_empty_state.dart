import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final String? message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    this.message,
    this.icon = Icons.inbox_rounded,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p20),
              decoration: const BoxDecoration(
                color: AppColors.dividerLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.textMutedLight),
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              message ?? 'no_data_found'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSizes.p16),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                width: 160,
                height: 40,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
