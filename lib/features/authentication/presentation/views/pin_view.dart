import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class PinView extends GetView<AuthController> {
  final bool isSettingNewPin;
  const PinView({super.key, this.isSettingNewPin = false});

  @override
  Widget build(BuildContext context) {
    if (isSettingNewPin) {
      controller.isSettingPin.value = true;
    } else {
      // Auto trigger biometrics if enabled
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.tryBiometricAuth();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isSettingNewPin ? 'set_pin'.tr : 'security'.tr),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Icon(
              isSettingNewPin ? Icons.lock_reset_rounded : Icons.lock_outline_rounded,
              size: 56,
              color: AppColors.primaryNavy,
            ),
            const SizedBox(height: AppSizes.p16),
            Obx(() {
              if (isSettingNewPin) {
                return Text(
                  controller.isConfirmingPin.value ? 'confirm_pin'.tr : 'set_pin'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                );
              }
              return Text(
                'enter_pin'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              );
            }),
            const SizedBox(height: AppSizes.p24),
            // Pin indicators
            Obx(() {
              final activePin = isSettingNewPin && controller.isConfirmingPin.value
                  ? controller.confirmPin.value
                  : controller.enteredPin.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < activePin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? AppColors.secondaryElectric : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? AppColors.secondaryElectric : AppColors.borderDark,
                        width: 2,
                      ),
                    ),
                  );
                }),
              );
            }),
            const Spacer(),
            // Numeric Keypad
            _buildKeypad(),
            const SizedBox(height: AppSizes.p24),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['bio', '0', 'del'],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key == 'bio') {
                  return Obx(() {
                    if (!isSettingNewPin &&
                        controller.pinService.isBiometricAvailable.value &&
                        controller.pinService.isBiometricEnabled.value) {
                      return IconButton(
                        iconSize: 32,
                        icon: const Icon(Icons.fingerprint_rounded, color: AppColors.secondaryElectric),
                        onPressed: () => controller.tryBiometricAuth(),
                      );
                    }
                    return const SizedBox(width: 72, height: 72);
                  });
                }
                if (key == 'del') {
                  return SizedBox(
                    width: 72,
                    height: 72,
                    child: IconButton(
                      icon: const Icon(Icons.backspace_outlined, color: AppColors.textPrimaryLight),
                      onPressed: () => controller.onDeletePressed(),
                    ),
                  );
                }
                return InkWell(
                  onTap: () {
                    controller.onNumberPressed(key);
                    final activePin = isSettingNewPin && controller.isConfirmingPin.value
                        ? controller.confirmPin.value
                        : controller.enteredPin.value;
                    if (activePin.length >= 4) {
                      if (isSettingNewPin) {
                        if (controller.isConfirmingPin.value) {
                          controller.submitSetPin();
                        } else {
                          controller.proceedToConfirmPin();
                        }
                      } else {
                        controller.submitVerifyPin();
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(36),
                  child: Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
