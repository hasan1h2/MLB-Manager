import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/party_controller.dart';

class AddPartyView extends GetView<PartyController> {
  final bool isCustomer;
  const AddPartyView({super.key, this.isCustomer = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCustomer ? 'add_customer'.tr : 'add_supplier'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'নাম',
              hint: isCustomer
                  ? 'গ্রাহকের পুরো নাম'
                  : 'সাপ্লায়ার ব্যক্তির নাম',
              controller: controller.nameController,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'প্রতিষ্ঠান / দোকানের নাম (ঐচ্ছিক)',
              hint: 'যেমন: মেসার্স রহিম স্টোর',
              controller: controller.companyController,
              prefixIcon: Icons.storefront_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            if (isCustomer) ...[
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: controller.selectedCustomerType.value,
                  decoration: const InputDecoration(
                    labelText: 'গ্রাহকের ধরণ (Customer Type)',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'retail', child: Text('খুচরা গ্রাহক (Retail)')),
                    DropdownMenuItem(
                        value: 'wholesale',
                        child: Text('পাইকারি গ্রাহক (Wholesale)')),
                  ],
                  onChanged: (val) {
                    if (val != null) controller.selectedCustomerType.value = val;
                  },
                );
              }),
              const SizedBox(height: AppSizes.p16),
            ],
            AppTextField(
              label: 'মোবাইল নম্বর',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'ঠিকানা',
              controller: controller.addressController,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            Row(
              children: [
                Expanded(
                  child: CurrencyInputField(
                    label: 'opening_balance'.tr,
                    controller: controller.openingBalanceController,
                  ),
                ),
                if (isCustomer) ...[
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: CurrencyInputField(
                      label: 'সর্বোচ্চ বাকি সীমা (Credit Limit)',
                      controller: controller.creditLimitController,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'notes'.tr,
              controller: controller.notesController,
              maxLines: 2,
            ),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = isCustomer
                    ? await controller.saveCustomer()
                    : await controller.saveSupplier();
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
}
