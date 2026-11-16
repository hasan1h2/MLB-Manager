import 'package:get/get.dart';

class Validators {
  static String? requiredField(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName ${'required'.tr}' : 'required'.tr;
    }
    return null;
  }

  static String? positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'required'.tr;
    }
    final parsed = double.tryParse(value.replaceAll(',', '').trim());
    if (parsed == null || parsed <= 0) {
      return 'must_be_positive'.tr;
    }
    return null;
  }

  static String? validPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.length < 11 || cleaned.length > 14) {
      return 'invalid_phone'.tr;
    }
    return null;
  }

  static String? pinValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'enter_pin'.tr;
    }
    if (value.length < 4 || value.length > 6) {
      return 'pin_length_error'.tr;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'pin_digits_only'.tr;
    }
    return null;
  }
}
