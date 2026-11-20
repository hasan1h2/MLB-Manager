import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/business_controller.dart';

class AddBusinessView extends GetView<BusinessController> {
  const AddBusinessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_business'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'ব্যবসার নাম',
              hint: 'যেমন: মেসার্স রহিম স্টোর, ডেইরি অ্যান্ড ক্যাটল ফার্ম',
              controller: controller.nameController,
              prefixIcon: Icons.storefront_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildTypeDropdown(),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'initial_capital'.tr,
              controller: controller.initialCapitalController,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'লোকেশন / ঠিকানা',
              controller: controller.locationController,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'মোবাইল নম্বর',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'description'.tr,
              controller: controller.descriptionController,
              maxLines: 2,
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveBusiness();
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

  Widget _buildTypeDropdown() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('business_type'.tr,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p4),
          DropdownButtonFormField<String>(
            value: controller.selectedType.value,
            items: const [
              DropdownMenuItem(
                  value: 'cattle', child: Text('গরুর খামার (Cattle Farm)')),
              DropdownMenuItem(
                  value: 'grocery', child: Text('মুদি দোকান (Grocery)')),
              DropdownMenuItem(
                  value: 'wholesale',
                  child: Text('পাইকারি ব্যবসা (Wholesale)')),
              DropdownMenuItem(
                  value: 'retail', child: Text('খুচরা দোকান (Retail)')),
              DropdownMenuItem(
                  value: 'raw_materials',
                  child: Text('কাঁচামাল সরবরাহ (Raw Materials)')),
              DropdownMenuItem(
                  value: 'agriculture',
                  child: Text('কৃষি ব্যবসা (Agriculture)')),
              DropdownMenuItem(
                  value: 'manufacturing',
                  child: Text('উৎপাদনমুখী শিল্প (Manufacturing)')),
              DropdownMenuItem(
                  value: 'service', child: Text('সেবা ও সার্ভিস (Service)')),
              DropdownMenuItem(
                  value: 'custom', child: Text('অন্যান্য ব্যবসা (Custom)')),
            ],
            onChanged: (val) {
              if (val != null) controller.selectedType.value = val;
            },
          ),
        ],
      );
    });
  }
}
