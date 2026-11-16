import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../controllers/ai_assistant_controller.dart';

class AiAssistantView extends GetView<AiAssistantController> {
  const AiAssistantView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('ai_assistant'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeatureCards(),
            const SizedBox(height: AppSizes.p24),
            Text(
              'expense_prediction'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.p8),
            _buildForecastCard(),
            const SizedBox(height: AppSizes.p24),
            _buildPrivacyNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.secondaryElectric.withValues(alpha: 0.12),
              child: const Icon(AppIcons.mic, color: AppColors.secondaryElectric),
            ),
            title: Text('voice_entry'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('মুখে বলে স্বয়ংক্রিয় লেনদেন যুক্ত করুন', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => Get.toNamed(AppRoutes.voiceEntry),
          ),
        ),
        const SizedBox(height: AppSizes.p12),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withValues(alpha: 0.12),
              child: const Icon(AppIcons.ocr, color: Colors.purple),
            ),
            title: Text('ocr_receipt_scanner'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('রসিদ বা মেমোর ছবি তুলে অটোমেটিক এন্ট্রি', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => Get.toNamed(AppRoutes.receiptScanner),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastCard() {
    return Obx(() {
      return Card(
        color: AppColors.infoBlueLight,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('আগামী মাসের সম্ভাব্য মোট খরচ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const Icon(Icons.auto_graph_rounded, color: AppColors.secondaryElectric),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyUtils.format(controller.forecastedMonthlyExpenseMinor.value),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'নির্ভরযোগ্যতা সূচক: ${controller.forecastConfidence.value}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 8),
              const Text(
                '* স্থানীয় মুভিং-অ্যাভারেজ গাণিতিক মডেলের মাধ্যমে অনুমিত। এটি কোনো আর্থিক নিশ্চয়তা নয়।',
                style: TextStyle(fontSize: 10, color: AppColors.textMutedLight, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPrivacyNotice() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Row(
          children: [
            const Icon(Icons.privacy_tip_outlined, color: AppColors.incomeGreen, size: 28),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('১০০% অফলাইন ও সম্পূর্ণ গোপনীয়', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  SizedBox(height: 2),
                  Text(
                    'আপনার ভয়েস ও রসিদের কোনো ছবি ইন্টারনেটে পাঠানো হয় না। ডিভাইসের অভ্যন্তরীণ প্রযুক্তিতে প্রক্রিয়াজাত হয়।',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
