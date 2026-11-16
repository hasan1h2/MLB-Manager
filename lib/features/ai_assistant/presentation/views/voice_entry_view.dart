import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/ai_assistant_controller.dart';

class VoiceEntryView extends GetView<AiAssistantController> {
  const VoiceEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('voice_entry'.tr),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            children: [
              const Text(
                'উদাহরণস্বরূপ বলুন:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: AppColors.infoBlueLight,
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
                child: const Text(
                  '"আজ বাজার থেকে ২ কেজি চাল ১৪০ টাকা এবং ১ লিটার তেল ১৮০ টাকা কিনেছি।"',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.primaryNavy),
                ),
              ),
              const Spacer(),
              Obx(() {
                final text = controller.recognizedVoiceText.value;
                return Text(
                  text.isNotEmpty ? text : (controller.isListening.value ? 'listening'.tr : 'tap_to_speak'.tr),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: text.isNotEmpty ? FontWeight.w600 : FontWeight.w400,
                    color: controller.isListening.value ? AppColors.secondaryElectric : AppColors.textSecondaryLight,
                  ),
                );
              }),
              const SizedBox(height: AppSizes.p32),
              Obx(() {
                final isRec = controller.isListening.value;
                return GestureDetector(
                  onTap: () => controller.toggleVoiceListening(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(isRec ? 28 : 24),
                    decoration: BoxDecoration(
                      color: isRec ? AppColors.expenseRed : AppColors.secondaryElectric,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isRec ? AppColors.expenseRed : AppColors.secondaryElectric).withValues(alpha: 0.35),
                          blurRadius: 20,
                          spreadRadius: isRec ? 8 : 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      isRec ? Icons.stop_rounded : AppIcons.mic,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
              const Spacer(),
              AppButton(
                text: 'ম্যানুয়াল টেক্সট এন্ট্রি করুন',
                isOutlined: true,
                onPressed: () => _showManualTextInputDialog(context),
              ),
              const SizedBox(height: AppSizes.p16),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualTextInputDialog(BuildContext context) {
    final textCtrl = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r12)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('টেক্সট লিখে স্বয়ংক্রিয় পার্স করুন', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'যেমন: ২ কেজি পেঁয়াজ ১২০ টাকা...',
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'পার্স ও রিভিউ করুন',
                onPressed: () {
                  Get.back();
                  controller.parseNaturalLanguage(textCtrl.text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
