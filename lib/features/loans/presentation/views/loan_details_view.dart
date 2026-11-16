import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/loan_controller.dart';

class LoanDetailsView extends GetView<LoanController> {
  const LoanDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as LoanWithRemaining?;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ঋণের বিস্তারিত')),
        body: const Center(child: Text('ঋণ পাওয়া যায়নি')),
      );
    }

    final isReceivable = item.loan.loanType == 'receivable';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(item.loan.partyName),
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
                  Text(
                    item.loan.partyName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Text(
                    isReceivable ? 'প্রদত্ত ঋণ (পাওনা)' : 'গৃহীত ঋণ (দেনা)',
                    style: const TextStyle(color: AppColors.secondaryElectricLight, fontSize: 13),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Text(
                    CurrencyUtils.format(item.remainingPrincipalMinor),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p4),
                  const Text('অবশিষ্ট বকেয়া আসল', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('মূল আসল টাকা', style: TextStyle(color: AppColors.textSecondaryLight)),
                        Text(CurrencyUtils.format(item.loan.principalMinor), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('পরিশোধের শেষ তারিখ', style: TextStyle(color: AppColors.textSecondaryLight)),
                        Text(AppDateUtils.formatTimestamp(item.loan.dueDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p20),
            if (item.remainingPrincipalMinor > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('কিস্তি / পরিশোধ এন্ট্রি', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSizes.p12),
                      CurrencyInputField(
                        label: 'পরিশোধিত টাকার পরিমাণ',
                        controller: controller.paymentAmountController,
                      ),
                      const SizedBox(height: AppSizes.p16),
                      AppButton(
                        text: 'পরিশোধ জমা দিন',
                        icon: AppIcons.check,
                        onPressed: () async {
                          await controller.recordPayment(item.loan.id);
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p20),
            ],
            Text('পরিশোধের ইতিহাস', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.p8),
            Obx(() {
              final payments = controller.selectedLoanPayments;
              if (payments.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.p16),
                    child: Center(child: Text('এখনও কোন কিস্তি পরিশোধ করা হয়নি', style: TextStyle(color: AppColors.textSecondaryLight))),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final p = payments[index];
                  return Card(
                    child: ListTile(
                      title: Text(AppDateUtils.formatTimestamp(p.paymentDate)),
                      trailing: Text(
                        CurrencyUtils.format(p.principalPaidMinor),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.incomeGreen),
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: AppSizes.p32),
          ],
        ),
      ),
    );
  }
}
