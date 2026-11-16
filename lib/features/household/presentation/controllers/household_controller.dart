import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class ShoppingItemDraft {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController unitPriceController = TextEditingController();
  String unit = 'kg';

  int get totalMinor {
    final qty = double.tryParse(qtyController.text) ?? 1.0;
    final unitPriceMinor = CurrencyUtils.takaToMinor(unitPriceController.text);
    return (qty * unitPriceMinor).round();
  }

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
    unitPriceController.dispose();
  }
}

class HouseholdController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<ShoppingRecord> shoppingRecords = <ShoppingRecord>[].obs;
  final RxList<ShoppingList> shoppingLists = <ShoppingList>[].obs;
  final RxList<ShoppingListItem> currentListItems = <ShoppingListItem>[].obs;
  final RxBool isLoading = true.obs;

  // Form Fields for Shopping Entry
  final storeNameController = TextEditingController();
  final discountController = TextEditingController(text: '0');
  final paidController = TextEditingController();
  final RxList<ShoppingItemDraft> draftItems = <ShoppingItemDraft>[].obs;
  final Rx<DateTime> shoppingDate = DateTime.now().obs;
  final Rx<String?> selectedAccountId = Rx<String?>(null);
  final Rx<String?> selectedMemberId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    watchData();
    addItemDraft();
  }

  void watchData() {
    _dbService.householdDao.watchShoppingRecords().listen((records) {
      shoppingRecords.value = records;
      isLoading.value = false;
    });

    _dbService.householdDao.watchShoppingLists().listen((lists) {
      shoppingLists.value = lists;
    });

    _dbService.coreDao.getAllAccounts().then((accounts) {
      if (accounts.isNotEmpty && selectedAccountId.value == null) {
        selectedAccountId.value = accounts.first.id;
      }
    });
  }

  void addItemDraft() {
    draftItems.add(ShoppingItemDraft());
  }

  void removeItemDraft(int index) {
    if (draftItems.length > 1) {
      final item = draftItems.removeAt(index);
      item.dispose();
    }
  }

  int get subtotalMinor {
    int sum = 0;
    for (var item in draftItems) {
      sum += item.totalMinor;
    }
    return sum;
  }

  int get discountMinor => CurrencyUtils.takaToMinor(discountController.text);

  int get totalBillMinor {
    final total = subtotalMinor - discountMinor;
    return total < 0 ? 0 : total;
  }

  Future<bool> saveShoppingBill() async {
    if (draftItems.isEmpty || draftItems.first.nameController.text.trim().isEmpty) {
      AppSnackbar.error('অনুগ্রহ করে অন্তত একটি পণ্য যোগ করুন');
      return false;
    }

    final total = totalBillMinor;
    final paid = paidController.text.trim().isNotEmpty
        ? CurrencyUtils.takaToMinor(paidController.text)
        : total;
    final due = total - paid;

    final recordId = _uuid.v4();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final shoppingDateMs = shoppingDate.value.toUtc().millisecondsSinceEpoch;

    final record = ShoppingRecordsCompanion(
      id: Value(recordId),
      shoppingDate: Value(shoppingDateMs),
      storeName: Value(storeNameController.text.trim()),
      purchasedByMemberId: Value(selectedMemberId.value),
      subtotalMinor: Value(subtotalMinor),
      discountMinor: Value(discountMinor),
      totalMinor: Value(total),
      paidMinor: Value(paid),
      dueMinor: Value(due < 0 ? 0 : due),
      createdAt: Value(now),
    );

    final items = <ShoppingItemsCompanion>[];
    for (var draft in draftItems) {
      if (draft.nameController.text.trim().isNotEmpty) {
        final qty = double.tryParse(draft.qtyController.text) ?? 1.0;
        final unitPriceMinor = CurrencyUtils.takaToMinor(draft.unitPriceController.text);
        items.add(
          ShoppingItemsCompanion(
            id: Value(_uuid.v4()),
            shoppingRecordId: Value(recordId),
            productName: Value(draft.nameController.text.trim()),
            quantity: Value(qty),
            unit: Value(draft.unit),
            unitPriceMinor: Value(unitPriceMinor),
            totalMinor: Value(draft.totalMinor),
          ),
        );
      }
    }

    // Link directly to household expense without creating duplicate expense bills!
    TransactionsCompanion? expenseTx;
    List<TransactionEntriesCompanion>? journalEntries;

    if (paid > 0 && selectedAccountId.value != null) {
      final txId = _uuid.v4();
      final txNumber = 'SHOP-${now.toString().substring(5)}';

      // Find or assign Household Grocery category
      final categories = await _dbService.coreDao.getAllCategories(type: 'expense');
      final groceryCat = categories.firstWhereOrNull((c) => c.nameEn.contains('Grocery') || c.nameBn.contains('বাজার'));

      expenseTx = TransactionsCompanion(
        id: Value(txId),
        transactionNumber: Value(txNumber),
        transactionType: const Value('expense'),
        scopeType: const Value('family'),
        familyMemberId: Value(selectedMemberId.value),
        categoryId: Value(groceryCat?.id ?? (categories.isNotEmpty ? categories.first.id : null)),
        accountId: Value(selectedAccountId.value),
        amountMinor: Value(paid),
        transactionDate: Value(shoppingDateMs),
        description: Value('বাজার খরচ: ${storeNameController.text.trim()}'),
        paymentStatus: Value(due > 0 ? 'partial' : 'paid'),
        sourceType: const Value('shopping'),
        sourceId: Value(recordId),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      journalEntries = [
        TransactionEntriesCompanion(
          id: Value(_uuid.v4()),
          transactionId: Value(txId),
          accountId: Value(selectedAccountId.value!),
          debitMinor: Value(paid), // Outflow from account
          creditMinor: const Value(0),
          createdAt: Value(now),
        ),
        TransactionEntriesCompanion(
          id: Value(_uuid.v4()),
          transactionId: Value(txId),
          accountId: Value(selectedAccountId.value!),
          debitMinor: const Value(0),
          creditMinor: Value(paid),
          createdAt: Value(now),
        ),
      ];
    }

    try {
      await _dbService.householdDao.postShoppingRecordWithItems(
        record: record,
        items: items,
        expenseTransaction: expenseTx,
        journalEntries: journalEntries,
      );

      AppSnackbar.success('বাজারের হিসাব সফলভাবে সংরক্ষিত হয়েছে');
      resetForm();
      return true;
    } catch (e) {
      AppSnackbar.error('Error: $e');
      return false;
    }
  }

  void resetForm() {
    storeNameController.clear();
    discountController.text = '0';
    paidController.clear();
    for (var draft in draftItems) {
      draft.dispose();
    }
    draftItems.clear();
    addItemDraft();
  }

  // --- Shopping List Item Toggling ---
  Future<void> toggleShoppingItem(String itemId, bool isPurchased) async {
    await _dbService.householdDao.toggleListItemPurchased(itemId, isPurchased);
  }

  @override
  void onClose() {
    storeNameController.dispose();
    discountController.dispose();
    paidController.dispose();
    for (var draft in draftItems) {
      draft.dispose();
    }
    super.onClose();
  }
}
