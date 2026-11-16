import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_utils.dart';

class CurrencyInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<int>? onMinorChanged;
  final String? Function(String?)? validator;

  const CurrencyInputField({
    super.key,
    required this.label,
    required this.controller,
    this.onMinorChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.p4),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (val) {
            final minor = CurrencyUtils.takaToMinor(val);
            onMinorChanged?.call(minor);
          },
          decoration: const InputDecoration(
            prefixText: '${AppConstants.defaultCurrencySymbol}  ',
            prefixStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.secondaryElectric,
            ),
            hintText: '0.00',
          ),
        ),
      ],
    );
  }
}
