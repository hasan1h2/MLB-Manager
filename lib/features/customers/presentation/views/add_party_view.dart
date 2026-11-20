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
                  : 'সাপ্লায়ার বা প্রতিষ্ঠানের নাম',
              controller: controller.nameController,
              prefixIcon: Icons.person_outline_rounded,
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
              label: 'ঠিকানা',
              controller: controller.addressController,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            CurrencyInputField(
              label: 'opening_balance'.tr,
              controller: controller.openingBalanceController,
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
