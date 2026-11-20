import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/family_controller.dart';

class AddFamilyMemberView extends GetView<FamilyController> {
  const AddFamilyMemberView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_family_member'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'নাম',
              hint: 'সদস্যের পুরো নাম লিখুন',
              controller: controller.nameController,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'মোবাইল নম্বর (ঐচ্ছিক)',
              hint: '০১৭xxxxxxxx',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: 'সম্পর্ক (ঐচ্ছিক)',
              hint: 'যেমন: পিতা, মাতা, সন্তান, ভাই, বোন',
              controller: controller.relationshipController,
              prefixIcon: Icons.people_outline_rounded,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildRoleSelector(),
            const SizedBox(height: AppSizes.p32),
            AppButton(
              text: 'save'.tr,
              icon: AppIcons.check,
              onPressed: () async {
                final success = await controller.saveMember();
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

  Widget _buildRoleSelector() {
    return Obx(() {
      final current = controller.selectedRole.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('role'.tr,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.p8),
          DropdownButtonFormField<String>(
            value: current,
            items: [
              DropdownMenuItem(value: 'owner', child: Text('role_owner'.tr)),
              DropdownMenuItem(value: 'admin', child: Text('role_admin'.tr)),
              DropdownMenuItem(value: 'member', child: Text('role_member'.tr)),
              DropdownMenuItem(value: 'viewer', child: Text('role_viewer'.tr)),
            ],
            onChanged: (val) {
              if (val != null) controller.selectedRole.value = val;
            },
          ),
        ],
      );
    });
  }
}
