import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/active_business_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/unit_conversion_utils.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../utils/receipt_printer.dart';

class SaleCartItem {
  final String? productId;
  final String productName;
  final String baseUnit;
  final RxString unit;
  final String? packageUnit;
  final double? packageQuantity;
  final RxDouble conversionFactor;
  final RxDouble quantity;
  final int purchasePriceMinor;
  final RxInt unitPriceMinor;

  SaleCartItem({
    this.productId,
    required this.productName,
    required this.baseUnit,
    required String unit,
    this.packageUnit,
    this.packageQuantity,
    required double conversionFactor,
    required double quantity,
    required this.purchasePriceMinor,
    required int unitPriceMinor,
  })  : unit = unit.obs,
        conversionFactor = conversionFactor.obs,
        quantity = quantity.obs,
        unitPriceMinor = unitPriceMinor.obs;

  double get baseQuantity => quantity.value * conversionFactor.value;
  int get totalMinor => (quantity.value * unitPriceMinor.value).round();
  int get totalCostMinor => (baseQuantity * purchasePriceMinor).round();
}

class BusinessSaleController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ActiveBusinessService _activeBizService = Get.find<ActiveBusinessService>();
  final _uuid = const Uuid();

  final Rx<BusinessesData?> currentBusiness = Rx<BusinessesData?>(null);
  final RxList<Product> availableProducts = <Product>[].obs;
  final RxList<Category> availableCategories = <Category>[].obs;
  final RxMap<String, double> productStockMap = <String, double>{}.obs;
  final RxList<Customer> availableCustomers = <Customer>[].obs;
  final RxList<Account> availableAccounts = <Account>[].obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isProcessing = false.obs;

  // Search & Filter
  final RxString searchQuery = ''.obs;
  final Rx<String?> selectedCategoryId = Rx<String?>(null);
  final RxInt activeTabIndex = 0.obs; // 0: Catalog, 1: Cart/Checkout

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

  // Quick Sale Item Dialog Controllers & State
  final quickItemNameController = TextEditingController();
  final quickItemQtyController = TextEditingController(text: '1');
  final quickItemPriceController = TextEditingController();
  final quickItemCostController = TextEditingController();
  final RxString quickItemUnit = 'piece'.obs;
  final Rx<Product?> selectedQuickProduct = Rx<Product?>(null);
  final RxList<Product> quickProductSuggestions = <Product>[].obs;
  final RxList<String> quickAvailableUnits = <String>[
    'piece',
    'packet',
    'kg',
    'g',
    'liter',
    'ml',
    'box',
    'carton',
    'dozen',
    'bottle',
    'bag',
    'sack',
    'pair',
  ].obs;

  // Barcode / Search
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Bind to ActiveBusinessService
    currentBusiness.value = _activeBizService.activeBusiness.value;
    ever(_activeBizService.activeBusiness, (BusinessesData? biz) {
      if (biz?.id != currentBusiness.value?.id) {
        currentBusiness.value = biz;
        clearCart();
        if (biz != null) {
          loadProductsAndCustomers(biz.id);
        } else {
          availableProducts.clear();
          availableCategories.clear();
          productStockMap.clear();
          availableCustomers.clear();
        }
      }
    });

    initData();
  }

  Future<void> initData() async {
    final biz = _activeBizService.activeBusiness.value ??
        (await _dbService.businessDao.getAllBusinesses()).firstOrNull;
    if (biz != null) {
      currentBusiness.value = biz;
      await loadProductsAndCustomers(biz.id);
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
    try {
      isLoadingProducts.value = true;
      final prods = await _dbService.inventoryDao.getAllProducts(businessId);
      availableProducts.value = prods;

      final cats =
          await _dbService.coreDao.getProductCategories(businessId: businessId);
      availableCategories.value = cats;

      final custs = await _dbService.businessDao.getAllCustomers(businessId);
      availableCustomers.value = custs;

      final Map<String, double> stockMap = {};
      for (final p in prods) {
        final stock = await _dbService.inventoryDao.getProductCurrentStock(p.id);
        stockMap[p.id] = stock;
      }
      productStockMap.value = stockMap;
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void selectCategory(String? categoryId) {
    if (selectedCategoryId.value == categoryId) {
      selectedCategoryId.value = null;
    } else {
      selectedCategoryId.value = categoryId;
    }
  }

  List<Product> get filteredProducts {
    var list = availableProducts.toList();
    if (selectedCategoryId.value != null) {
      list = list.where((p) => p.categoryId == selectedCategoryId.value).toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) {
        final nameMatch = p.name.toLowerCase().contains(q);
        final bnMatch = (p.nameBn ?? '').toLowerCase().contains(q);
        final skuMatch = (p.sku ?? '').toLowerCase().contains(q);
        final barcodeMatch = (p.barcode ?? '').toLowerCase().contains(q);
        return nameMatch || bnMatch || skuMatch || barcodeMatch;
      }).toList();
    }
    return list;
  }

  double getProductStock(String productId) => productStockMap[productId] ?? 0.0;

  SaleCartItem? getCartItemForProduct(String productId) {
    return cartItems.firstWhereOrNull((item) => item.productId == productId);
  }

  int get cartItemCount => cartItems.length;

  double get cartTotalQuantity =>
      cartItems.fold(0.0, (sum, i) => sum + i.quantity.value);

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

  Future<void> addProductToCart(
    Product product, {
    double qty = 1.0,
    String? selectedUnit,
    int? customUnitPriceMinor,
  }) async {
    final unitToUse = selectedUnit ?? product.unit;
    final factor = UnitConversionUtils.getConversionFactor(
      fromUnit: unitToUse,
      toBaseUnit: product.unit,
      packageUnit: product.packageUnit,
      packageQuantity: product.packageQuantity,
    );
    final neededBaseQty = qty * factor;

    // Check if item already exists in cart with same unit
    final existing = cartItems.firstWhereOrNull(
        (item) => item.productId == product.id && item.unit.value == unitToUse);
    if (existing != null) {
      await updateItemQuantity(existing, existing.quantity.value + qty);
      AppSnackbar.success('কার্টে পণ্য যোগ করা হয়েছে!');
      return;
    }

    // Check stock if negative stock is disallowed
    final biz = currentBusiness.value;
    if (biz != null && biz.allowNegativeStock == 0) {
      final currentStock = getProductStock(product.id);
      if (currentStock < neededBaseQty) {
        AppSnackbar.warning(
            'পর্যাপ্ত স্টক নেই: ${product.nameBn ?? product.name} (বর্তমান স্টক: $currentStock ${product.unit})');
        return;
      }
    }

    // Determine initial price based on saleType
    final isWholesale = saleType.value == 'wholesale';
    final basePrice = await _dbService.inventoryDao.getProductPriceForQuantity(
      product.id,
      neededBaseQty,
      isWholesale: isWholesale,
    );

    final effectiveUnitPriceMinor = customUnitPriceMinor ??
        (factor == 1.0 ? basePrice : (factor * basePrice).round());

    final cartItem = SaleCartItem(
      productId: product.id,
      productName: product.nameBn ?? product.name,
      baseUnit: product.unit,
      unit: unitToUse,
      packageUnit: product.packageUnit,
      packageQuantity: product.packageQuantity,
      conversionFactor: factor,
      purchasePriceMinor: product.purchasePriceMinor,
      quantity: qty,
      unitPriceMinor: effectiveUnitPriceMinor,
    );

    cartItems.add(cartItem);
    _syncPaidField();
    AppSnackbar.success('কার্টে পণ্য যোগ করা হয়েছে!');
  }

  Future<void> changeCartItemUnit(SaleCartItem item, String newUnit) async {
    if (item.productId == null) {
      item.unit.value = newUnit;
      return;
    }
    final product =
        availableProducts.firstWhereOrNull((p) => p.id == item.productId);
    if (product == null) return;

    final newFactor = UnitConversionUtils.getConversionFactor(
      fromUnit: newUnit,
      toBaseUnit: item.baseUnit,
      packageUnit: item.packageUnit,
      packageQuantity: item.packageQuantity,
    );

    final isWholesale = saleType.value == 'wholesale';
    final basePrice = await _dbService.inventoryDao.getProductPriceForQuantity(
      product.id,
      item.quantity.value * newFactor,
      isWholesale: isWholesale,
    );

    item.unit.value = newUnit;
    item.conversionFactor.value = newFactor;
    item.unitPriceMinor.value = (newFactor * basePrice).round();

    cartItems.refresh();
    _syncPaidField();
  }

  void onQuickItemNameChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      quickProductSuggestions.clear();
      return;
    }
    final bizId = currentBusiness.value?.id;
    final matches = availableProducts.where((p) {
      if (bizId != null && p.businessId != bizId) return false;
      if (p.isActive != 1) return false;
      final nameMatch = p.name.toLowerCase().contains(q);
      final bnMatch = (p.nameBn ?? '').toLowerCase().contains(q);
      final enMatch = (p.nameEn ?? '').toLowerCase().contains(q);
      final skuMatch = (p.sku ?? '').toLowerCase().contains(q);
      final barcodeMatch = (p.barcode ?? '').toLowerCase().contains(q);
      return nameMatch || bnMatch || enMatch || skuMatch || barcodeMatch;
    }).take(8).toList();

    quickProductSuggestions.value = matches;

    if (selectedQuickProduct.value != null) {
      final cur = selectedQuickProduct.value!;
      final curName = (cur.nameBn ?? cur.name).toLowerCase();
      if (!curName.contains(q)) {
        selectedQuickProduct.value = null;
      }
    }
  }

  void selectQuickProduct(Product product) {
    selectedQuickProduct.value = product;
    quickItemNameController.text = product.nameBn ?? product.name;
    quickItemUnit.value = product.unit;

    quickAvailableUnits.value = UnitConversionUtils.getAvailableUnitsForProduct(
      baseUnit: product.unit,
      packageUnit: product.packageUnit,
    );

    final isWholesale = saleType.value == 'wholesale';
    final price = (isWholesale && product.wholesalePriceMinor > 0)
        ? product.wholesalePriceMinor
        : product.sellingPriceMinor;
    final priceTaka = CurrencyUtils.minorToTaka(price);
    quickItemPriceController.text =
        priceTaka % 1 == 0 ? priceTaka.toInt().toString() : priceTaka.toStringAsFixed(2);
    final costTaka = CurrencyUtils.minorToTaka(product.purchasePriceMinor);
    quickItemCostController.text =
        costTaka % 1 == 0 ? costTaka.toInt().toString() : costTaka.toStringAsFixed(2);

    quickProductSuggestions.clear();
  }

  void clearQuickSaleForm() {
    selectedQuickProduct.value = null;
    quickProductSuggestions.clear();
    quickItemNameController.clear();
    quickItemQtyController.text = '1';
    quickItemPriceController.clear();
    quickItemCostController.clear();
    quickItemUnit.value = 'piece';
  }

  Future<void> addQuickSaleItem() async {
    final name = quickItemNameController.text.trim();
    if (name.isEmpty) {
      AppSnackbar.validation('পণ্যের নাম লিখুন');
      return;
    }
    final qty = double.tryParse(quickItemQtyController.text) ?? 1.0;
    if (qty <= 0) {
      AppSnackbar.validation('পরিমাণ অবশ্যই শূন্যের বেশি হতে হবে');
      return;
    }

    final priceMinor =
        CurrencyUtils.takaToMinor(quickItemPriceController.text);
    final costMinor =
        CurrencyUtils.takaToMinor(quickItemCostController.text);
    final unit = quickItemUnit.value;
    final biz = currentBusiness.value;

    if (biz == null) {
      AppSnackbar.error('কোন সক্রিয় ব্যবসা নির্বাচন করা নেই');
      return;
    }

    Product? targetProduct = selectedQuickProduct.value;

    // If not explicitly selected from suggestions, search if product already exists
    if (targetProduct == null) {
      final q = name.toLowerCase();
      targetProduct = availableProducts.firstWhereOrNull((p) {
        if (p.businessId != biz.id || p.isActive != 1) return false;
        final pName = p.name.trim().toLowerCase();
        final pNameBn = (p.nameBn ?? '').trim().toLowerCase();
        final pNameEn = (p.nameEn ?? '').trim().toLowerCase();
        final pSku = (p.sku ?? '').trim().toLowerCase();
        return pName == q || pNameBn == q || pNameEn == q || (pSku.isNotEmpty && pSku == q);
      });
    }

    // If product does not exist, create a new inventory record with real ID
    if (targetProduct == null) {
      final newId = _uuid.v4();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final newCompanion = ProductsCompanion(
        id: Value(newId),
        businessId: Value(biz.id),
        name: Value(name),
        nameBn: Value(name),
        unit: Value(unit),
        purchasePriceMinor: Value(costMinor),
        sellingPriceMinor: Value(priceMinor),
        wholesalePriceMinor: Value(priceMinor),
        openingQuantity: const Value(0.0),
        minimumStock: const Value(5.0),
        isActive: const Value(1),
        createdAt: Value(now),
      );

      await _dbService.inventoryDao.insertProduct(newCompanion);
      await loadProductsAndCustomers(biz.id);
      targetProduct = availableProducts.firstWhereOrNull((p) => p.id == newId);
    }

    if (targetProduct == null) {
      AppSnackbar.error('পণ্য যুক্ত করতে সমস্যা হয়েছে');
      return;
    }

    // Add to cart with original/created product and its actual ID
    await addProductToCart(
      targetProduct,
      qty: qty,
      selectedUnit: unit,
      customUnitPriceMinor: priceMinor > 0 ? priceMinor : null,
    );

    clearQuickSaleForm();
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  Future<void> updateItemQuantity(SaleCartItem item, double newQty) async {
    if (newQty <= 0) {
      cartItems.remove(item);
    } else {
      // Stock check in base stock units
      final biz = currentBusiness.value;
      if (biz != null &&
          biz.allowNegativeStock == 0 &&
          item.productId != null) {
        final currentStock = getProductStock(item.productId!);
        final neededBaseQty = newQty * item.conversionFactor.value;
        if (currentStock < neededBaseQty) {
          AppSnackbar.warning(
              'পর্যাপ্ত স্টক নেই: ${item.productName} (বর্তমান স্টক: $currentStock ${item.baseUnit})');
          return;
        }
      }

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
    final basePrice = await _dbService.inventoryDao.getProductPriceForQuantity(
      item.productId!,
      item.baseQuantity,
      isWholesale: isWholesale,
    );
    item.unitPriceMinor.value = (item.conversionFactor.value * basePrice).round();
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
      AppSnackbar.success('${product.nameBn ?? product.name} যুক্ত হয়েছে');
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
    if (isProcessing.value) return false;
    isProcessing.value = true;

    try {
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

      // Negative stock check in base units
      if (biz.allowNegativeStock == 0) {
        for (var item in cartItems) {
          if (item.productId != null) {
            final stock =
                await _dbService.inventoryDao.getProductCurrentStock(item.productId!);
            if (stock < item.baseQuantity) {
              AppSnackbar.error(
                  'পর্যাপ্ত স্টক নেই: ${item.productName} (বর্তমান স্টক: $stock ${item.baseUnit})');
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
            unit: Value(item.unit.value),
            quantity: Value(item.quantity.value),
            conversionFactor: Value(item.conversionFactor.value),
            baseQuantity: Value(item.baseQuantity),
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
              movementType: Value(
                  saleType.value == 'wholesale' ? 'wholesale_sale' : 'sale'),
              quantity: Value(item.baseQuantity),
              unitCostMinor: Value(item.purchasePriceMinor),
              referenceType: const Value('sale'),
              referenceId: Value(saleId),
              movementDate: Value(sDate),
              notes: Value(
                  'বিক্রয় ইনভয়েস: ${invoiceController.text.trim()} (${item.quantity.value} ${item.unit.value})'),
            ),
          );
        }
      }

      await _dbService.inventoryDao.postSaleWithItems(
        sale: saleRecord,
        items: itemsCompanionList,
        movements: movementsCompanionList,
        accountId: selectedAccount.value?.id,
      );

      // Refresh local stock map
      for (var item in cartItems) {
        if (item.productId != null) {
          final updatedStock =
              await _dbService.inventoryDao.getProductCurrentStock(item.productId!);
          productStockMap[item.productId!] = updatedStock;
        }
      }

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
      activeTabIndex.value = 0; // Return to catalog
      return true;
    } catch (e) {
      AppSnackbar.error('বিক্রয় সংরক্ষণ ব্যর্থ: $e');
      return false;
    } finally {
      isProcessing.value = false;
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
