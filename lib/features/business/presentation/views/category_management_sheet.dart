import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/active_business_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';

class CategoryManagementSheet extends StatefulWidget {
  const CategoryManagementSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (_) => const CategoryManagementSheet(),
    );
  }

  @override
  State<CategoryManagementSheet> createState() =>
      _CategoryManagementSheetState();
}

class _CategoryManagementSheetState extends State<CategoryManagementSheet> {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ActiveBusinessService _activeBiz = Get.find<ActiveBusinessService>();
  final _uuid = const Uuid();

  List<Category> _categories = [];
  Map<String, List<Category>> _subcategoriesMap = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final bizId = _activeBiz.activeBusiness.value?.id;
    final allCats = await _dbService.coreDao.getProductCategories(
      businessId: bizId,
      activeOnly: false, // show all so user can enable/disable
    );

    final rootCats = allCats.where((c) => c.parentId == null).toList();
    final subMap = <String, List<Category>>{};

    for (final c in rootCats) {
      final subs = allCats.where((sub) => sub.parentId == c.id).toList();
      subMap[c.id] = subs;
    }

    setState(() {
      _categories = rootCats;
      _subcategoriesMap = subMap;
      _isLoading = false;
    });
  }

  void _showAddCategoryDialog({Category? parentCategory, Category? editCategory}) {
    final nameBnCtrl =
        TextEditingController(text: editCategory?.nameBn ?? '');
    final nameEnCtrl =
        TextEditingController(text: editCategory?.nameEn ?? '');

    Get.defaultDialog(
      title: editCategory != null
          ? 'ক্যাটাগরি সম্পাদনা'
          : parentCategory != null
              ? 'নতুন সাবক্যাটাগরি যোগ (${parentCategory.nameBn})'
              : 'নতুন ক্যাটাগরি যোগ',
      content: Padding(
        padding: const EdgeInsets.all(AppSizes.p8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'ক্যাটাগরির নাম (বাংলা)*',
              controller: nameBnCtrl,
            ),
            const SizedBox(height: 8),
            AppTextField(
              label: 'নাম (English - ঐচ্ছিক)',
              controller: nameEnCtrl,
            ),
          ],
        ),
      ),
      textConfirm: 'সংরক্ষণ',
      textCancel: 'বাতিল',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        final bn = nameBnCtrl.text.trim();
        final en = nameEnCtrl.text.trim().isNotEmpty
            ? nameEnCtrl.text.trim()
            : bn;
        if (bn.isEmpty) {
          AppSnackbar.error('নাম লিখুন');
          return;
        }

        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        final bizId = _activeBiz.activeBusiness.value?.id;

        if (editCategory != null) {
          final updated = editCategory.copyWith(
            nameBn: bn,
            nameEn: en,
          );
          await _dbService.coreDao.updateCategory(updated);
          AppSnackbar.success('ক্যাটাগরি আপডেট করা হয়েছে');
        } else {
          await _dbService.coreDao.insertCategory(
            CategoriesCompanion(
              id: drift.Value(_uuid.v4()),
              nameBn: drift.Value(bn),
              nameEn: drift.Value(en),
              categoryType: const drift.Value('product'),
              scope: const drift.Value('business'),
              businessId: drift.Value(bizId),
              parentId: drift.Value(parentCategory?.id),
              icon: const drift.Value('category'),
              isSystem: const drift.Value(0),
              isActive: const drift.Value(1),
              createdAt: drift.Value(now),
            ),
          );
          AppSnackbar.success('ক্যাটাগরি যুক্ত হয়েছে');
        }

        Get.back();
        await _loadCategories();
      },
    );
  }

  Future<void> _toggleArchive(Category cat) async {
    final newActive = cat.isActive == 1 ? 0 : 1;
    final updated = cat.copyWith(isActive: newActive);
    await _dbService.coreDao.updateCategory(updated);
    AppSnackbar.success(newActive == 1
        ? '${cat.nameBn} সক্রিয় করা হয়েছে'
        : '${cat.nameBn} আর্কাইভ করা হয়েছে');
    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final filtered = _categories.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.nameBn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.nameEn.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: AppSizes.p16,
        left: AppSizes.p16,
        right: AppSizes.p16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.category_rounded,
                        color: AppColors.secondaryElectric),
                    SizedBox(width: 8),
                    Text(
                      'ক্যাটাগরি ও সাবক্যাটাগরি',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'ক্যাটাগরি খুঁজুন...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryElectric,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('নতুন ক্যাটাগরি',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _showAddCategoryDialog(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(
                          child: Text('কোন ক্যাটাগরি পাওয়া যায়নি'))
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final cat = filtered[index];
                            final subs = _subcategoriesMap[cat.id] ?? [];
                            final isArchived = cat.isActive == 0;

                            return Card(
                              color: isArchived
                                  ? (isDark
                                      ? Colors.white10
                                      : Colors.grey.shade200)
                                  : cardBg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                    color: isArchived
                                        ? Colors.transparent
                                        : borderColor),
                              ),
                              child: ExpansionTile(
                                leading: Icon(
                                  Icons.label_outline,
                                  color: isArchived
                                      ? Colors.grey
                                      : AppColors.secondaryElectric,
                                ),
                                title: Text(
                                  cat.nameBn,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    decoration: isArchived
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isArchived ? Colors.grey : null,
                                  ),
                                ),
                                subtitle: Text(
                                  '${subs.length} টি সাবক্যাটাগরি ${isArchived ? "• (আর্কাইভ)" : ""}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 18),
                                      tooltip: 'সম্পাদনা',
                                      onPressed: () => _showAddCategoryDialog(
                                          editCategory: cat),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isArchived
                                            ? Icons.restore_rounded
                                            : Icons.archive_outlined,
                                        size: 18,
                                        color: isArchived
                                            ? AppColors.incomeGreen
                                            : AppColors.warningAmberDark,
                                      ),
                                      tooltip: isArchived
                                          ? 'পুনরুদ্ধার'
                                          : 'আর্কাইভ করুন',
                                      onPressed: () => _toggleArchive(cat),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('সাবক্যাটাগরি সমূহ:',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                        TextButton.icon(
                                          icon: const Icon(Icons.add, size: 14),
                                          label: const Text(
                                              'সাবক্যাটাগরি যোগ',
                                              style: TextStyle(fontSize: 12)),
                                          onPressed: () =>
                                              _showAddCategoryDialog(
                                                  parentCategory: cat),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (subs.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        'কোন সাবক্যাটাগরি নেই',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey),
                                      ),
                                    )
                                  else
                                    ...subs.map((sub) {
                                      final isSubArchived = sub.isActive == 0;
                                      return ListTile(
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.only(left: 32, right: 16),
                                        title: Text(
                                          sub.nameBn,
                                          style: TextStyle(
                                            fontSize: 13,
                                            decoration: isSubArchived
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: isSubArchived
                                                ? Colors.grey
                                                : null,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 16),
                                              onPressed: () =>
                                                  _showAddCategoryDialog(
                                                parentCategory: cat,
                                                editCategory: sub,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                isSubArchived
                                                    ? Icons.restore_rounded
                                                    : Icons.archive_outlined,
                                                size: 16,
                                                color: isSubArchived
                                                    ? AppColors.incomeGreen
                                                    : AppColors.warningAmberDark,
                                              ),
                                              onPressed: () =>
                                                  _toggleArchive(sub),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
