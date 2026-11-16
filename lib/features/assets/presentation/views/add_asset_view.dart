import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/asset_controller.dart';

class AddAssetView extends GetView<AssetController> {
  const AddAssetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_asset'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'সম্পদের নাম',
              hint: 'যেমন: ধানমন্ডি ফ্ল্যাট, ৫ কাঠা জমি, স্বর্ণের গহনা',
              controller: controller.assetNameController,
              prefixIcon: Icons.apartment_rounded,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildCategoryDropdown(),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'ক্রয় মূল্য',
              controller: controller.assetPurchaseValueController,
            ),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'বর্তমান আনুমানিক বাজার মূল্য',
              controller: controller.assetCurrentValueController,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'notes'.tr,
              controller: controller.assetNotesController,
              maxLines: 2,
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveAsset();
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

  Widget _buildCategoryDropdown() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('সম্পদের ধরণ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p4),
          DropdownButtonFormField<String>(
            value: controller.selectedAssetCategory.value,
            items: const [
              DropdownMenuItem(value: 'land', child: Text('জমি / প্লট (Land)')),
              DropdownMenuItem(value: 'house', child: Text('বাড়ি / ফ্ল্যাট (Building/Flat)')),
              DropdownMenuItem(value: 'gold', child: Text('স্বর্ণ / অলংকার (Gold)')),
              DropdownMenuItem(value: 'vehicle', child: Text('গাড়ি / যানবাহন (Vehicle)')),
              DropdownMenuItem(value: 'cattle', child: Text('গবাদি পশু সম্পদ (Cattle)')),
              DropdownMenuItem(value: 'machinery', child: Text('যন্ত্রপাতি / কলকব্জা (Machinery)')),
              DropdownMenuItem(value: 'other', child: Text('অন্যান্য সম্পদ (Other)')),
            ],
            onChanged: (val) {
              if (val != null) controller.selectedAssetCategory.value = val;
            },
          ),
        ],
      );
    });
  }
}
