import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/ai_assistant_controller.dart';

class OcrReviewView extends GetView<AiAssistantController> {
  const OcrReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('ocr_review'.tr),
      ),
      body: Obx(() {
        final items = controller.extractedItems;
        if (items.isEmpty) {
          return const Center(child: Text('কোন তথ্য পাওয়া যায়নি'));
        }

        int totalMinor = 0;
        for (var item in items) {
          totalMinor += item.totalMinor;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.p12),
                decoration: BoxDecoration(
                  color: AppColors.warningAmberLight,
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.warningAmberDark, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'অনুগ্রহ করে সেভ করার পূর্বে প্রতিটি পণ্যের নাম ও টাকার পরিমাণ যাচাই বা সংশোধন করে নিন।',
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimaryLight),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.p16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              initialValue: item.name,
                              decoration: const InputDecoration(labelText: 'পণ্যের নাম', isDense: true),
                              onChanged: (val) => item.name = val,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              initialValue: item.quantity.toString(),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'পরিমাণ', isDense: true),
                              onChanged: (val) {
                                item.quantity = double.tryParse(val) ?? 1.0;
                                controller.extractedItems.refresh();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: (item.unitPriceMinor / 100).toStringAsFixed(0),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'দর/মূল্য', isDense: true),
                              onChanged: (val) {
                                item.unitPriceMinor = CurrencyUtils.takaToMinor(val);
                                controller.extractedItems.refresh();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.p16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('সর্বমোট বিল:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(
                        CurrencyUtils.format(totalMinor),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.expenseRed),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p24),
              AppButton(
                text: 'যাচাই শেষে নিশ্চিত করুন ও সেভ করুন',
                icon: AppIcons.check,
                onPressed: () => controller.confirmAndSaveExtractedBill(),
              ),
              const SizedBox(height: AppSizes.p32),
            ],
          ),
        );
      }),
    );
  }
}
