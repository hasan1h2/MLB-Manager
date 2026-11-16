import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/security/pin_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_image.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final pinService = Get.isRegistered<PinService>() ? Get.find<PinService>() : null;

    if (pinService != null && pinService.hasPin.value && pinService.isLocked.value) {
      Get.offAllNamed(AppRoutes.pinVerify);
    } else {
      Get.offAllNamed(AppRoutes.mainNav);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppImage(
              imagePath: AppConstants.appLogoAsset,
              width: 96,
              height: 96,
              borderRadius: AppSizes.r24,
              fallbackIcon: Icons.account_balance_wallet_rounded,
              fallbackColor: AppColors.secondaryElectric,
              backgroundColor: Colors.white10,
            ),
            const SizedBox(height: AppSizes.p24),
            Text(
              'app_name'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              'app_tagline'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryElectricLight,
              ),
            ),
            const SizedBox(height: AppSizes.p48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
