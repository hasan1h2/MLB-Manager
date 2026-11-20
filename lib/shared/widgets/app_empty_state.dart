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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.dividerLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark
                    ? AppColors.secondaryElectric
                    : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              message ?? 'no_data_found'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSizes.p20),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                width: 200,
                height: 42,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
