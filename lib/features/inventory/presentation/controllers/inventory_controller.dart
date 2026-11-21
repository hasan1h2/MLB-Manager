import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/active_business_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class ProductWithStock {
  final Product product;
  final double currentStock;
  ProductWithStock({required this.product, required this.currentStock});
}

class ProductTierItem {
  final TextEditingController minQtyController;
  final TextEditingController priceController;
  ProductTierItem({String minQty = '', String price = ''})
      : minQtyController = TextEditingController(text: minQty),
        priceController = TextEditingController(text: price);

  void dispose() {
    minQtyController.dispose();
    priceController.dispose();
  }
}

class InventoryController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ActiveBusinessService _activeBizService = Get.find<ActiveBusinessService>();
  final _uuid = const Uuid();
  final ImagePicker _picker = ImagePicker();

  final RxList<ProductWithStock> productsWithStock = <ProductWithStock>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<String?> activeBusinessId = Rx<String?>(null);
  final RxList<Category> businessCategories = <Category>[].obs;

  // Form Fields for Add / Edit Product
  final nameController = TextEditingController();
  final nameEnController = TextEditingController();
  final skuController = TextEditingController();
  final barcodeController = TextEditingController();
  final brandController = TextEditingController();
  final descriptionController = TextEditingController();
  final batchNumberController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final wholesalePriceController = TextEditingController();
  final openingQtyController = TextEditingController(text: '0');
  final minStockController = TextEditingController(text: '5');
  final RxString selectedUnit = 'piece'.obs;
  final Rx<String?> selectedCategoryId = Rx<String?>(null);
  final Rx<String?> selectedSubcategoryId = Rx<String?>(null);
  final RxList<Category> subcategories = <Category>[].obs;
  final RxString packageUnit = ''.obs;
  final packageQuantityController = TextEditingController(text: '1');
  final Rx<String?> imagePath = Rx<String?>(null);
  final Rx<DateTime?> expiryDate = Rx<DateTime?>(null);

  // Wholesale Price Tiers
  final RxList<ProductTierItem> priceTiers = <ProductTierItem>[].obs;

  // Stock Movement Fields
  final movementQtyController = TextEditingController();
  final movementNotesController = TextEditingController();
  final RxString selectedMovementType =
      'in'.obs; // in, out, adjustment, damage, wastage, return

  // Search & Filter
  final searchController = TextEditingController();
  final Rx<String?> filterCategory = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    // React to active business changes
    ever(_activeBizService.activeBusiness, (BusinessesData? b) {
      activeBusinessId.value = b?.id;
      if (b != null) {
        loadCategories();
        loadProducts();
      } else {
        productsWithStock.clear();
        isLoading.value = false;
      }
    });

    final current = _activeBizService.activeBusiness.value;
    if (current != null) {
      activeBusinessId.value = current.id;
      loadCategories();
      loadProducts();
    } else {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    final cats = await _dbService.coreDao
        .getProductCategories(businessId: activeBusinessId.value);
    businessCategories.value = cats;
  }

  Future<void> onCategoryChanged(String? catId) async {
    selectedCategoryId.value = catId;
    selectedSubcategoryId.value = null;
    subcategories.clear();
    if (catId != null) {
      final subs = await _dbService.coreDao.getSubcategories(
        catId,
        businessId: activeBusinessId.value,
      );
      subcategories.value = subs;
    }
  }

  Future<void> loadProducts() async {
    final bizId = activeBusinessId.value;
    if (bizId == null) {
      productsWithStock.clear();
      isLoading.value = false;
      return;
    }
    try {
      isLoading.value = true;
      final prods = await _dbService.inventoryDao.getAllProducts(bizId);

      final list = <ProductWithStock>[];
      final query = searchController.text.trim().toLowerCase();
      final catFilter = filterCategory.value;

      for (var p in prods) {
        if (catFilter != null && p.categoryId != catFilter) continue;
        if (query.isNotEmpty) {
          final matches = p.name.toLowerCase().contains(query) ||
              (p.nameEn?.toLowerCase().contains(query) ?? false) ||
              (p.barcode?.toLowerCase().contains(query) ?? false) ||
              (p.sku?.toLowerCase().contains(query) ?? false);
          if (!matches) continue;
        }

        final stock =
            await _dbService.inventoryDao.getProductCurrentStock(p.id);
        list.add(ProductWithStock(product: p, currentStock: stock));
      }
      productsWithStock.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  void addTier() {
    priceTiers.add(ProductTierItem());
  }

  void removeTier(ProductTierItem tier) {
    tier.dispose();
    priceTiers.remove(tier);
  }

  Future<void> pickImage({bool fromCamera = false}) async {
    final picked = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (picked != null) {
      imagePath.value = picked.path;
    }
  }

  Future<bool> saveProduct() async {
    final bizId = activeBusinessId.value;
    if (bizId == null) {
      AppSnackbar.error('কোন সক্রিয় ব্যবসা নির্বাচন করা নেই');
      return false;
    }

    if (nameController.text.trim().isEmpty) {
      AppSnackbar.error('পণ্যের নাম লিখুন');
      return false;
    }

    final purchasePrice =
        CurrencyUtils.takaToMinor(purchasePriceController.text);
    final sellingPrice = CurrencyUtils.takaToMinor(sellingPriceController.text);
    final wholesalePrice = wholesalePriceController.text.trim().isNotEmpty
        ? CurrencyUtils.takaToMinor(wholesalePriceController.text)
        : 0;
    final openingQty = double.tryParse(openingQtyController.text) ?? 0.0;
    final minStock = double.tryParse(minStockController.text) ?? 0.0;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final productId = _uuid.v4();

    try {
      await _dbService.inventoryDao.insertProduct(
        ProductsCompanion(
          id: Value(productId),
          businessId: Value(bizId),
          name: Value(nameController.text.trim()),
          nameBn: Value(nameController.text.trim()),
          nameEn: Value(nameEnController.text.trim().isNotEmpty
              ? nameEnController.text.trim()
              : null),
          categoryId: Value(selectedCategoryId.value),
          subcategoryId: Value(selectedSubcategoryId.value),
          packageUnit: Value(packageUnit.value.isNotEmpty ? packageUnit.value : null),
          packageQuantity: Value(double.tryParse(packageQuantityController.text) ?? 1.0),
          sku: Value(skuController.text.trim().isNotEmpty
              ? skuController.text.trim()
              : null),
          barcode: Value(barcodeController.text.trim().isNotEmpty
              ? barcodeController.text.trim()
              : null),
          brand: Value(brandController.text.trim().isNotEmpty
              ? brandController.text.trim()
              : null),
          description: Value(descriptionController.text.trim().isNotEmpty
              ? descriptionController.text.trim()
              : null),
          batchNumber: Value(batchNumberController.text.trim().isNotEmpty
              ? batchNumberController.text.trim()
              : null),
          expiryDate: Value(expiryDate.value?.millisecondsSinceEpoch),
          imagePath: Value(imagePath.value),
          unit: Value(selectedUnit.value),
          purchasePriceMinor: Value(purchasePrice),
          sellingPriceMinor: Value(sellingPrice),
          wholesalePriceMinor: Value(wholesalePrice),
          openingQuantity: Value(openingQty),
          minimumStock: Value(minStock),
          isActive: const Value(1),
          createdAt: Value(now),
        ),
      );

      // Save wholesale price tiers if any
      final tierCompanions = <ProductPriceTiersCompanion>[];
      for (var t in priceTiers) {
        final minQ = double.tryParse(t.minQtyController.text) ?? 0.0;
        final priceM = CurrencyUtils.takaToMinor(t.priceController.text);
        if (minQ > 0 && priceM > 0) {
          tierCompanions.add(ProductPriceTiersCompanion(
            id: Value(_uuid.v4()),
            productId: Value(productId),
            minQuantity: Value(minQ),
            priceMinor: Value(priceM),
            createdAt: Value(now),
          ));
        }
      }
      if (tierCompanions.isNotEmpty) {
        await _dbService.inventoryDao.setProductPriceTiers(productId, tierCompanions);
      }

      AppSnackbar.success('পণ্য সফলভাবে যুক্ত হয়েছে');
      _clearForm();
      await loadProducts();
      return true;
    } catch (e) {
      AppSnackbar.error('ত্রুটি: $e');
      return false;
    }
  }

  void _clearForm() {
    nameController.clear();
    nameEnController.clear();
    skuController.clear();
    barcodeController.clear();
    brandController.clear();
    descriptionController.clear();
    batchNumberController.clear();
    purchasePriceController.clear();
    sellingPriceController.clear();
    wholesalePriceController.clear();
    openingQtyController.text = '0';
    minStockController.text = '5';
    packageQuantityController.text = '1';
    packageUnit.value = '';
    selectedCategoryId.value = null;
    selectedSubcategoryId.value = null;
    subcategories.clear();
    imagePath.value = null;
    expiryDate.value = null;
    for (var t in priceTiers) {
      t.dispose();
    }
    priceTiers.clear();
  }

  Future<void> recordMovement(String productId) async {
    final bizId = activeBusinessId.value;
    if (bizId == null) return;

    final qty = double.tryParse(movementQtyController.text) ?? 0.0;
    if (qty <= 0) return;

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _dbService.inventoryDao.insertMovement(
      InventoryMovementsCompanion(
        id: Value(_uuid.v4()),
        productId: Value(productId),
        businessId: Value(bizId),
        movementType: Value(selectedMovementType.value),
        quantity: Value(qty),
        movementDate: Value(now),
        notes: Value(movementNotesController.text.trim()),
      ),
    );

    movementQtyController.clear();
    movementNotesController.clear();
    await loadProducts();
    AppSnackbar.success('স্টক আপডেট করা হয়েছে');
  }

  @override
  void onClose() {
    nameController.dispose();
    nameEnController.dispose();
    skuController.dispose();
    barcodeController.dispose();
    brandController.dispose();
    descriptionController.dispose();
    batchNumberController.dispose();
    purchasePriceController.dispose();
    sellingPriceController.dispose();
    wholesalePriceController.dispose();
    openingQtyController.dispose();
    minStockController.dispose();
    packageQuantityController.dispose();
    movementQtyController.dispose();
    movementNotesController.dispose();
    searchController.dispose();
    for (var t in priceTiers) {
      t.dispose();
    }
    super.onClose();
  }
}
