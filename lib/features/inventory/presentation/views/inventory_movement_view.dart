import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/inventory_controller.dart';

class InventoryMovementView extends GetView<InventoryController> {
  const InventoryMovementView({super.key});

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as ProductWithStock?;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('স্টক সমন্বয়')),
        body: const Center(child: Text('পণ্য পাওয়া যায়নি')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${item.product.name} - স্টক সমন্বয়'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('বর্তমান মজুদ স্টক', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '${item.currentStock} ${item.product.unit}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.secondaryElectric),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            _buildMovementTypeDropdown(),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'পরিমাণ (${item.product.unit})',
              controller: controller.movementQtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'বিবরণ / কারণ',
              hint: 'যেমন: নতুন সরবরাহ, ক্ষতিগ্রস্থ পণ্য বাতিল, গণনা সংশোধন',
              controller: controller.movementNotesController,
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'স্টক আপডেট করুন',
              icon: AppIcons.check,
              onPressed: () async {
                await controller.recordMovement(item.product.id);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementTypeDropdown() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('সমন্বয়ের ধরণ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p4),
          DropdownButtonFormField<String>(
            value: controller.selectedMovementType.value,
            items: const [
              DropdownMenuItem(value: 'in', child: Text('স্টক বৃদ্ধি (Stock In)')),
              DropdownMenuItem(value: 'out', child: Text('স্টক হ্রাস (Stock Out)')),
              DropdownMenuItem(value: 'adjustment', child: Text('স্টক সংশোধন (Adjustment)')),
              DropdownMenuItem(value: 'damage', child: Text('ক্ষতিগ্রস্থ / নষ্ট (Damage)')),
              DropdownMenuItem(value: 'wastage', child: Text('অপচয় (Wastage)')),
            ],
            onChanged: (val) {
              if (val != null) controller.selectedMovementType.value = val;
            },
          ),
        ],
      );
    });
  }
}
