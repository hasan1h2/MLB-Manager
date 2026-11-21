import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/product_import_controller.dart';

class ProductImportView extends GetView<ProductImportController> {
  const ProductImportView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('পণ্য ইমপোর্ট ও স্ক্যান (Import)',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Obx(() {
        if (controller.isProcessing.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLoadingIndicator(),
                SizedBox(height: 16),
                Text('ফাইল প্রসেসিং হচ্ছে, অনুগ্রহ করে অপেক্ষা করুন...'),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildImportOptions(context, cardBg, borderColor, isDark),
            Expanded(
              child: _buildCandidatesList(context, cardBg, borderColor, isDark),
            ),
            if (controller.candidates.isNotEmpty)
              _buildBottomSavePanel(context, cardBg, borderColor),
          ],
        );
      }),
    );
  }

  Widget _buildImportOptions(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ইমপোর্টের মাধ্যম নির্বাচন করুন',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSizes.p10),
          Row(
            children: [
              Expanded(
                child: _buildSourceButton(
                  icon: Icons.table_chart_outlined,
                  color: AppColors.incomeGreen,
                  label: 'Excel (.xlsx)',
                  onTap: () => controller.importFromExcel(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSourceButton(
                  icon: Icons.description_outlined,
                  color: AppColors.infoBlue,
                  label: 'CSV ফাইল',
                  onTap: () => controller.importFromCsv(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSourceButton(
                  icon: Icons.camera_alt_outlined,
                  color: AppColors.secondaryElectric,
                  label: 'ছবি OCR',
                  onTap: () => _showOcrChoiceSheet(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.r8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.r8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showOcrChoiceSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('রসিদ বা পণ্য তালিকার ছবি OCR স্ক্যান',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.p12),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('ক্যামেরা দিয়ে ছবি তুলুন'),
              onTap: () {
                Get.back();
                controller.importFromImage(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('গ্যালারি থেকে ছবি বাছাই করুন'),
              onTap: () {
                Get.back();
                controller.importFromImage(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidatesList(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    if (controller.candidates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_upload_outlined,
                size: 64,
                color: isDark
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                    : AppColors.textSecondaryLight.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text(
              'কোন পণ্য ইমপোর্ট তালিকা নেই',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'উপরে এক্সেল (.xlsx), সিএসভি (.csv) ফাইল অথবা পণ্যের তালিকার ছবি নির্বাচন করুন। স্বয়ংক্রিয়ভাবে ডাটা প্রিভিউ টেবিলে চলে আসবে।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('ম্যানুয়ালি একটি রো যোগ করুন'),
              onPressed: () => controller.addManualCandidate(),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'শনাক্তকৃত পণ্য তালিকা (${controller.candidates.length} টি)',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('আরও রো যোগ', style: TextStyle(fontSize: 12)),
                onPressed: () => controller.addManualCandidate(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            itemCount: controller.candidates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final c = controller.candidates[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Obx(() => Checkbox(
                                value: c.isSelected.value,
                                onChanged: (v) {
                                  if (v != null) c.isSelected.value = v;
                                },
                              )),
                          Expanded(
                            child: TextField(
                              controller: c.nameController,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: 'পণ্যের নাম',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.grey, size: 18),
                            onPressed: () => controller.removeCandidate(c),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: c.unitController,
                              decoration: const InputDecoration(
                                labelText: 'একক',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: c.purchasePriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'ক্রয়দর (৳)',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: c.sellingPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'খুচরা (৳)',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: c.wholesalePriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'পাইকারি (৳)',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: c.stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'স্টক',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSavePanel(
      BuildContext context, Color cardBg, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          text: 'নির্বাচিত পণ্যসমূহ ডেটাবেজে যুক্ত করুন',
          icon: AppIcons.check,
          onPressed: () async {
            final ok = await controller.saveImportedProducts();
            if (ok) Get.back();
          },
        ),
      ),
    );
  }
}
