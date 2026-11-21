import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';
import '../utils/receipt_printer.dart';

class SaleCartItem {
  final String? productId;
  final String productName;
  final String unit;
  final int purchasePriceMinor;
  final RxDouble quantity;
  final RxInt unitPriceMinor;

  SaleCartItem({
    this.productId,
    required this.productName,
    required this.unit,
    required this.purchasePriceMinor,
    required double quantity,
    required int unitPriceMinor,
  })  : quantity = quantity.obs,
        unitPriceMinor = unitPriceMinor.obs;

  int get totalMinor => (quantity.value * unitPriceMinor.value).round();
  int get totalCostMinor => (quantity.value * purchasePriceMinor).round();
}

class BusinessSaleController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final Rx<BusinessesData?> currentBusiness = Rx<BusinessesData?>(null);
  final RxList<Product> availableProducts = <Product>[].obs;
  final RxList<Customer> availableCustomers = <Customer>[].obs;
  final RxList<Account> availableAccounts = <Account>[].obs;

  // Sale Options
  final RxString saleType = 'retail'.obs; // retail, wholesale, quick_sale
  final Rx<Customer?> selectedCustomer = Rx<Customer?>(null);
  final Rx<Account?> selectedAccount = Rx<Account?>(null);
  final RxString paymentMethod = 'cash'.obs;

  // Cart
  final RxList<SaleCartItem> cartItems = <SaleCartItem>[].obs;

  // Real-time Date and Time Capture
  final Rx<DateTime> transactionDate = DateTime.now().obs;
  final Rx<TimeOfDay> transactionTime = TimeOfDay.now().obs;
  final RxBool isCustomDateTime = false.obs;

  // Pricing & Financials
  final discountController = TextEditingController(text: '0');
  final paidController = TextEditingController();
  final notesController = TextEditingController();
  final invoiceController = TextEditingController();

  // Quick Sale Item Dialog Controllers
  final quickItemNameController = TextEditingController();
  final quickItemQtyController = TextEditingController(text: '1');
  final quickItemPriceController = TextEditingController();
  final quickItemCostController = TextEditingController();
  final RxString quickItemUnit = 'piece'.obs;

  // Barcode / Search
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async {
    final businesses = await _dbService.businessDao.getAllBusinesses();
    if (businesses.isNotEmpty) {
      currentBusiness.value = businesses.first;
      await loadProductsAndCustomers(currentBusiness.value!.id);
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
        'INV-${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  Future<void> loadProductsAndCustomers(String businessId) async {
    final prods = await _dbService.inventoryDao.getAllProducts(businessId);
    availableProducts.value = prods;

    final custs = await _dbService.businessDao.getAllCustomers(businessId);
    availableCustomers.value = custs;
  }

  int get subtotalMinor =>
      cartItems.fold<int>(0, (sum, item) => sum + item.totalMinor);

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

  void setSaleType(String type) {
    saleType.value = type;
    // Re-evaluate tiered / wholesale prices for all items in cart
    for (var item in cartItems) {
      if (item.productId != null) {
        _recalculateItemPrice(item);
      }
    }
  }

  Future<void> addProductToCart(Product product, {double qty = 1.0}) async {
    // Check if item already exists in cart
    final existing =
        cartItems.firstWhereOrNull((item) => item.productId == product.id);
    if (existing != null) {
      existing.quantity.value += qty;
      await _recalculateItemPrice(existing);
      cartItems.refresh();
      return;
    }

    // Determine initial price based on saleType
    final isWholesale = saleType.value == 'wholesale';
    final price = await _dbService.inventoryDao.getProductPriceForQuantity(
      product.id,
      qty,
      isWholesale: isWholesale,
    );

    final cartItem = SaleCartItem(
      productId: product.id,
      productName: product.name,
      unit: product.unit,
      purchasePriceMinor: product.purchasePriceMinor,
      quantity: qty,
      unitPriceMinor: price,
    );

    cartItems.add(cartItem);
    _syncPaidField();
  }

  void addQuickSaleItem() {
    final name = quickItemNameController.text.trim();
    if (name.isEmpty) {
      AppSnackbar.error('পণ্যের নাম লিখুন');
      return;
    }
    final qty = double.tryParse(quickItemQtyController.text) ?? 1.0;
    final priceMinor =
        CurrencyUtils.takaToMinor(quickItemPriceController.text);
    final costMinor =
        CurrencyUtils.takaToMinor(quickItemCostController.text);

    final item = SaleCartItem(
      productId: null,
      productName: name,
      unit: quickItemUnit.value,
      purchasePriceMinor: costMinor,
      quantity: qty,
      unitPriceMinor: priceMinor,
    );

    cartItems.add(item);
    _syncPaidField();

    quickItemNameController.clear();
    quickItemQtyController.text = '1';
    quickItemPriceController.clear();
    quickItemCostController.clear();
    Get.back(); // close dialog
  }

  Future<void> updateItemQuantity(SaleCartItem item, double newQty) async {
    if (newQty <= 0) {
      cartItems.remove(item);
    } else {
      item.quantity.value = newQty;
      if (item.productId != null) {
        await _recalculateItemPrice(item);
      }
    }
    cartItems.refresh();
    _syncPaidField();
  }

  Future<void> _recalculateItemPrice(SaleCartItem item) async {
    if (item.productId == null) return;
    final isWholesale = saleType.value == 'wholesale';
    final price = await _dbService.inventoryDao.getProductPriceForQuantity(
      item.productId!,
      item.quantity.value,
      isWholesale: isWholesale,
    );
    item.unitPriceMinor.value = price;
  }

  void removeItem(SaleCartItem item) {
    cartItems.remove(item);
    _syncPaidField();
  }

  void clearCart() {
    cartItems.clear();
    discountController.text = '0';
    paidController.clear();
    notesController.clear();
    selectedCustomer.value = null;
    _generateInvoiceNumber();
  }

  void _syncPaidField() {
    paidController.text = CurrencyUtils.minorToTaka(totalMinor).toStringAsFixed(2);
  }

  Future<void> onScanBarcode(String barcode) async {
    if (currentBusiness.value == null) return;
    final product = await _dbService.inventoryDao.getProductByBarcode(
      currentBusiness.value!.id,
      barcode.trim(),
    );
    if (product != null) {
      await addProductToCart(product);
      AppSnackbar.success('${product.name} যুক্ত হয়েছে');
    } else {
      AppSnackbar.warning('বারকোডের পণ্যটি পাওয়া যায়নি: $barcode');
    }
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

  Future<bool> processSale({bool printReceipt = false}) async {
    if (currentBusiness.value == null) {
      AppSnackbar.error('ব্যবসা নির্বাচন করা নেই');
      return false;
    }
    if (cartItems.isEmpty) {
      AppSnackbar.error('কার্ট খালি! পণ্য যোগ করুন');
      return false;
    }

    final biz = currentBusiness.value!;

    // Credit limit check
    if (dueMinor > 0 && selectedCustomer.value != null) {
      final cust = selectedCustomer.value!;
      if (cust.creditLimitMinor > 0) {
        final currentDue =
            await _dbService.businessDao.getCustomerOutstandingDue(cust.id);
        if (currentDue + dueMinor > cust.creditLimitMinor) {
          AppSnackbar.warning(
              'সতর্কতা: গ্রাহকের বাকি সীমা (${CurrencyUtils.format(cust.creditLimitMinor)}) অতিক্রম করছে!');
        }
      }
    }

    // Negative stock check
    if (biz.allowNegativeStock == 0) {
      for (var item in cartItems) {
        if (item.productId != null) {
          final stock =
              await _dbService.inventoryDao.getProductCurrentStock(item.productId!);
          if (stock < item.quantity.value) {
            AppSnackbar.error(
                'পর্যাপ্ত স্টক নেই: ${item.productName} (বর্তমান স্টক: $stock ${item.unit})');
            return false;
          }
        }
      }
    }

    final saleId = _uuid.v4();
    final nowAudit = DateTime.now().millisecondsSinceEpoch;

    // Use custom or device date/time
    final sDate = DateTime(
      transactionDate.value.year,
      transactionDate.value.month,
      transactionDate.value.day,
      transactionTime.value.hour,
      transactionTime.value.minute,
    ).millisecondsSinceEpoch;

    final timeStr =
        '${transactionTime.value.hour.toString().padLeft(2, '0')}:${transactionTime.value.minute.toString().padLeft(2, '0')}';

    final saleRecord = SalesRecordsCompanion(
      id: Value(saleId),
      businessId: Value(biz.id),
      customerId: Value(selectedCustomer.value?.id),
      saleDate: Value(sDate),
      saleTime: Value(timeStr),
      isCustomDateTime: Value(isCustomDateTime.value ? 1 : 0),
      invoiceNumber: Value(invoiceController.text.trim()),
      saleType: Value(saleType.value),
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

    final itemsCompanionList = <SalesItemsCompanion>[];
    final movementsCompanionList = <InventoryMovementsCompanion>[];

    for (var item in cartItems) {
      final itemId = _uuid.v4();
      itemsCompanionList.add(
        SalesItemsCompanion(
          id: Value(itemId),
          saleId: Value(saleId),
          productId: Value(item.productId),
          productName: Value(item.productName),
          unit: Value(item.unit),
          quantity: Value(item.quantity.value),
          unitPriceMinor: Value(item.unitPriceMinor.value),
          unitCostMinor: Value(item.purchasePriceMinor),
          totalMinor: Value(item.totalMinor),
        ),
      );

      if (item.productId != null) {
        movementsCompanionList.add(
          InventoryMovementsCompanion(
            id: Value(_uuid.v4()),
            productId: Value(item.productId!),
            businessId: Value(biz.id),
            movementType: const Value('sale'),
            quantity: Value(item.quantity.value),
            unitCostMinor: Value(item.purchasePriceMinor),
            referenceType: const Value('sale'),
            referenceId: Value(saleId),
            movementDate: Value(sDate),
            notes: Value('বিক্রয় ইনভয়েস: ${invoiceController.text.trim()}'),
          ),
        );
      }
    }

    try {
      await _dbService.inventoryDao.postSaleWithItems(
        sale: saleRecord,
        items: itemsCompanionList,
        movements: movementsCompanionList,
        accountId: selectedAccount.value?.id,
      );

      AppSnackbar.success('বিক্রয় সফলভাবে সম্পন্ন হয়েছে!');

      if (printReceipt) {
        final savedItems = await _dbService.businessDao.getSaleItems(saleId);
        final saleData = (await _dbService.businessDao.getSales(biz.id))
            .firstWhere((s) => s.id == saleId);
        await ReceiptPrinter.printSaleReceipt(
          business: biz,
          sale: saleData,
          items: savedItems,
          customerName: selectedCustomer.value?.name,
          format: ReceiptFormat.thermal80,
        );
      }

      clearCart();
      return true;
    } catch (e) {
      AppSnackbar.error('বিক্রয় সংরক্ষণ ব্যর্থ: $e');
      return false;
    }
  }

  @override
  void onClose() {
    discountController.dispose();
    paidController.dispose();
    notesController.dispose();
    invoiceController.dispose();
    quickItemNameController.dispose();
    quickItemQtyController.dispose();
    quickItemPriceController.dispose();
    quickItemCostController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
