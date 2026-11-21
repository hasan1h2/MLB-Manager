import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class PurchaseCartItem {
  final String productId;
  final String productName;
  final String unit;
  final RxDouble quantity;
  final RxInt unitCostMinor;

  PurchaseCartItem({
    required this.productId,
    required this.productName,
    required this.unit,
    required double quantity,
    required int unitCostMinor,
  })  : quantity = quantity.obs,
        unitCostMinor = unitCostMinor.obs;

  int get totalMinor => (quantity.value * unitCostMinor.value).round();
}

class BusinessPurchaseController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final Rx<BusinessesData?> currentBusiness = Rx<BusinessesData?>(null);
  final RxList<Product> availableProducts = <Product>[].obs;
  final RxList<Supplier> availableSuppliers = <Supplier>[].obs;
  final RxList<Account> availableAccounts = <Account>[].obs;

  // Selected Options
  final Rx<Supplier?> selectedSupplier = Rx<Supplier?>(null);
  final Rx<Account?> selectedAccount = Rx<Account?>(null);
  final RxString paymentMethod = 'cash'.obs;

  // Items
  final RxList<PurchaseCartItem> items = <PurchaseCartItem>[].obs;

  // Real-time Date and Time Capture
  final Rx<DateTime> transactionDate = DateTime.now().obs;
  final Rx<TimeOfDay> transactionTime = TimeOfDay.now().obs;
  final RxBool isCustomDateTime = false.obs;

  // Financials
  final discountController = TextEditingController(text: '0');
  final paidController = TextEditingController();
  final notesController = TextEditingController();
  final invoiceController = TextEditingController();

  // Add Item Dialog / Form
  final Rx<Product?> selectedProductToAdd = Rx<Product?>(null);
  final qtyController = TextEditingController(text: '1');
  final unitCostController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async {
    final businesses = await _dbService.businessDao.getAllBusinesses();
    if (businesses.isNotEmpty) {
      currentBusiness.value = businesses.first;
      await loadProductsAndSuppliers(currentBusiness.value!.id);
    }
    final accounts = await _dbService.coreDao.getAllAccounts();
    availableAccounts.value = accounts;
    if (accounts.isNotEmpty) {
      selectedAccount.value = accounts.first;
    }
    _generateInvoiceNumber();
  }

  void _generateInvoiceNumber() {
    final now = DateTime.now();
    invoiceController.text =
        'PUR-${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  Future<void> loadProductsAndSuppliers(String businessId) async {
    final prods = await _dbService.inventoryDao.getAllProducts(businessId);
    availableProducts.value = prods;

    final supps = await _dbService.businessDao.getAllSuppliers(businessId);
    availableSuppliers.value = supps;
  }

  int get subtotalMinor =>
      items.fold<int>(0, (sum, item) => sum + item.totalMinor);

  int get discountMinor => CurrencyUtils.takaToMinor(discountController.text);

  int get totalMinor {
    final t = subtotalMinor - discountMinor;
    return t > 0 ? t : 0;
  }

  int get paidMinor {
    if (paidController.text.trim().isEmpty) return totalMinor;
    return CurrencyUtils.takaToMinor(paidController.text);
  }

  int get dueMinor {
    final d = totalMinor - paidMinor;
    return d > 0 ? d : 0;
  }

  void addItem() {
    if (selectedProductToAdd.value == null) {
      AppSnackbar.error('পণ্য নির্বাচন করুন');
      return;
    }
    final prod = selectedProductToAdd.value!;
    final qty = double.tryParse(qtyController.text) ?? 1.0;
    final costMinor = unitCostController.text.trim().isNotEmpty
        ? CurrencyUtils.takaToMinor(unitCostController.text)
        : prod.purchasePriceMinor;

    final existing = items.firstWhereOrNull((i) => i.productId == prod.id);
    if (existing != null) {
      existing.quantity.value += qty;
      existing.unitCostMinor.value = costMinor;
      items.refresh();
    } else {
      items.add(PurchaseCartItem(
        productId: prod.id,
        productName: prod.name,
        unit: prod.unit,
        quantity: qty,
        unitCostMinor: costMinor,
      ));
    }

    _syncPaidField();
    selectedProductToAdd.value = null;
    qtyController.text = '1';
    unitCostController.clear();
    Get.back();
  }

  void removeItem(PurchaseCartItem item) {
    items.remove(item);
    _syncPaidField();
  }

  void _syncPaidField() {
    paidController.text =
        CurrencyUtils.minorToTaka(totalMinor).toStringAsFixed(2);
  }

  void setCustomDateTime(DateTime date, TimeOfDay time) {
    transactionDate.value = date;
    transactionTime.value = time;
    isCustomDateTime.value = true;
  }

  void resetToDeviceDateTime() {
    transactionDate.value = DateTime.now();
    transactionTime.value = TimeOfDay.now();
    isCustomDateTime.value = false;
  }

  Future<bool> savePurchase() async {
    if (currentBusiness.value == null) {
      AppSnackbar.error('ব্যবসা নির্বাচন করা নেই');
      return false;
    }
    if (items.isEmpty) {
      AppSnackbar.error('ক্রয়ের পণ্য যোগ করুন');
      return false;
    }

    final biz = currentBusiness.value!;
    final purchaseId = _uuid.v4();
    final nowAudit = DateTime.now().millisecondsSinceEpoch;

    final pDate = DateTime(
      transactionDate.value.year,
      transactionDate.value.month,
      transactionDate.value.day,
      transactionTime.value.hour,
      transactionTime.value.minute,
    ).millisecondsSinceEpoch;

    final timeStr =
        '${transactionTime.value.hour.toString().padLeft(2, '0')}:${transactionTime.value.minute.toString().padLeft(2, '0')}';

    final purchaseRecord = PurchaseRecordsCompanion(
      id: Value(purchaseId),
      businessId: Value(biz.id),
      supplierId: Value(selectedSupplier.value?.id),
      purchaseDate: Value(pDate),
      purchaseTime: Value(timeStr),
      isCustomDateTime: Value(isCustomDateTime.value ? 1 : 0),
      invoiceNumber: Value(invoiceController.text.trim()),
      paymentMethod: Value(paymentMethod.value),
      notes: Value(notesController.text.trim().isNotEmpty
          ? notesController.text.trim()
          : null),
      subtotalMinor: Value(subtotalMinor),
      discountMinor: Value(discountMinor),
      totalMinor: Value(totalMinor),
      paidMinor: Value(paidMinor),
      dueMinor: Value(dueMinor),
      createdAt: Value(nowAudit),
      updatedAt: Value(nowAudit),
    );

    final itemsCompanionList = <PurchaseItemsCompanion>[];
    final movementsCompanionList = <InventoryMovementsCompanion>[];

    for (var item in items) {
      final itemId = _uuid.v4();
      itemsCompanionList.add(
        PurchaseItemsCompanion(
          id: Value(itemId),
          purchaseId: Value(purchaseId),
          productId: Value(item.productId),
          productName: Value(item.productName),
          unit: Value(item.unit),
          quantity: Value(item.quantity.value),
          unitCostMinor: Value(item.unitCostMinor.value),
          totalMinor: Value(item.totalMinor),
        ),
      );

      movementsCompanionList.add(
        InventoryMovementsCompanion(
          id: Value(_uuid.v4()),
          productId: Value(item.productId),
          businessId: Value(biz.id),
          movementType: const Value('purchase'),
          quantity: Value(item.quantity.value),
          unitCostMinor: Value(item.unitCostMinor.value),
          referenceType: const Value('purchase'),
          referenceId: Value(purchaseId),
          movementDate: Value(pDate),
          notes: Value('ক্রয় মেমো: ${invoiceController.text.trim()}'),
        ),
      );
    }

    try {
      await _dbService.inventoryDao.postPurchaseWithItems(
        purchase: purchaseRecord,
        items: itemsCompanionList,
        movements: movementsCompanionList,
        accountId: selectedAccount.value?.id,
      );

      AppSnackbar.success('ক্রয় সফলভাবে সংরক্ষিত হয়েছে!');
      items.clear();
      discountController.text = '0';
      paidController.clear();
      notesController.clear();
      selectedSupplier.value = null;
      _generateInvoiceNumber();
      return true;
    } catch (e) {
      AppSnackbar.error('ক্রয় সংরক্ষণ ব্যর্থ: $e');
      return false;
    }
  }

  @override
  void onClose() {
    discountController.dispose();
    paidController.dispose();
    notesController.dispose();
    invoiceController.dispose();
    qtyController.dispose();
    unitCostController.dispose();
    super.onClose();
  }
}
