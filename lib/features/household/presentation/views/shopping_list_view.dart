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
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/household_controller.dart';

class ShoppingListView extends GetView<HouseholdController> {
  const ShoppingListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = Get.find<DatabaseService>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('shopping_list'.tr),
      ),
      body: StreamBuilder<List<ShoppingListItem>>(
        stream: dbService.database.select(dbService.database.shoppingListItems).watch(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return AppEmptyState(
              message: 'বাজারের ফর্দ খালি',
              actionText: 'add_item'.tr,
              onAction: () => _showAddItemDialog(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
            itemBuilder: (context, index) {
              final item = items[index];
              final isDone = item.isPurchased == 1;

              return Card(
                child: CheckboxListTile(
                  value: isDone,
                  title: Text(
                    item.itemName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? AppColors.textMutedLight : AppColors.textPrimaryLight,
                    ),
                  ),
                  subtitle: Text('${item.quantity} ${item.unit}'),
                  onChanged: (val) {
                    controller.toggleShoppingItem(item.id, val ?? false);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    String unit = 'kg';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r12)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ফর্দে পণ্য যোগ করুন', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSizes.p16),
              AppTextField(label: 'পণ্যের নাম', controller: nameController, hint: 'যেমন: আলু, পেঁয়াজ, ডিম'),
              const SizedBox(height: AppSizes.p12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(label: 'পরিমাণ', controller: qtyController, keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: unit,
                      decoration: const InputDecoration(labelText: 'একক'),
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('কেজি')),
                        DropdownMenuItem(value: 'liter', child: Text('লিটার')),
                        DropdownMenuItem(value: 'piece', child: Text('পিস')),
                        DropdownMenuItem(value: 'packet', child: Text('প্যাকেট')),
                      ],
                      onChanged: (v) => unit = v ?? 'kg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p24),
              AppButton(
                text: 'save'.tr,
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  final dbService = Get.find<DatabaseService>();
                  final qty = double.tryParse(qtyController.text) ?? 1.0;
                  await dbService.householdDao.insertShoppingListItem(
                    ShoppingListItemsCompanion(
                      id: drift.Value(const Uuid().v4()),
                      shoppingListId: const drift.Value('default_list'),
                      itemName: drift.Value(nameController.text.trim()),
                      quantity: drift.Value(qty),
                      unit: drift.Value(unit),
                      isPurchased: const drift.Value(0),
                    ),
                  );
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
