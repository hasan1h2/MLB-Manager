import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/constants/product_templates.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/active_business_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/unit_conversion_utils.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class PurchaseCartItem {
  final String productId;
  final String productName;
  final String? categoryId;
  final String? categoryName;
  final String? subcategoryId;
  final String baseUnit;
  final String unit;
  final String? packageUnit;
  final double? packageQuantity;
  final double conversionFactor;
  final RxDouble quantity;
  final RxInt unitCostMinor;
  final int retailPriceMinor;
  final int wholesalePriceMinor;

  PurchaseCartItem({
    required this.productId,
    required this.productName,
    this.categoryId,
    this.categoryName,
    this.subcategoryId,
    required this.baseUnit,
    required this.unit,
    this.packageUnit,
    this.packageQuantity,
    required this.conversionFactor,
    required double quantity,
    required int unitCostMinor,
    this.retailPriceMinor = 0,
    this.wholesalePriceMinor = 0,
  })  : quantity = quantity.obs,
        unitCostMinor = unitCostMinor.obs;

  double get baseQuantity => quantity.value * conversionFactor;
  int get totalMinor => (quantity.value * unitCostMinor.value).round();
}

class BusinessPurchaseController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ActiveBusinessService _activeBizService = Get.find<ActiveBusinessService>();
  final _uuid = const Uuid();

  Rx<BusinessesData?> get currentBusiness => _activeBizService.activeBusiness;
  final RxList<Product> availableProducts = <Product>[].obs;
  final RxList<Category> availableCategories = <Category>[].obs;
  final RxList<Category> availableSubcategories = <Category>[].obs;
  final RxList<Supplier> availableSuppliers = <Supplier>[].obs;
  final RxList<Account> availableAccounts = <Account>[].obs;
  final RxBool isSaving = false.obs;

  // Selected Options
  final Rx<Supplier?> selectedSupplier = Rx<Supplier?>(null);
  final Rx<Account?> selectedAccount = Rx<Account?>(null);
  final RxString paymentMethod = 'cash'.obs;

  // Items in Purchase Cart
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

  // Add Item Dialog / Form State (Category-First)
  final Rx<Category?> selectedCategory = Rx<Category?>(null);
  final Rx<Category?> selectedSubcategory = Rx<Category?>(null);
  final Rx<Product?> selectedProductToAdd = Rx<Product?>(null);
  final RxList<String> productSuggestions = <String>[].obs;

  final qtyController = TextEditingController(text: '1');
  final unitCostController = TextEditingController();
  final retailPriceController = TextEditingController();
  final wholesalePriceController = TextEditingController();
  final packageQuantityController = TextEditingController(text: '1');
  final RxString selectedUnit = 'piece'.obs;
  final RxString selectedPackageUnit = ''.obs;

  // Inline product creation
  final inlineNameController = TextEditingController();
  final inlineSkuController = TextEditingController();
  final inlineBarcodeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    ever(_activeBizService.activeBusiness, (BusinessesData? b) {
      if (b != null) {
        items.clear();
        selectedSupplier.value = null;
        loadData(b.id);
      } else {
        availableProducts.clear();
        availableCategories.clear();
        availableSuppliers.clear();
      }
    });

    initData();
  }

  Future<void> initData() async {
    final b = _activeBizService.activeBusiness.value;
    if (b != null) {
      await loadData(b.id);
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

  Future<void> loadData(String businessId) async {
    final prods = await _dbService.inventoryDao.getAllProducts(businessId);
    availableProducts.value = prods;

    final cats = await _dbService.coreDao.getProductCategories(businessId: businessId);
    availableCategories.value = cats;

    final supps = await _dbService.businessDao.getAllSuppliers(businessId);
    availableSuppliers.value = supps;
  }

  void onSelectCategory(Category? cat) async {
    selectedCategory.value = cat;
    selectedSubcategory.value = null;
    selectedProductToAdd.value = null;
    availableSubcategories.clear();

    if (cat != null) {
      final subs = await _dbService.coreDao.getSubcategories(
        cat.id,
        businessId: currentBusiness.value?.id,
      );
      availableSubcategories.value = subs;
      productSuggestions.value = ProductTemplates.getSuggestionsForCategory(cat.nameBn);
    } else {
      productSuggestions.value = ProductTemplates.globalSuggestions;
    }
  }

  void onSelectSubcategory(Category? sub) {
    selectedSubcategory.value = sub;
    selectedProductToAdd.value = null;
  }

  List<Product> get filteredProductsForAdd {
    var prods = availableProducts.toList();
    if (selectedCategory.value != null) {
      prods = prods.where((p) => p.categoryId == selectedCategory.value!.id).toList();
    }
    if (selectedSubcategory.value != null) {
      prods = prods.where((p) => p.subcategoryId == selectedSubcategory.value!.id).toList();
    }
    return prods;
  }

  void onSelectProduct(Product? prod) {
    selectedProductToAdd.value = prod;
    if (prod != null) {
      selectedUnit.value = prod.unit;
      if (prod.packageUnit != null && prod.packageUnit!.isNotEmpty) {
        selectedPackageUnit.value = prod.packageUnit!;
        packageQuantityController.text = prod.packageQuantity > 0
            ? (prod.packageQuantity % 1 == 0
                ? prod.packageQuantity.toInt().toString()
                : prod.packageQuantity.toString())
            : '1';
      } else {
        selectedPackageUnit.value = '';
        packageQuantityController.text = '1';
      }
      unitCostController.text =
          CurrencyUtils.minorToTaka(prod.purchasePriceMinor).toString();
      retailPriceController.text =
          CurrencyUtils.minorToTaka(prod.sellingPriceMinor).toString();
      wholesalePriceController.text = prod.wholesalePriceMinor > 0
          ? CurrencyUtils.minorToTaka(prod.wholesalePriceMinor).toString()
          : '';
    }
  }

  Future<Product?> createProductInline({
    required String name,
    required String baseUnit,
    String? packageUnit,
    double packageQuantity = 1.0,
    int purchaseCostMinor = 0,
    int retailPriceMinor = 0,
    int wholesalePriceMinor = 0,
  }) async {
    final biz = currentBusiness.value;
    if (biz == null) {
      AppSnackbar.error('ব্যবসা নির্বাচন করা নেই');
      return null;
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final newId = _uuid.v4();

    final newProduct = ProductsCompanion(
      id: Value(newId),
      businessId: Value(biz.id),
      name: Value(name),
      nameBn: Value(name),
      nameEn: Value(name),
      categoryId: Value(selectedCategory.value?.id),
      subcategoryId: Value(selectedSubcategory.value?.id),
      unit: Value(baseUnit),
      packageUnit: Value(packageUnit),
      packageQuantity: Value(packageQuantity),
      purchasePriceMinor: Value(purchaseCostMinor),
      sellingPriceMinor: Value(retailPriceMinor),
      wholesalePriceMinor: Value(wholesalePriceMinor),
      openingQuantity: const Value(0.0),
      minimumStock: const Value(5.0),
      isActive: const Value(1),
      createdAt: Value(now),
    );

    await _dbService.inventoryDao.insertProduct(newProduct);
    await loadData(biz.id);

    final created = availableProducts.firstWhereOrNull((p) => p.id == newId);
    if (created != null) {
      onSelectProduct(created);
    }
    return created;
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
      AppSnackbar.error('পণ্য নির্বাচন করুন অথবা নতুন পণ্য তৈরি করুন');
      return;
    }
    final prod = selectedProductToAdd.value!;
    final qty = double.tryParse(qtyController.text) ?? 1.0;
    if (qty <= 0) {
      AppSnackbar.error('সঠিক পরিমাণ লিখুন');
      return;
    }

    final costMinor = unitCostController.text.trim().isNotEmpty
        ? CurrencyUtils.takaToMinor(unitCostController.text)
        : prod.purchasePriceMinor;

    final retailMinor = retailPriceController.text.trim().isNotEmpty
        ? CurrencyUtils.takaToMinor(retailPriceController.text)
        : prod.sellingPriceMinor;

    final wholesaleMinor = wholesalePriceController.text.trim().isNotEmpty
        ? CurrencyUtils.takaToMinor(wholesalePriceController.text)
        : prod.wholesalePriceMinor;

    final packQty = double.tryParse(packageQuantityController.text) ?? 1.0;
    final packUnit = selectedPackageUnit.value.isNotEmpty ? selectedPackageUnit.value : prod.packageUnit;

    final factor = UnitConversionUtils.getConversionFactor(
      fromUnit: selectedUnit.value,
      toBaseUnit: prod.unit,
      packageUnit: packUnit,
      packageQuantity: packQty > 0 ? packQty : prod.packageQuantity,
    );

    final existing = items.firstWhereOrNull(
        (i) => i.productId == prod.id && i.unit == selectedUnit.value);

    if (existing != null) {
      existing.quantity.value += qty;
      existing.unitCostMinor.value = costMinor;
      items.refresh();
    } else {
      items.add(PurchaseCartItem(
        productId: prod.id,
        productName: prod.nameBn ?? prod.name,
        categoryId: prod.categoryId,
        categoryName: selectedCategory.value?.nameBn,
        subcategoryId: prod.subcategoryId,
        baseUnit: prod.unit,
        unit: selectedUnit.value,
        packageUnit: packUnit,
        packageQuantity: packQty,
        conversionFactor: factor,
        quantity: qty,
        unitCostMinor: costMinor,
        retailPriceMinor: retailMinor,
        wholesalePriceMinor: wholesaleMinor,
      ));
    }

    _syncPaidField();
    selectedProductToAdd.value = null;
    qtyController.text = '1';
    unitCostController.clear();
    retailPriceController.clear();
    wholesalePriceController.clear();
    Get.back(); // close dialog
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
    if (isSaving.value) return false;
    isSaving.value = true;

    try {
      final biz = _activeBizService.activeBusiness.value;
      if (biz == null) {
        AppSnackbar.error('ব্যবসা নির্বাচন করা নেই');
        return false;
      }
      if (items.isEmpty) {
        AppSnackbar.error('ক্রয়ের পণ্য যোগ করুন');
        return false;
      }

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
            conversionFactor: Value(item.conversionFactor),
            baseQuantity: Value(item.baseQuantity),
            unitCostMinor: Value(item.unitCostMinor.value),
            retailPriceMinor: Value(item.retailPriceMinor),
            wholesalePriceMinor: Value(item.wholesalePriceMinor),
            totalMinor: Value(item.totalMinor),
          ),
        );

        movementsCompanionList.add(
          InventoryMovementsCompanion(
            id: Value(_uuid.v4()),
            productId: Value(item.productId),
            businessId: Value(biz.id),
            movementType: const Value('purchase'),
            quantity: Value(item.baseQuantity), // in base stock units!
            unitCostMinor: Value((item.totalMinor / (item.baseQuantity > 0 ? item.baseQuantity : 1.0)).round()),
            referenceType: const Value('purchase'),
            referenceId: Value(purchaseId),
            movementDate: Value(pDate),
            notes: Value('ক্রয় মেমো: ${invoiceController.text.trim()} (${item.quantity.value} ${item.unit})'),
          ),
        );
      }

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
    } finally {
      isSaving.value = false;
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
    retailPriceController.dispose();
    wholesalePriceController.dispose();
    packageQuantityController.dispose();
    inlineNameController.dispose();
    inlineSkuController.dispose();
    inlineBarcodeController.dispose();
    super.onClose();
  }
}
