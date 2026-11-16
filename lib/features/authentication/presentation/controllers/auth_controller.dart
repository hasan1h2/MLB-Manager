import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/security/pin_service.dart';
import '../../../../core/services/storage_service.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class AuthController extends GetxController {
  final PinService pinService = Get.find<PinService>();
  final StorageService storageService = Get.find<StorageService>();

  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  final RxString enteredPin = ''.obs;
  final RxString confirmPin = ''.obs;
  final RxBool isSettingPin = false.obs;
  final RxBool isConfirmingPin = false.obs;

  void onNumberPressed(String number) {
    if (isConfirmingPin.value) {
      if (confirmPin.value.length < 6) {
        confirmPin.value += number;
      }
    } else {
      if (enteredPin.value.length < 6) {
        enteredPin.value += number;
      }
    }
  }

  void onDeletePressed() {
    if (isConfirmingPin.value) {
      if (confirmPin.value.isNotEmpty) {
        confirmPin.value = confirmPin.value.substring(0, confirmPin.value.length - 1);
      }
    } else {
      if (enteredPin.value.isNotEmpty) {
        enteredPin.value = enteredPin.value.substring(0, enteredPin.value.length - 1);
      }
    }
  }

  Future<void> submitVerifyPin() async {
    final success = await pinService.verifyPin(enteredPin.value);
    if (success) {
      Get.offAllNamed(AppRoutes.mainNav);
    } else {
      enteredPin.value = '';
      AppSnackbar.error('pin_incorrect'.tr);
    }
  }

  void proceedToConfirmPin() {
    if (enteredPin.value.length < 4) {
      AppSnackbar.error('pin_length_error'.tr);
      return;
    }
    isConfirmingPin.value = true;
  }

  Future<void> submitSetPin() async {
    if (enteredPin.value != confirmPin.value) {
      AppSnackbar.error('pin_mismatch'.tr);
      confirmPin.value = '';
      return;
    }

    final success = await pinService.setPin(enteredPin.value);
    if (success) {
      AppSnackbar.success('${'app_pin'.tr} ${'saved'.tr}');
      Get.offAllNamed(AppRoutes.mainNav);
    } else {
      AppSnackbar.error('error'.tr);
    }
  }

  Future<void> tryBiometricAuth() async {
    final success = await pinService.authenticateWithBiometrics();
    if (success) {
      Get.offAllNamed(AppRoutes.mainNav);
    }
  }

  void finishOnboarding() {
    storageService.setBool(AppConstants.keyIsFirstRun, false);
    if (pinService.hasPin.value) {
      Get.offAllNamed(AppRoutes.pinVerify);
    } else {
      Get.offAllNamed(AppRoutes.mainNav);
    }
  }

  @override
  void onClose() {
    pinController.dispose();
    confirmPinController.dispose();
    super.onClose();
  }
}
