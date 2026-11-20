import '../constants/app_constants.dart';

class CurrencyUtils {
  /// Converts Taka string (e.g. "150.50" or "150") to exact integer Poisha (e.g. 15050)
  static int takaToMinor(String takaText) {
    if (takaText.trim().isEmpty) return 0;
    final cleaned = takaText.replaceAll(',', '').trim();
    final parts = cleaned.split('.');
    final int major = int.tryParse(parts[0]) ?? 0;
    int minor = 0;
    if (parts.length > 1) {
      String minorStr = parts[1];
      if (minorStr.length == 1) {
        minorStr += '0';
      } else if (minorStr.length > 2) {
        minorStr = minorStr.substring(0, 2);
      }
      minor = int.tryParse(minorStr) ?? 0;
    }
    return (major * AppConstants.minorUnitMultiplier) + minor;
  }

  /// Converts Poisha (minor units) to decimal string e.g. 15050 -> "150.50"
  static String minorToTakaString(int minorUnits,
      {bool includeSymbol = true, bool useBengaliDigits = false}) {
    final bool isNegative = minorUnits < 0;
    final int absMinor = minorUnits.abs();
    final int major = absMinor ~/ AppConstants.minorUnitMultiplier;
    final int minor = absMinor % AppConstants.minorUnitMultiplier;
    final String minorFormatted = minor.toString().padLeft(2, '0');

    String formatted = '$major.$minorFormatted';
    if (isNegative) {
      formatted = '-$formatted';
    }

    if (useBengaliDigits) {
      formatted = toBengaliNumerals(formatted);
    }

    if (includeSymbol) {
      return '${AppConstants.defaultCurrencySymbol} $formatted';
    }
    return formatted;
  }

  /// Formats integer minor units directly into formatted display text
  static String format(int minorUnits,
      {bool includeSymbol = true, bool useBengaliDigits = false}) {
    return minorToTakaString(minorUnits,
        includeSymbol: includeSymbol, useBengaliDigits: useBengaliDigits);
  }

  /// Converts English digits to Bengali digits
  static String toBengaliNumerals(String input) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = input;
    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], bengaliDigits[i]);
    }
    return result;
  }
}
