import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/ai_assistant_controller.dart';

class ReceiptScannerView extends GetView<AiAssistantController> {
  const ReceiptScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ocr_receipt_scanner'.tr),
      ),
      body: Obx(() {
        if (controller.isProcessingOcr.value) {
          return const AppLoadingIndicator(message: 'ছবি থেকে টেক্সট এক্সট্রাক্ট করা হচ্ছে...');
        }

        return Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.p32),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.ocr, size: 72, color: Colors.purple),
              ),
              const SizedBox(height: AppSizes.p24),
              const Text(
                'রসিদ বা ভাউচার স্ক্যান করুন',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSizes.p8),
              const Text(
                'ক্যামেরা দিয়ে সরাসরি ছবি তুলুন অথবা গ্যালারি থেকে পূর্বে সংরক্ষিত মেমোর ছবি নির্বাচন করুন',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: AppSizes.p48),
              AppButton(
                text: 'ক্যামেরা দিয়ে ছবি তুলুন',
                icon: Icons.camera_alt_rounded,
                backgroundColor: AppColors.primaryNavy,
                onPressed: () => controller.pickAndScanReceipt(fromCamera: true),
              ),
              const SizedBox(height: AppSizes.p16),
              AppButton(
                text: 'গ্যালারি থেকে ছবি নিন',
                icon: Icons.photo_library_rounded,
                isOutlined: true,
                onPressed: () => controller.pickAndScanReceipt(fromCamera: false),
              ),
            ],
          ),
        );
      }),
    );
  }
}
