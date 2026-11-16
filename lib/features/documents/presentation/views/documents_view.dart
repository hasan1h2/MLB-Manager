import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/document_controller.dart';

class DocumentsView extends GetView<DocumentController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('documents'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }

        if (controller.attachments.isEmpty) {
          return AppEmptyState(
            message: 'কোন ডকুমেন্ট বা রসিদ আপলোড করা হয়নি',
            actionText: 'ডকুমেন্ট যোগ করুন',
            onAction: () => controller.pickAndSaveDocument(),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: controller.attachments.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
          itemBuilder: (context, index) {
            final doc = controller.attachments[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondaryElectric.withValues(alpha: 0.12),
                  child: const Icon(AppIcons.documents, color: AppColors.secondaryElectric),
                ),
                title: Text(doc.fileName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                  '${(doc.fileSize / 1024).toStringAsFixed(1)} KB • ${AppDateUtils.formatTimestamp(doc.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                trailing: const Icon(Icons.attachment_rounded, color: AppColors.textSecondaryLight),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.pickAndSaveDocument(),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }
}
