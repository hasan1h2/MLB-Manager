import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/party_controller.dart';

class PartyLedgerView extends GetView<PartyController> {
  final bool isCustomer;
  const PartyLedgerView({super.key, this.isCustomer = true});

  @override
  Widget build(BuildContext context) {
    final customerItem =
        isCustomer ? (Get.arguments as CustomerWithDue?) : null;
    final supplierItem =
        !isCustomer ? (Get.arguments as SupplierWithPayable?) : null;

    final name = isCustomer
        ? (customerItem?.customer.name ?? '')
        : (supplierItem?.supplier.name ?? '');
    final balanceMinor = isCustomer
        ? (customerItem?.dueMinor ?? 0)
        : (supplierItem?.payableMinor ?? 0);
    final partyId = isCustomer
        ? (customerItem?.customer.id ?? '')
        : (supplierItem?.supplier.id ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(isCustomer ? 'কাস্টমার লেজার' : 'সাপ্লায়ার লেজার'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.p20),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(AppSizes.r12),
              ),
              child: Column(
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSizes.p12),
                  Text(
                    isCustomer ? 'মোট বাকি পাওনা' : 'মোট প্রদেয় দেনা',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: AppSizes.p4),
                  Text(
                    CurrencyUtils.format(balanceMinor),
                    style: TextStyle(
                      color: balanceMinor > 0
                          ? (isCustomer ? Colors.white : AppColors.warningAmber)
                          : AppColors.incomeGreen,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCustomer
                          ? 'টাকা আদায় / জমা গ্রহণ'
                          : 'টাকা পরিশোধ এন্ট্রি',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    CurrencyInputField(
                      label: 'পরিশোধিত টাকার পরিমাণ',
                      controller: controller.paymentAmountController,
                    ),
                    const SizedBox(height: AppSizes.p16),
                    AppButton(
                      text: 'পেমেন্ট সংরক্ষণ করুন',
                      icon: AppIcons.check,
                      onPressed: () async {
                        await controller.recordPayment(
                          partyType: isCustomer ? 'customer' : 'supplier',
                          partyId: partyId,
                        );
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
