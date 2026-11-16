import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/auth_controller.dart';

class OnboardingView extends GetView<AuthController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            children: [
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.r24),
                child: Image.asset(
                  AppConstants.appLogoAsset,
                  width: 104,
                  height: 104,
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(AppSizes.p32),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryElectric.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 80,
                      color: AppColors.secondaryElectric,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p32),
              Text(
                'app_name'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.p12),
              Text(
                'app_tagline'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondaryLight,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'finish'.tr,
                onPressed: () => controller.finishOnboarding(),
              ),
              const SizedBox(height: AppSizes.p16),
            ],
          ),
        ),
      ),
    );
  }
}
