import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/household_controller.dart';

class AddShoppingEntryView extends GetView<HouseholdController> {
  const AddShoppingEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('add_shopping_entry'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'store_name'.tr,
              hint: 'যেমন: কারওয়ান বাজার, স্থানীয় মুদি দোকান',
              controller: controller.storeNameController,
              prefixIcon: Icons.storefront_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildDatePicker(context),
            const SizedBox(height: AppSizes.p20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('items'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton.icon(
                  icon: const Icon(AppIcons.add, size: 16),
                  label: Text('add_item'.tr),
                  onPressed: () => controller.addItemDraft(),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p8),
            _buildItemsList(),
            const SizedBox(height: AppSizes.p16),
            const Divider(),
            const SizedBox(height: AppSizes.p8),
            _buildBillSummary(),
            const SizedBox(height: AppSizes.p24),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveShoppingBill();
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

  Widget _buildDatePicker(BuildContext context) {
    return Obx(() {
      return ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r8),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        tileColor: Colors.white,
        leading: const Icon(AppIcons.calendar, color: AppColors.secondaryElectric),
        title: Text('date'.tr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
        subtitle: Text(
          AppDateUtils.standardDateFormat.format(controller.shoppingDate.value),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: controller.shoppingDate.value,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.shoppingDate.value = picked;
          }
        },
      );
    });
  }

  Widget _buildItemsList() {
    return Obx(() {
      return Column(
        children: List.generate(controller.draftItems.length, (index) {
          final item = controller.draftItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p8),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: item.nameController,
                          decoration: InputDecoration(
                            labelText: 'product_name'.tr,
                            hintText: 'চাল, ডাল, তেল...',
                            isDense: true,
                          ),
                        ),
                      ),
                      if (controller.draftItems.length > 1)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.expenseRed, size: 20),
                          onPressed: () => controller.removeItemDraft(index),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: item.qtyController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'quantity'.tr,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: item.unit,
                          decoration: const InputDecoration(isDense: true, labelText: 'একক'),
                          items: const [
                            DropdownMenuItem(value: 'kg', child: Text('কেজি')),
                            DropdownMenuItem(value: 'liter', child: Text('লিটার')),
                            DropdownMenuItem(value: 'piece', child: Text('পিস')),
                            DropdownMenuItem(value: 'packet', child: Text('প্যাকেট')),
                            DropdownMenuItem(value: 'g', child: Text('গ্রাম')),
                          ],
                          onChanged: (val) {
                            if (val != null) item.unit = val;
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: item.unitPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'unit_price'.tr,
                            hintText: '0.00',
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildBillSummary() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            CurrencyInputField(
              label: 'discount'.tr,
              controller: controller.discountController,
            ),
            const SizedBox(height: AppSizes.p12),
            CurrencyInputField(
              label: 'paid_amount'.tr,
              controller: controller.paidController,
            ),
          ],
        ),
      ),
    );
  }
}
