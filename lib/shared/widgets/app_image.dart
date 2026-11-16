import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';

class AppImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final Color? backgroundColor;

  const AppImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = AppSizes.r8,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = (isDark ? AppColors.secondaryElectric : AppColors.primaryNavy).withValues(alpha: 0.12);
    final bg = backgroundColor ?? defaultBg;
    final fg = fallbackColor ?? (isDark ? AppColors.secondaryElectric : AppColors.primaryNavy);

    Widget fallbackWidget() {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: Icon(
            fallbackIcon,
            color: fg,
            size: (width != null && height != null)
                ? (width! < height! ? width! * 0.5 : height! * 0.5).clamp(16.0, 48.0)
                : 24.0,
          ),
        ),
      );
    }

    if (imagePath == null || imagePath!.trim().isEmpty) {
      return fallbackWidget();
    }

    final path = imagePath!.trim();

    // 1. Asset Image
    if (path.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          path,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => fallbackWidget(),
        ),
      );
    }

    // 2. Network Image
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          path,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => fallbackWidget(),
        ),
      );
    }

    // 3. Local File Image
    try {
      final file = File(path);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => fallbackWidget(),
          ),
        );
      }
    } catch (_) {
      // Return fallback on any filesystem error
    }

    return fallbackWidget();
  }
}
