import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/document_controller.dart';

class DocumentsView extends GetView<DocumentController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            final ext = doc.fileName.contains('.')
                ? doc.fileName.split('.').last.toLowerCase()
                : '';
            final isImage = ext == 'jpg' ||
                ext == 'jpeg' ||
                ext == 'png' ||
                ext == 'webp' ||
                (doc.mimeType?.startsWith('image/') == true);

            Widget leadingWidget;
            if (isImage) {
              leadingWidget = AppImage(
                imagePath: doc.filePath,
                width: 44,
                height: 44,
                borderRadius: AppSizes.r8,
                fallbackIcon: Icons.image_outlined,
              );
            } else if (ext == 'pdf' || doc.mimeType == 'application/pdf') {
              leadingWidget = Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.expenseRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
                child: const Icon(Icons.picture_as_pdf_outlined,
                    color: AppColors.expenseRed, size: 24),
              );
            } else {
              leadingWidget = Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondaryElectric.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
                child: const Icon(AppIcons.documents,
                    color: AppColors.secondaryElectric, size: 24),
              );
            }

            return Card(
              child: ListTile(
                leading: leadingWidget,
                title: Text(doc.fileName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                  '${(doc.fileSize / 1024).toStringAsFixed(1)} KB • ${AppDateUtils.formatTimestamp(doc.createdAt)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                trailing: const Icon(Icons.attachment_rounded,
                    color: AppColors.textSecondaryLight),
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
