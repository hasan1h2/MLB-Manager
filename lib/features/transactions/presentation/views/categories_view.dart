import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/transaction_controller.dart';

class CategoriesView extends GetView<TransactionController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text('category'.tr),
          bottom: TabBar(
            tabs: [
              Tab(text: 'add_expense'.tr),
              Tab(text: 'add_income'.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryList('expense'),
            _buildCategoryList('income'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddCategoryDialog(context),
          backgroundColor: AppColors.primaryNavy,
          child: const Icon(AppIcons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoryList(String type) {
    return Obx(() {
      final list = controller.categories.where((c) => c.categoryType == type).toList();
      final isBn = Get.locale?.languageCode == 'bn';

      return ListView.separated(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
        itemBuilder: (context, index) {
          final cat = list[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (type == 'income' ? AppColors.incomeGreen : AppColors.expenseRed).withValues(alpha: 0.12),
                child: Icon(
                  type == 'income' ? AppIcons.income : AppIcons.expense,
                  color: type == 'income' ? AppColors.incomeGreen : AppColors.expenseRed,
                  size: 20,
                ),
              ),
              title: Text(
                isBn ? cat.nameBn : cat.nameEn,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                isBn ? cat.nameEn : cat.nameBn,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
              trailing: cat.isSystem == 1
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.dividerLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('System', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                    )
                  : null,
            ),
          );
        },
      );
    });
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameBnController = TextEditingController();
    final nameEnController = TextEditingController();
    final RxString catType = 'expense'.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r12)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ক্যাটাগরি যোগ করুন', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSizes.p16),
              AppTextField(label: 'বাংলায় নাম', controller: nameBnController),
              const SizedBox(height: AppSizes.p12),
              AppTextField(label: 'English Name', controller: nameEnController),
              const SizedBox(height: AppSizes.p16),
              Obx(() => Row(
                    children: [
                      Radio<String>(
                        value: 'expense',
                        groupValue: catType.value,
                        onChanged: (v) => catType.value = v!,
                      ),
                      Text('add_expense'.tr),
                      const SizedBox(width: AppSizes.p16),
                      Radio<String>(
                        value: 'income',
                        groupValue: catType.value,
                        onChanged: (v) => catType.value = v!,
                      ),
                      Text('add_income'.tr),
                    ],
                  )),
              const SizedBox(height: AppSizes.p24),
              AppButton(
                text: 'save'.tr,
                onPressed: () async {
                  if (nameBnController.text.trim().isEmpty) return;
                  final dbService = Get.find<DatabaseService>();
                  final now = DateTime.now().toUtc().millisecondsSinceEpoch;
                  await dbService.coreDao.insertCategory(
                    CategoriesCompanion(
                      id: drift.Value(const Uuid().v4()),
                      nameBn: drift.Value(nameBnController.text.trim()),
                      nameEn: drift.Value(nameEnController.text.trim().isNotEmpty
                          ? nameEnController.text.trim()
                          : nameBnController.text.trim()),
                      categoryType: drift.Value(catType.value),
                      scope: const drift.Value('both'),
                      isSystem: const drift.Value(0),
                      createdAt: drift.Value(now),
                    ),
                  );
                  Get.back();
                  AppSnackbar.success('Category added');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
