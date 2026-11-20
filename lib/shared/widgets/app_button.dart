import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.width,
    this.height = AppSizes.buttonHeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultBg =
        isDark ? AppColors.secondaryElectric : AppColors.primaryNavy;
    final effectiveBg = backgroundColor ?? defaultBg;
    final effectiveText =
        textColor ?? (isOutlined ? effectiveBg : Colors.white);

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: effectiveBg, width: 1.5),
            padding:
                padding ?? const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.r8),
            ),
          ),
          child: _buildChild(effectiveText),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBg,
          foregroundColor: effectiveText,
          elevation: 0,
          padding:
              padding ?? const EdgeInsets.symmetric(horizontal: AppSizes.p16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r8),
          ),
        ),
        child: _buildChild(effectiveText),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSizes.iconSm, color: color),
          const SizedBox(width: AppSizes.p8),
        ],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
