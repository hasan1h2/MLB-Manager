import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/cashbook_controller.dart';

class CashbookView extends GetView<CashbookController> {
  const CashbookView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('দৈনিক ক্যাশ খাতা (Cashbook)',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        final session = controller.activeSession.value;
        final isOpen = session != null && session.status == 'open';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isOpen)
                _buildOpenSessionCard(cardBg, borderColor, isDark)
              else
                _buildActiveSessionSection(context, cardBg, borderColor, isDark),
              const SizedBox(height: AppSizes.p24),
              _buildHistorySection(cardBg, borderColor, isDark),
              const SizedBox(height: AppSizes.p32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOpenSessionCard(Color cardBg, Color borderColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_open_rounded,
                  color: AppColors.incomeGreen, size: 24),
              const SizedBox(width: 8),
              const Text(
                'আজকের ক্যাশ হিসাব শুরু করুন',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'সকালে দোকান খোলার সময় ক্যাশ বাক্সে কত টাকা ছিল তা দিয়ে হিসাব শুরু করুন।',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          CurrencyInputField(
            label: 'প্রারম্ভিক ক্যাশ ব্যালেন্স (Opening Cash)',
            controller: controller.openingCashController,
          ),
          const SizedBox(height: AppSizes.p12),
          AppTextField(
            label: 'মন্তব্য (ঐচ্ছিক)',
            controller: controller.openingNotesController,
          ),
          const SizedBox(height: AppSizes.p16),
          AppButton(
            text: 'ক্যাশ সেশন শুরু করুন',
            icon: AppIcons.check,
            onPressed: () => controller.startSession(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionSection(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cash flow summary card
        Container(
          padding: const EdgeInsets.all(AppSizes.p16),
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'আজকের ক্যাশ প্রবাহ হিসাব',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSizes.p12),
              _buildFlowRow(
                'প্রারম্ভিক ক্যাশ (Opening):',
                CurrencyUtils.format(
                    controller.activeSession.value?.openingCashMinor ?? 0),
                Colors.white70,
              ),
              _buildFlowRow(
                '(+) নগদ বিক্রয় (Cash Sales):',
                CurrencyUtils.format(controller.todayCashSalesMinor.value),
                AppColors.incomeGreen,
              ),
              _buildFlowRow(
                '(+) বাকি আদায় (Customer Collections):',
                CurrencyUtils.format(
                    controller.todayCustomerCollectionsMinor.value),
                AppColors.incomeGreen,
              ),
              _buildFlowRow(
                '(-) নগদ ক্রয় (Cash Purchases):',
                CurrencyUtils.format(controller.todayCashPurchasesMinor.value),
                AppColors.warningAmber,
              ),
              _buildFlowRow(
                '(-) পরিচালন ব্যয় (Expenses):',
                CurrencyUtils.format(controller.todayCashExpensesMinor.value),
                AppColors.expenseRed,
              ),
              _buildFlowRow(
                '(-) মহাজনকে পরিশোধ (Supplier Payments):',
                CurrencyUtils.format(
                    controller.todaySupplierPaymentsMinor.value),
                AppColors.warningAmber,
              ),
              const Divider(color: Colors.white24, height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'প্রত্যাশিত ক্যাশ (Expected Closing):',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    CurrencyUtils.format(
                        controller.expectedClosingCashMinor),
                    style: const TextStyle(
                        color: AppColors.secondaryElectricLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.p20),

        // Cash counting / Denomination card
        Container(
          padding: const EdgeInsets.all(AppSizes.p16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppSizes.r12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'নোট গণনা (Denomination Counter)',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  Obx(() => TextButton(
                        onPressed: () {
                          controller.useManualClosing.toggle();
                        },
                        child: Text(controller.useManualClosing.value
                            ? 'নোট গণনা করুন'
                            : 'সরাসরি টাকা লিখুন'),
                      )),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.useManualClosing.value) {
                  return CurrencyInputField(
                    label: 'মোট গণনাকৃত ক্যাশ টাকা (Actual Count)',
                    controller: controller.manualClosingController,
                  );
                }
                return Column(
                  children: [
                    _buildNoteInputRow('১০০০ টাকার নোট', controller.count1000, 1000),
                    _buildNoteInputRow('৫০০ টাকার নোট', controller.count500, 500),
                    _buildNoteInputRow('২০০ টাকার নোট', controller.count200, 200),
                    _buildNoteInputRow('১০০ টাকার নোট', controller.count100, 100),
                    _buildNoteInputRow('৫০ টাকার নোট', controller.count50, 50),
                    _buildNoteInputRow('২০ টাকার নোট', controller.count20, 20),
                    _buildNoteInputRow('১০ টাকার নোট', controller.count10, 10),
                    _buildNoteInputRow('৫ টাকার কয়েন/নোট', controller.count5, 5),
                    _buildNoteInputRow('২ টাকার কয়েন/নোট', controller.count2, 2),
                    _buildNoteInputRow('১ টাকার কয়েন', controller.count1, 1),
                  ],
                );
              }),
              const SizedBox(height: AppSizes.p16),
              const Divider(),
              // Difference calculation
              Obx(() {
                final diff = controller.differenceMinor;
                final actual = controller.actualCountedCashMinor;
                Color statusColor;
                String statusText;

                if (diff == 0) {
                  statusColor = AppColors.incomeGreen;
                  statusText = 'ক্যাশ হিসাব সম্পূর্ণ মিলেছে (Balanced)';
                } else if (diff > 0) {
                  statusColor = AppColors.infoBlue;
                  statusText =
                      'ক্যাশ উদ্বৃত্ত (Surplus): +${CurrencyUtils.format(diff)}';
                } else {
                  statusColor = AppColors.expenseRed;
                  statusText =
                      'ক্যাশ ঘাটতি (Shortage): ${CurrencyUtils.format(diff)}';
                }

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('গণনাকৃত মোট ক্যাশ:',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        Text(CurrencyUtils.format(actual),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                label: 'ক্লোজিং মন্তব্য / নোট (ঐচ্ছিক)',
                controller: controller.closingNotesController,
              ),
              const SizedBox(height: AppSizes.p16),
              AppButton(
                text: 'ক্যাশ সেশন ক্লোজ করুন (Day End)',
                icon: Icons.check_circle_outline,
                onPressed: () async {
                  final ok = await controller.closeSession();
                  if (ok) Get.back();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlowRow(String label, String amount, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          Text(amount,
              style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNoteInputRow(
      String label, TextEditingController countCtrl, int noteValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: countCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: (_) {
                  // Trigger UI update for denomination calculation
                  controller.manualClosingController.text =
                      controller.manualClosingController.text;
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: countCtrl,
              builder: (_, value, __) {
                final qty = int.tryParse(value.text) ?? 0;
                return Text(
                  CurrencyUtils.format(qty * noteValue * 100),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
      Color cardBg, Color borderColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'পূর্বের ক্যাশ ক্লোজিং ইতিহাস (History)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSizes.p12),
        Obx(() {
          if (controller.pastSessions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              alignment: Alignment.center,
              child: Text(
                'কোন পূর্ববর্তী সেশন রেকর্ড নেই',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            );
          }

          return Column(
            children: controller.pastSessions.take(7).map((s) {
              final dateStr = DateFormat('dd MMM yyyy')
                  .format(DateTime.fromMillisecondsSinceEpoch(s.sessionDate));
              final isClosed = s.status == 'closed';
              final diff = s.differenceMinor ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(dateStr,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    'প্রারম্ভিক: ${CurrencyUtils.format(s.openingCashMinor)} • ক্লোজিং: ${CurrencyUtils.format(s.actualClosingMinor ?? 0)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Text(
                    isClosed
                        ? (diff == 0
                            ? 'হিসাব মিলেছে'
                            : (diff > 0
                                ? '+${CurrencyUtils.format(diff)}'
                                : CurrencyUtils.format(diff)))
                        : 'চলমান',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isClosed
                          ? (diff == 0
                              ? AppColors.incomeGreen
                              : (diff > 0
                                  ? AppColors.infoBlue
                                  : AppColors.expenseRed))
                          : AppColors.warningAmberDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
