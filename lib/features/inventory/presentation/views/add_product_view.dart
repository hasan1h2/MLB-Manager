import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/unit_conversion_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/inventory_controller.dart';

class AddProductView extends GetView<InventoryController> {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন পণ্য যোগ করুন',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('পণ্যের মৌলিক তথ্য',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.p12),
            AppTextField(
              label: 'পণ্যের নাম (বাংলা)',
              hint: 'যেমন: মিনিকেট চাল, সোয়াবিন তেল ১ লিটার',
              controller: controller.nameController,
              prefixIcon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: AppSizes.p12),
            AppTextField(
              label: 'পণ্যের নাম (English - ঐচ্ছিক)',
              hint: 'e.g. Miniket Rice, Soybean Oil 1L',
              controller: controller.nameEnController,
              prefixIcon: Icons.translate,
            ),
            const SizedBox(height: AppSizes.p12),
            // Category & Subcategory Selector
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: controller.selectedCategoryId.value,
                    decoration: const InputDecoration(
                      labelText: 'ক্যাটাগরি নির্বাচন করুন*',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: controller.businessCategories.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nameBn.isNotEmpty ? c.nameBn : c.nameEn),
                      );
                    }).toList(),
                    onChanged: (val) => controller.onCategoryChanged(val),
                  ),
                  if (controller.subcategories.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.p12),
                    DropdownButtonFormField<String>(
                      value: controller.selectedSubcategoryId.value,
                      decoration: const InputDecoration(
                        labelText: 'সাবক্যাটাগরি (ঐচ্ছিক)',
                        prefixIcon: Icon(Icons.subdirectory_arrow_right),
                      ),
                      items: controller.subcategories.map((sc) {
                        return DropdownMenuItem(
                          value: sc.id,
                          child: Text(sc.nameBn),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          controller.selectedSubcategoryId.value = val,
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: AppSizes.p12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'ব্র্যান্ড / কোম্পানি (ঐচ্ছিক)',
                    hint: 'যেমন: তীর, রূপচাঁদা, স্কয়ার',
                    controller: controller.brandController,
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: _buildUnitDropdown(),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            // Packaging Unit, Content & Conversion
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: controller.packageUnit.value.isEmpty
                              ? null
                              : controller.packageUnit.value,
                          decoration: const InputDecoration(
                            labelText: 'প্যাকেজিং ধরণ / একক (ঐচ্ছিক)',
                          ),
                          items: const [
                            DropdownMenuItem(value: '', child: Text('কোনটিই নয় (শুধুমাত্র বেস একক)')),
                            DropdownMenuItem(value: 'carton', child: Text('কার্টন (Carton)')),
                            DropdownMenuItem(value: 'box', child: Text('বক্স (Box)')),
                            DropdownMenuItem(value: 'sack', child: Text('বস্তা (Sack)')),
                            DropdownMenuItem(value: 'bag', child: Text('ব্যাগ (Bag)')),
                            DropdownMenuItem(value: 'packet', child: Text('প্যাকেট (Packet)')),
                            DropdownMenuItem(value: 'bottle', child: Text('বোতল (Bottle)')),
                            DropdownMenuItem(value: 'custom', child: Text('কাস্টম প্যাকেজ নাম')),
                          ],
                          onChanged: (val) {
                            controller.packageUnit.value = val ?? '';
                            if (val != null && val.isNotEmpty) {
                              controller.hasPackageConversion.value = true;
                            } else {
                              controller.hasPackageConversion.value = false;
                            }
                          },
                        ),
                      ),
                      if (controller.packageUnit.value == 'custom') ...[
                        const SizedBox(width: AppSizes.p12),
                        Expanded(
                          child: AppTextField(
                            label: 'প্যাকেজের নাম লিখুন',
                            hint: 'যেমন: পেটি, ড্রাম',
                            controller: controller.customPackageNameController,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (controller.packageUnit.value.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.p8),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.p12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: controller.hasPackageConversion.value,
                                onChanged: (v) =>
                                    controller.hasPackageConversion.value = v ?? false,
                              ),
                              Expanded(
                                child: Text(
                                  'প্যাকেজের ভেতরের পণ্য খুচরা/আলাদা বিক্রি হবে (কনভার্সন চালু)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (controller.hasPackageConversion.value) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label:
                                        '১ ${controller.packageUnit.value == 'custom' ? (controller.customPackageNameController.text.isNotEmpty ? controller.customPackageNameController.text : 'প্যাকেজ') : UnitConversionUtils.getShortUnitLabel(controller.packageUnit.value)} = কত ${UnitConversionUtils.getShortUnitLabel(controller.selectedUnit.value)}?',
                                    hint: 'যেমন: 50 বা 24',
                                    controller: controller.packageQuantityController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (val) => controller.onPackageQuantityChanged(val),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.p12),
                                Expanded(
                                  child: CurrencyInputField(
                                    label: 'প্যাকেজ ক্রয় মূল্য (৳)',
                                    controller: controller.packageCostController,
                                    onChanged: (val) => controller.onPackageCostChanged(val),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Obx(() {
                              final pCost = double.tryParse(controller.packageCostController.text) ?? 0.0;
                              final pQty = double.tryParse(controller.packageQuantityController.text) ?? 1.0;
                              if (pCost > 0 && pQty > 0) {
                                final perBase = pCost / pQty;
                                return Text(
                                  '💡 হিসাবকৃত একক ক্রয়দর: ${CurrencyUtils.format((perBase * 100).round())} / ${UnitConversionUtils.getShortUnitLabel(controller.selectedUnit.value)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.incomeGreen,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ] else ...[
                            const Text(
                              'প্যাকেজ সরাসরি বিক্রি হবে, কোনো কেজি/গ্রাম/পিস রূপান্তর প্রয়োজন নেই।',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: AppSizes.p12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'বারকোড (Barcode)',
                    hint: 'স্ক্যান বা কোড লিখুন',
                    controller: controller.barcodeController,
                    prefixIcon: Icons.qr_code_scanner,
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: AppTextField(
                    label: 'SKU / কোড (ঐচ্ছিক)',
                    controller: controller.skuController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p24),
            const Text('মূল্য নির্ধারণ (Pricing)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.p12),
            Row(
              children: [
                Expanded(
                  child: CurrencyInputField(
                    label: 'একক ক্রয় মূল্য',
                    controller: controller.purchasePriceController,
                    onChanged: (val) => controller.onBaseCostChanged(val),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: CurrencyInputField(
                    label: 'খুচরা বিক্রয় দর',
                    controller: controller.sellingPriceController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            CurrencyInputField(
              label: 'সাধারণ পাইকারি দর (Wholesale Price)',
              controller: controller.wholesalePriceController,
            ),
            const SizedBox(height: AppSizes.p24),

            // Wholesale Price Tiers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('পরিমাণভিত্তিক পাইকারি দর (Price Tiers)',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('নির্দিষ্ট পরিমাণের বেশি কিনলে বিশেষ ছাড় দর',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('টিয়ার যোগ'),
                  onPressed: () => controller.addTier(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.priceTiers.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(AppSizes.p12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                    border: Border.all(color: borderColor),
                  ),
                  child: const Text(
                    'কোন বিশেষ পাইকারি টিয়ার সেট করা নেই। প্রয়োজন হলে "+ টিয়ার যোগ" চাপুন (যেমন: ১০ পিস কিনলে ৯০ টাকা দর)।',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: controller.priceTiers.map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: AppTextField(
                            label: 'সর্বনিম্ন পরিমাণ (Qty)',
                            hint: 'যেমন: 10',
                            controller: t.minQtyController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: CurrencyInputField(
                            label: 'বিশেষ পাইকারি দর',
                            controller: t.priceController,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: AppColors.expenseRed),
                          onPressed: () => controller.removeTier(t),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: AppSizes.p24),

            const Text('মজুদ ও ট্র্যাকিং (Stock & Tracking)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.p12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'প্রারম্ভিক স্টক (Opening Stock)',
                    controller: controller.openingQtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: AppTextField(
                    label: 'সতর্কতা স্টক সীমা (Min Stock)',
                    controller: controller.minStockController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'ব্যাচ নম্বর (ঐচ্ছিক)',
                    controller: controller.batchNumberController,
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 180)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2040),
                      );
                      if (picked != null) {
                        controller.expiryDate.value = picked;
                      }
                    },
                    child: Obx(() {
                      final exp = controller.expiryDate.value;
                      final text = exp != null
                          ? DateFormat('dd/MM/yyyy').format(exp)
                          : 'মেয়াদোত্তীর্ণ তারিখ (Expiry)';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(AppSizes.r8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(text,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: exp != null ? null : Colors.grey)),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'পণ্য সংরক্ষণ করুন',
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveProduct();
                if (success) {
                  Get.back();
                }
              },
            ),
            const SizedBox(height: AppSizes.p32),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return Obx(() {
      const units = [
        'piece',
        'packet',
        'kg',
        'g',
        'mg',
        'liter',
        'ml',
        'box',
        'carton',
        'dozen',
        'bottle',
        'bag',
        'sack',
        'pair',
        'custom',
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('একক (Unit)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p4),
          DropdownButtonFormField<String>(
            value: units.contains(controller.selectedUnit.value)
                ? controller.selectedUnit.value
                : 'piece',
            items: units.map((u) {
              return DropdownMenuItem(
                value: u,
                child: Text(UnitConversionUtils.getUnitLabel(u)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.selectedUnit.value = val;
            },
          ),
        ],
      );
    });
  }
}
