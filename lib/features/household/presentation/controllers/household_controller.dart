import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class CartItem {
  final String id;
  String productName;
  final RxDouble quantity;
  String unit;
  final RxInt unitPriceMinor;
  final RxInt lineTotalMinor;
  final Rx<String?> note;
  final Rx<String?> imagePath;

  CartItem({
    String? id,
    required this.productName,
    double quantity = 1.0,
    this.unit = 'kg',
    int unitPriceMinor = 0,
    int? lineTotalMinor,
    String? note,
    String? imagePath,
  })  : id = id ?? const Uuid().v4(),
        quantity = quantity.obs,
        unitPriceMinor = unitPriceMinor.obs,
        lineTotalMinor = (lineTotalMinor ??
                (unitPriceMinor > 0 ? (quantity * unitPriceMinor).round() : 0))
            .obs,
        note = Rx<String?>(note),
        imagePath = Rx<String?>(imagePath);

  int get subtotalMinor => lineTotalMinor.value;
}

class ProductSummaryItem {
  final String productName;
  final String unit;
  final double totalQuantity;
  final int totalAmountMinor;
  final int purchaseCount;
  final String? imagePath;

  ProductSummaryItem({
    required this.productName,
    required this.unit,
    required this.totalQuantity,
    required this.totalAmountMinor,
    required this.purchaseCount,
    this.imagePath,
  });

  int get avgPriceMinor => (totalQuantity > 0)
      ? (totalAmountMinor / totalQuantity).round()
      : (purchaseCount > 0 ? (totalAmountMinor / purchaseCount).round() : 0);
}

class _ProductAggregator {
  final String displayName;
  final String unit;
  double totalQuantity = 0.0;
  int totalAmountMinor = 0;
  int purchaseCount = 0;
  String? imagePath;

  _ProductAggregator({
    required this.displayName,
    required this.unit,
    this.imagePath,
  });
}

class ShoppingItemDraft {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController lineTotalController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  String unit = 'kg';

  int get totalMinor {
    if (lineTotalController.text.trim().isNotEmpty) {
      return CurrencyUtils.takaToMinor(lineTotalController.text);
    }
    final qty = double.tryParse(qtyController.text) ?? 1.0;
    final unitPriceMinor = CurrencyUtils.takaToMinor(unitPriceController.text);
    return (qty * unitPriceMinor).round();
  }

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
    unitPriceController.dispose();
    lineTotalController.dispose();
    noteController.dispose();
  }
}

class HouseholdController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<ShoppingRecord> shoppingRecords = <ShoppingRecord>[].obs;
  final RxList<ShoppingList> shoppingLists = <ShoppingList>[].obs;
  final RxList<ShoppingListItem> currentListItems = <ShoppingListItem>[].obs;
  final RxBool isLoading = true.obs;

  // Entry Mode: 'itemized' (পণ্যের তালিকা) vs 'direct_total' (শুধু মোট টাকা)
  final RxString entryMode = 'itemized'.obs;

  // Shopping Cart Items
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  // Form Fields for Shopping Entry
  final storeNameController = TextEditingController();
  final discountController = TextEditingController(text: '0');
  final paidController = TextEditingController();
  final notesController = TextEditingController();
  final RxList<ShoppingItemDraft> draftItems = <ShoppingItemDraft>[].obs;
  final Rx<DateTime> shoppingDate = DateTime.now().obs;
  final Rx<TimeOfDay?> shoppingTime = Rx<TimeOfDay?>(null);
  final Rx<String?> selectedAccountId = Rx<String?>(null);
  final Rx<String?> selectedMemberId = Rx<String?>(null);

  // Direct Total Mode Form Fields
  final directTitleController = TextEditingController(text: 'দৈনিক বাজার');
  final directAmountController = TextEditingController();
  final directNoteController = TextEditingController();
  final Rx<String?> directCategoryId = Rx<String?>(null);

  // Search, Filter & Product Summary States
  final RxString searchQuery = ''.obs;
  final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);
  final RxInt selectedViewTab = 0.obs; // 0: History, 1: Product Summary
  final RxList<ProductSummaryItem> productSummaries = <ProductSummaryItem>[].obs;
  final RxMap<String, String> cachedShortSummaries = <String, String>{}.obs;
  final RxBool isSummaryLoading = false.obs;

  List<ShoppingRecord> get filteredShoppingRecords {
    final query = searchQuery.value.trim().toLowerCase();
    final range = selectedDateRange.value;

    return shoppingRecords.where((record) {
      if (range != null) {
        final startMs = range.start.millisecondsSinceEpoch;
        final endMs =
            range.end.add(const Duration(days: 1)).millisecondsSinceEpoch;
        if (record.shoppingDate < startMs || record.shoppingDate >= endMs) {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final storeMatches =
            record.storeName?.toLowerCase().contains(query) ?? false;
        final notesMatches =
            record.notes?.toLowerCase().contains(query) ?? false;
        final summaryMatches =
            cachedShortSummaries[record.id]?.toLowerCase().contains(query) ??
                false;
        if (!storeMatches && !notesMatches && !summaryMatches) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<String> getShortSummary(String recordId) async {
    if (cachedShortSummaries.containsKey(recordId)) {
      return cachedShortSummaries[recordId]!;
    }
    final items = await _dbService.householdDao.getItemsForRecord(recordId);
    if (items.isEmpty) {
      cachedShortSummaries[recordId] = 'শুধু মোট টাকা';
      return 'শুধু মোট টাকা';
    }
    final names = items.map((i) => i.productName).toList();
    String summary;
    if (names.length <= 3) {
      summary = names.join(', ');
    } else {
      summary = '${names.take(2).join(', ')} + আরও ${names.length - 2}টি';
    }
    cachedShortSummaries[recordId] = summary;
    return summary;
  }

  Future<void> loadProductSummaries() async {
    try {
      isSummaryLoading.value = true;
      final allItems = await _dbService.householdDao.getAllShoppingItems();

      final map = <String, _ProductAggregator>{};

      for (var item in allItems) {
        final key = '${item.productName.trim().toLowerCase()}__${item.unit}';
        if (!map.containsKey(key)) {
          map[key] = _ProductAggregator(
            displayName: item.productName.trim(),
            unit: item.unit,
            imagePath: item.imagePath,
          );
        }
        final agg = map[key]!;
        agg.totalQuantity += item.quantity;
        agg.totalAmountMinor += item.totalMinor;
        agg.purchaseCount += 1;
        if (agg.imagePath == null && item.imagePath != null) {
          agg.imagePath = item.imagePath;
        }
      }

      final list = map.values.map((agg) {
        return ProductSummaryItem(
          productName: agg.displayName,
          unit: agg.unit,
          totalQuantity: agg.totalQuantity,
          totalAmountMinor: agg.totalAmountMinor,
          purchaseCount: agg.purchaseCount,
          imagePath: agg.imagePath,
        );
      }).toList();

      list.sort((a, b) => b.totalAmountMinor.compareTo(a.totalAmountMinor));
      productSummaries.value = list;
    } finally {
      isSummaryLoading.value = false;
    }
  }

  Future<bool> deleteShoppingRecord(String recordId) async {
    try {
      await _dbService.householdDao.deleteShoppingRecordWithItems(recordId);
      cachedShortSummaries.remove(recordId);
      await loadProductSummaries();
      AppSnackbar.success('বাজারের হিসাব সফলভাবে মুছে ফেলা হয়েছে');
      return true;
    } catch (e) {
      AppSnackbar.error('মুছতে ব্যর্থ হয়েছে: $e');
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    watchData();
    addItemDraft();
    loadProductSummaries();
  }

  void watchData() {
    _dbService.householdDao.watchShoppingRecords().listen((records) {
      shoppingRecords.value = records;
      isLoading.value = false;
      loadProductSummaries();
    });

    _dbService.householdDao.watchShoppingLists().listen((lists) {
      shoppingLists.value = lists;
    });

    _dbService.coreDao.getAllAccounts().then((accounts) {
      if (accounts.isNotEmpty && selectedAccountId.value == null) {
        selectedAccountId.value = accounts.first.id;
      }
    });

    _dbService.coreDao.getAllCategories(type: 'expense').then((categories) {
      if (categories.isNotEmpty && directCategoryId.value == null) {
        final grocery = categories.firstWhereOrNull(
            (c) => c.nameEn.contains('Grocery') || c.nameBn.contains('বাজার'));
        directCategoryId.value = grocery?.id ?? categories.first.id;
      }
    });
  }

  // --- Cart Management ---
  void addToCart({
    required String name,
    double quantity = 1.0,
    String unit = 'kg',
    int unitPriceMinor = 0,
    int? lineTotalMinor,
    String? note,
    String? imagePath,
  }) {
    if (name.trim().isEmpty) return;

    final computedTotal = lineTotalMinor ??
        (unitPriceMinor > 0 ? (quantity * unitPriceMinor).round() : 0);

    final newItem = CartItem(
      productName: name.trim(),
      quantity: quantity,
      unit: unit,
      unitPriceMinor: unitPriceMinor,
      lineTotalMinor: computedTotal,
      note: note,
      imagePath: imagePath,
    );
    cartItems.add(newItem);
    cartItems.refresh();
  }

  void removeCartItem(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
      cartItems.refresh();
    }
  }

  void incrementQuantity(int index, [double step = 1.0]) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index].quantity.value += step;
      if (cartItems[index].unitPriceMinor.value > 0) {
        cartItems[index].lineTotalMinor.value =
            (cartItems[index].quantity.value *
                    cartItems[index].unitPriceMinor.value)
                .round();
      }
      cartItems.refresh();
    }
  }

  void decrementQuantity(int index, [double step = 1.0]) {
    if (index >= 0 && index < cartItems.length) {
      final current = cartItems[index].quantity.value;
      if (current > step) {
        cartItems[index].quantity.value -= step;
        if (cartItems[index].unitPriceMinor.value > 0) {
          cartItems[index].lineTotalMinor.value =
              (cartItems[index].quantity.value *
                      cartItems[index].unitPriceMinor.value)
                  .round();
        }
      } else {
        removeCartItem(index);
        return;
      }
      cartItems.refresh();
    }
  }

  void updateQuantity(int index, double newQty) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index].quantity.value = newQty > 0 ? newQty : 1.0;
      if (cartItems[index].unitPriceMinor.value > 0) {
        cartItems[index].lineTotalMinor.value =
            (cartItems[index].quantity.value *
                    cartItems[index].unitPriceMinor.value)
                .round();
      }
      cartItems.refresh();
    }
  }

  void updateUnitPrice(int index, int newPriceMinor) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index].unitPriceMinor.value =
          newPriceMinor >= 0 ? newPriceMinor : 0;
      cartItems[index].lineTotalMinor.value = (cartItems[index].quantity.value *
              cartItems[index].unitPriceMinor.value)
          .round();
      cartItems.refresh();
    }
  }

  void updateLineTotal(int index, int newLineTotalMinor) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index].lineTotalMinor.value =
          newLineTotalMinor >= 0 ? newLineTotalMinor : 0;
      if (cartItems[index].quantity.value > 0 &&
          cartItems[index].unitPriceMinor.value > 0) {
        cartItems[index].unitPriceMinor.value =
            (newLineTotalMinor / cartItems[index].quantity.value).round();
      }
      cartItems.refresh();
    }
  }

  void clearCart() {
    cartItems.clear();
  }

  // Legacy draft items
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
    if (entryMode.value == 'direct_total') {
      return CurrencyUtils.takaToMinor(directAmountController.text);
    }

    if (cartItems.isNotEmpty) {
      int sum = 0;
      for (var item in cartItems) {
        sum += item.subtotalMinor;
      }
      return sum;
    }
    int sum = 0;
    for (var item in draftItems) {
      sum += item.totalMinor;
    }
    return sum;
  }

  int get discountMinor {
    if (entryMode.value == 'direct_total') return 0;
    return CurrencyUtils.takaToMinor(discountController.text);
  }

  int get totalBillMinor {
    final total = subtotalMinor - discountMinor;
    return total < 0 ? 0 : total;
  }

  int get cartPaidMinor {
    if (entryMode.value == 'direct_total') return totalBillMinor;
    final text = paidController.text.trim();
    if (text.isEmpty) return totalBillMinor;
    return CurrencyUtils.takaToMinor(text);
  }

  int get cartDueMinor {
    final due = totalBillMinor - cartPaidMinor;
    return due < 0 ? 0 : due;
  }

  String? formatShoppingTime(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<bool> saveShoppingBill() async {
    final isDirectMode = entryMode.value == 'direct_total';

    if (isDirectMode) {
      final directAmountMinor =
          CurrencyUtils.takaToMinor(directAmountController.text);
      if (directAmountMinor <= 0) {
        AppSnackbar.error('অনুগ্রহ করে মোট খরচের পরিমাণ লিখুন');
        return false;
      }
    } else {
      final hasCartItems = cartItems.isNotEmpty;
      final hasDraftItems = draftItems.isNotEmpty &&
          draftItems.first.nameController.text.trim().isNotEmpty;

      if (!hasCartItems && !hasDraftItems) {
        AppSnackbar.error('অনুগ্রহ করে অন্তত একটি পণ্য যোগ করুন');
        return false;
      }
    }

    final total = totalBillMinor;
    final paid = isDirectMode
        ? total
        : (paidController.text.trim().isNotEmpty
            ? CurrencyUtils.takaToMinor(paidController.text)
            : total);
    final due = total - paid;

    final recordId = _uuid.v4();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final shoppingDateMs = shoppingDate.value.toUtc().millisecondsSinceEpoch;
    final formattedTime = formatShoppingTime(shoppingTime.value);

    final storeTitle = isDirectMode
        ? (directTitleController.text.trim().isNotEmpty
            ? directTitleController.text.trim()
            : 'দৈনিক বাজার')
        : (storeNameController.text.trim().isNotEmpty
            ? storeNameController.text.trim()
            : 'দৈনিক বাজার');

    final recordNote = isDirectMode
        ? directNoteController.text.trim()
        : notesController.text.trim();

    final record = ShoppingRecordsCompanion(
      id: Value(recordId),
      shoppingDate: Value(shoppingDateMs),
      storeName: Value(storeTitle),
      purchasedByMemberId: Value(selectedMemberId.value),
      subtotalMinor: Value(subtotalMinor),
      discountMinor: Value(discountMinor),
      totalMinor: Value(total),
      paidMinor: Value(paid),
      dueMinor: Value(due < 0 ? 0 : due),
      notes: Value(recordNote.isNotEmpty ? recordNote : null),
      purchaseTime: Value(formattedTime),
      entryMode: Value(isDirectMode ? 'direct_total' : 'itemized'),
      createdAt: Value(now),
    );

    final items = <ShoppingItemsCompanion>[];

    if (!isDirectMode) {
      if (cartItems.isNotEmpty) {
        for (var cartItem in cartItems) {
          items.add(
            ShoppingItemsCompanion(
              id: Value(_uuid.v4()),
              shoppingRecordId: Value(recordId),
              productName: Value(cartItem.productName),
              quantity: Value(cartItem.quantity.value),
              unit: Value(cartItem.unit),
              unitPriceMinor: Value(cartItem.unitPriceMinor.value),
              totalMinor: Value(cartItem.subtotalMinor),
              note: Value(cartItem.note.value),
              imagePath: Value(cartItem.imagePath.value),
            ),
          );
        }
      } else {
        for (var draft in draftItems) {
          if (draft.nameController.text.trim().isNotEmpty) {
            final qty = double.tryParse(draft.qtyController.text) ?? 1.0;
            final unitPriceMinor =
                CurrencyUtils.takaToMinor(draft.unitPriceController.text);
            items.add(
              ShoppingItemsCompanion(
                id: Value(_uuid.v4()),
                shoppingRecordId: Value(recordId),
                productName: Value(draft.nameController.text.trim()),
                quantity: Value(qty),
                unit: Value(draft.unit),
                unitPriceMinor: Value(unitPriceMinor),
                totalMinor: Value(draft.totalMinor),
                note: Value(draft.noteController.text.trim().isNotEmpty
                    ? draft.noteController.text.trim()
                    : null),
              ),
            );
          }
        }
      }
    }

    // Link directly to household expense without creating duplicate expense bills!
    TransactionsCompanion? expenseTx;
    List<TransactionEntriesCompanion>? journalEntries;

    if (paid > 0 && selectedAccountId.value != null) {
      final txId = _uuid.v4();
      final txNumber = 'SHOP-${now.toString().substring(5)}';

      // Find or assign Household Grocery category
      final categories =
          await _dbService.coreDao.getAllCategories(type: 'expense');
      final groceryCat = categories.firstWhereOrNull(
          (c) => c.nameEn.contains('Grocery') || c.nameBn.contains('বাজার'));
      final targetCatId = isDirectMode && directCategoryId.value != null
          ? directCategoryId.value
          : (groceryCat?.id ??
              (categories.isNotEmpty ? categories.first.id : null));

      expenseTx = TransactionsCompanion(
        id: Value(txId),
        transactionNumber: Value(txNumber),
        transactionType: const Value('expense'),
        scopeType: const Value('family'),
        familyMemberId: Value(selectedMemberId.value),
        categoryId: Value(targetCatId),
        accountId: Value(selectedAccountId.value),
        amountMinor: Value(paid),
        transactionDate: Value(shoppingDateMs),
        description: Value('বাজার খরচ: $storeTitle'),
        paymentStatus: Value(due > 0 ? 'partial' : 'paid'),
        purchaseTime: Value(formattedTime),
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
      AppSnackbar.error('বাজারের খরচ সংরক্ষণ ব্যর্থ: $e');
      return false;
    }
  }

  void resetForm() {
    storeNameController.clear();
    discountController.text = '0';
    paidController.clear();
    notesController.clear();
    directAmountController.clear();
    directNoteController.clear();
    shoppingTime.value = null;
    for (var draft in draftItems) {
      draft.dispose();
    }
    draftItems.clear();
    cartItems.clear();
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
    notesController.dispose();
    directTitleController.dispose();
    directAmountController.dispose();
    directNoteController.dispose();
    for (var draft in draftItems) {
      draft.dispose();
    }
    super.onClose();
  }
}
