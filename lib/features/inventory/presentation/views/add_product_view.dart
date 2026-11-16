import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('add_product'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'পণ্যের নাম',
              hint: 'যেমন: মিনিকেট চাল, সোয়াবিন তেল ১ লিটার',
              controller: controller.nameController,
              prefixIcon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'SKU / কোড (ঐচ্ছিক)',
                    controller: controller.skuController,
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: _buildUnitDropdown(),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),
            Row(
              children: [
                Expanded(
                  child: CurrencyInputField(
                    label: 'purchase_price_minor'.tr,
                    controller: controller.purchasePriceController,
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: CurrencyInputField(
                    label: 'selling_price_minor'.tr,
                    controller: controller.sellingPriceController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'প্রারম্ভিক স্টক',
                    controller: controller.openingQtyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: AppTextField(
                    label: 'minimum_stock'.tr,
                    controller: controller.minStockController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveProduct();
                if (success) {
                  Get.back();
                }
              },
            ),
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
          Text('unit'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p4),
          DropdownButtonFormField<String>(
            value: controller.selectedUnit.value,
            items: const [
              DropdownMenuItem(value: 'piece', child: Text('পিস (Piece)')),
              DropdownMenuItem(value: 'kg', child: Text('কেজি (kg)')),
              DropdownMenuItem(value: 'liter', child: Text('লিটার (Liter)')),
              DropdownMenuItem(value: 'packet', child: Text('প্যাকেট (Packet)')),
              DropdownMenuItem(value: 'box', child: Text('বক্স (Box)')),
              DropdownMenuItem(value: 'bag', child: Text('বস্তা (Bag)')),
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
