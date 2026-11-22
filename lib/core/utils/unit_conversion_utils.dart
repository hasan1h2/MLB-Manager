class UnitConversionUtils {
  static const String unitMg = 'mg';
  static const String unitG = 'g';
  static const String unitKg = 'kg';
  static const String unitMl = 'ml';
  static const String unitLiter = 'liter';
  static const String unitPiece = 'piece';
  static const String unitPacket = 'packet';
  static const String unitBox = 'box';
  static const String unitCarton = 'carton';
  static const String unitDozen = 'dozen';
  static const String unitBottle = 'bottle';
  static const String unitBag = 'bag';
  static const String unitSack = 'sack';
  static const String unitPair = 'pair';
  static const String unitCustom = 'custom';

  static const Map<String, String> unitLabelsBn = {
    unitMg: 'মিলিগ্রাম (mg)',
    unitG: 'গ্রাম (g)',
    unitKg: 'কেজি (kg)',
    unitMl: 'মিলিলিটার (ml)',
    unitLiter: 'লিটার (L)',
    unitPiece: 'পিস (pcs)',
    'pcs': 'পিস (pcs)',
    unitPacket: 'প্যাকেট',
    unitBox: 'বক্স',
    unitCarton: 'কার্টন',
    unitDozen: 'ডজন',
    unitBottle: 'বোতল',
    unitBag: 'ব্যাগ',
    unitSack: 'বস্তা',
    unitPair: 'জোড়া',
    unitCustom: 'কাস্টম একক',
  };

  static const Map<String, String> unitLabelsEn = {
    unitMg: 'Milligram (mg)',
    unitG: 'Gram (g)',
    unitKg: 'Kilogram (kg)',
    unitMl: 'Millilitre (ml)',
    unitLiter: 'Litre (L)',
    unitPiece: 'Piece (pcs)',
    'pcs': 'Piece (pcs)',
    unitPacket: 'Packet',
    unitBox: 'Box',
    unitCarton: 'Carton',
    unitDozen: 'Dozen',
    unitBottle: 'Bottle',
    unitBag: 'Bag',
    unitSack: 'Sack',
    unitPair: 'Pair',
    unitCustom: 'Custom Unit',
  };

  static String getUnitLabel(String unit, {bool isBangla = true}) {
    final normalized = unit.trim().toLowerCase();
    if (isBangla) {
      return unitLabelsBn[normalized] ?? unit;
    } else {
      return unitLabelsEn[normalized] ?? unit;
    }
  }

  static String getShortUnitLabel(String unit, {bool isBangla = true}) {
    final normalized = unit.trim().toLowerCase();
    switch (normalized) {
      case unitMg:
        return isBangla ? 'মিলিগ্রাম' : 'mg';
      case unitG:
        return isBangla ? 'গ্রাম' : 'g';
      case unitKg:
        return isBangla ? 'কেজি' : 'kg';
      case unitMl:
        return isBangla ? 'মিলি' : 'ml';
      case unitLiter:
      case 'l':
        return isBangla ? 'লিটার' : 'L';
      case unitPiece:
      case 'pcs':
        return isBangla ? 'পিস' : 'pcs';
      case unitPacket:
        return isBangla ? 'প্যাকেট' : 'pkt';
      case unitBox:
        return isBangla ? 'বক্স' : 'box';
      case unitCarton:
        return isBangla ? 'কার্টন' : 'ctn';
      case unitDozen:
        return isBangla ? 'ডজন' : 'doz';
      case unitBottle:
        return isBangla ? 'বোতল' : 'btl';
      case unitBag:
        return isBangla ? 'ব্যাগ' : 'bag';
      case unitSack:
        return isBangla ? 'বস্তা' : 'sack';
      case unitPair:
        return isBangla ? 'জোড়া' : 'pair';
      case unitCustom:
        return isBangla ? 'কাস্টম' : 'custom';
      default:
        return unit;
    }
  }

  /// Returns available units for selecting in POS or Purchase based on product base unit and package configuration.
  static List<String> getAvailableUnitsForProduct({
    required String baseUnit,
    String? packageUnit,
    List<String>? customUnits,
  }) {
    final normalizedBase = baseUnit.trim().toLowerCase();
    final result = <String>{normalizedBase};

    // Weight conversions
    if (normalizedBase == unitKg || normalizedBase == unitG || normalizedBase == unitMg) {
      result.add(unitKg);
      result.add(unitG);
      result.add(unitMg);
    } else if (normalizedBase == unitLiter || normalizedBase == 'l' || normalizedBase == unitMl) {
      result.add(unitLiter);
      result.add(unitMl);
    } else if (normalizedBase == unitPiece ||
        normalizedBase == 'pcs' ||
        normalizedBase == unitPacket ||
        normalizedBase == unitBottle) {
      result.add(unitDozen);
      result.add(unitPair);
    }

    if (packageUnit != null && packageUnit.trim().isNotEmpty) {
      result.add(packageUnit.trim().toLowerCase());
    }

    if (customUnits != null) {
      for (final u in customUnits) {
        if (u.trim().isNotEmpty) {
          result.add(u.trim().toLowerCase());
        }
      }
    }

    return result.toList();
  }

  /// Calculates the conversion factor from `fromUnit` to `toBaseUnit`.
  /// baseQuantity = enteredQuantity * getConversionFactor(...)
  static double getConversionFactor({
    required String fromUnit,
    required String toBaseUnit,
    String? packageUnit,
    double? packageQuantity,
    Map<String, double>? customFactors,
  }) {
    final from = fromUnit.trim().toLowerCase();
    final base = toBaseUnit.trim().toLowerCase();

    if (from == base) {
      return 1.0;
    }

    if (customFactors != null && customFactors.containsKey(from)) {
      final factor = customFactors[from]!;
      if (factor > 0) return factor;
    }

    // Product packaging conversion (e.g. 1 carton = 24 packets)
    if (packageUnit != null &&
        packageUnit.trim().toLowerCase() == from &&
        packageQuantity != null &&
        packageQuantity > 0) {
      return packageQuantity;
    }

    // Reverse package conversion: if base unit is carton and user entered base unit piece/packet
    if (packageUnit != null &&
        packageUnit.trim().toLowerCase() == base &&
        packageQuantity != null &&
        packageQuantity > 0) {
      return 1.0 / packageQuantity;
    }

    // Weight conversions
    if (from == unitG && base == unitKg) {
      return 0.001;
    }
    if (from == unitKg && base == unitG) {
      return 1000.0;
    }
    if (from == unitMg && base == unitG) {
      return 0.001;
    }
    if (from == unitG && base == unitMg) {
      return 1000.0;
    }
    if (from == unitMg && base == unitKg) {
      return 0.000001;
    }
    if (from == unitKg && base == unitMg) {
      return 1000000.0;
    }

    // Volume conversions
    if (from == unitMl && (base == unitLiter || base == 'l')) {
      return 0.001;
    }
    if ((from == unitLiter || from == 'l') && base == unitMl) {
      return 1000.0;
    }

    // Count conversions
    if (from == unitDozen &&
        (base == unitPiece || base == 'pcs' || base == unitPacket || base == unitBottle)) {
      return 12.0;
    }
    if (from == unitPair &&
        (base == unitPiece || base == 'pcs' || base == unitPacket)) {
      return 2.0;
    }
    if ((from == unitPiece || from == 'pcs' || from == unitPacket || from == unitBottle) &&
        base == unitDozen) {
      return 1.0 / 12.0;
    }
    if ((from == unitPiece || from == 'pcs' || from == unitPacket) &&
        base == unitPair) {
      return 0.5;
    }

    return 1.0;
  }

  /// Calculates the base unit quantity from entered quantity and unit.
  static double calculateBaseQuantity({
    required double quantity,
    required String unit,
    required String baseUnit,
    String? packageUnit,
    double? packageQuantity,
    Map<String, double>? customFactors,
  }) {
    final factor = getConversionFactor(
      fromUnit: unit,
      toBaseUnit: baseUnit,
      packageUnit: packageUnit,
      packageQuantity: packageQuantity,
      customFactors: customFactors,
    );
    return quantity * factor;
  }

  /// Calculates line total in minor units (Poisha) for sale.
  static int calculateSaleLineTotal({
    required double quantity,
    required String unit,
    required int baseUnitPriceMinor,
    required String baseUnit,
    String? packageUnit,
    double? packageQuantity,
    int? packagePriceMinor,
  }) {
    final from = unit.trim().toLowerCase();
    final pack = packageUnit?.trim().toLowerCase();

    // If direct package price is specified for this package unit
    if (pack != null && from == pack && packagePriceMinor != null && packagePriceMinor > 0) {
      return (quantity * packagePriceMinor).round();
    }

    // Otherwise calculate based on base quantity * base unit price
    final baseQty = calculateBaseQuantity(
      quantity: quantity,
      unit: unit,
      baseUnit: baseUnit,
      packageUnit: packageUnit,
      packageQuantity: packageQuantity,
    );
    return (baseQty * baseUnitPriceMinor).round();
  }

  /// Formats quantity with unit, e.g. "0.5 কেজি" or "2 কার্টন (৪৮ প্যাকেট)"
  static String formatQuantityWithUnit(
    double quantity,
    String unit, {
    String? baseUnit,
    double? packageQuantity,
    bool isBangla = true,
  }) {
    final formattedQty = (quantity % 1 == 0)
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(quantity.toString().split('.').last.length > 3 ? 3 : 2);
    final unitLabel = getShortUnitLabel(unit, isBangla: isBangla);

    if (baseUnit != null &&
        packageQuantity != null &&
        packageQuantity > 1 &&
        unit.trim().toLowerCase() != baseUnit.trim().toLowerCase()) {
      final totalBaseQty = quantity * packageQuantity;
      final formattedBaseQty = (totalBaseQty % 1 == 0)
          ? totalBaseQty.toInt().toString()
          : totalBaseQty.toStringAsFixed(2);
      final baseUnitLabel = getShortUnitLabel(baseUnit, isBangla: isBangla);
      return '$formattedQty $unitLabel ($formattedBaseQty $baseUnitLabel)';
    }

    return '$formattedQty $unitLabel';
  }
}
