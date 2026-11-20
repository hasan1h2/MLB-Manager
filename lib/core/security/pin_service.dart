import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../constants/app_constants.dart';

class PinService extends GetxService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  final RxBool hasPin = false.obs;
  final RxBool isLocked = false.obs;
  final RxBool isBiometricAvailable = false.obs;
  final RxBool isBiometricEnabled = false.obs;

  static const String _pinSalt = 'MLB_MANAGER_SALT_2026_SECURE';

  @override
  void onInit() {
    super.onInit();
    checkSecurityState();
  }

  Future<void> checkSecurityState() async {
    try {
      final pinHash = await _secureStorage.read(key: AppConstants.keyAppPin);
      hasPin.value = pinHash != null && pinHash.isNotEmpty;

      final biometricSaved =
          await _secureStorage.read(key: AppConstants.keyBiometricEnabled);
      isBiometricEnabled.value = biometricSaved == 'true';
    } catch (_) {
      hasPin.value = false;
      isBiometricEnabled.value = false;
    }

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      isBiometricAvailable.value = canCheck && isDeviceSupported;
    } catch (_) {
      isBiometricAvailable.value = false;
    }

    if (hasPin.value) {
      isLocked.value = true;
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin + _pinSalt);
    return sha256.convert(bytes).toString();
  }

  Future<bool> setPin(String pin) async {
    try {
      final hash = _hashPin(pin);
      await _secureStorage.write(key: AppConstants.keyAppPin, value: hash);
      hasPin.value = true;
      isLocked.value = false;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    final savedHash = await _secureStorage.read(key: AppConstants.keyAppPin);
    if (savedHash == null) return true;
    final enteredHash = _hashPin(pin);
    if (savedHash == enteredHash) {
      isLocked.value = false;
      return true;
    }
    return false;
  }

  Future<void> removePin() async {
    await _secureStorage.delete(key: AppConstants.keyAppPin);
    hasPin.value = false;
    isLocked.value = false;
    await setBiometricEnabled(false);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    isBiometricEnabled.value = enabled;
    await _secureStorage.write(
      key: AppConstants.keyBiometricEnabled,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!isBiometricAvailable.value || !isBiometricEnabled.value) return false;
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access MLB Manager',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        isLocked.value = false;
      }
      return authenticated;
    } catch (_) {
      return false;
    }
  }

  void lockApp() {
    if (hasPin.value) {
      isLocked.value = true;
    }
  }

  void unlockApp() {
    isLocked.value = false;
  }
}
