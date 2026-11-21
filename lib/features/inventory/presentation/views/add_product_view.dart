import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('একক (Unit)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p4),
          DropdownButtonFormField<String>(
            value: controller.selectedUnit.value,
            items: const [
              DropdownMenuItem(value: 'piece', child: Text('পিস (Piece)')),
              DropdownMenuItem(value: 'kg', child: Text('কেজি (kg)')),
              DropdownMenuItem(value: 'gm', child: Text('গ্রাম (gm)')),
              DropdownMenuItem(value: 'liter', child: Text('লিটার (Liter)')),
              DropdownMenuItem(
                  value: 'packet', child: Text('প্যাকেট (Packet)')),
              DropdownMenuItem(value: 'box', child: Text('বক্স (Box)')),
              DropdownMenuItem(value: 'bag', child: Text('বস্তা (Bag)')),
              DropdownMenuItem(value: 'dozen', child: Text('ডজন (Dozen)')),
              DropdownMenuItem(value: 'carton', child: Text('কার্টন (Carton)')),
            ],
            onChanged: (val) {
              if (val != null) controller.selectedUnit.value = val;
            },
          ),
        ],
      );
    });
  }
}
