import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class ProductWithStock {
  final Product product;
  final double currentStock;
  ProductWithStock({required this.product, required this.currentStock});
}

class InventoryController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<ProductWithStock> productsWithStock = <ProductWithStock>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<String?> activeBusinessId = Rx<String?>(null);

  // Form Fields for Add Product
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final barcodeController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final openingQtyController = TextEditingController(text: '0');
  final minStockController = TextEditingController(text: '5');
  final RxString selectedUnit = 'piece'.obs;

  // Stock Movement Fields
  final movementQtyController = TextEditingController();
  final movementNotesController = TextEditingController();
  final RxString selectedMovementType = 'in'.obs; // in, out, adjustment, damage, wastage

  @override
  void onInit() {
    super.onInit();
    initBusiness();
  }

  Future<void> initBusiness() async {
    final businesses = await _dbService.businessDao.getAllBusinesses();
    if (businesses.isNotEmpty) {
      activeBusinessId.value = businesses.first.id;
      await loadProducts();
    } else {
      isLoading.value = false;
    }
  }

  Future<void> loadProducts() async {
    if (activeBusinessId.value == null) return;
    try {
      isLoading.value = true;
      final prods = await _dbService.inventoryDao.getAllProducts(activeBusinessId.value!);
      final list = <ProductWithStock>[];
      for (var p in prods) {
        final stock = await _dbService.inventoryDao.getProductCurrentStock(p.id);
        list.add(ProductWithStock(product: p, currentStock: stock));
      }
      productsWithStock.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveProduct() async {
    if (nameController.text.trim().isEmpty) {
      AppSnackbar.error('পণ্যের নাম লিখুন');
      return false;
    }

    final purchasePrice = CurrencyUtils.takaToMinor(purchasePriceController.text);
    final sellingPrice = CurrencyUtils.takaToMinor(sellingPriceController.text);
    final openingQty = double.tryParse(openingQtyController.text) ?? 0.0;
    final minStock = double.tryParse(minStockController.text) ?? 0.0;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    try {
      await _dbService.inventoryDao.insertProduct(
        ProductsCompanion(
          id: Value(_uuid.v4()),
          businessId: Value(activeBusinessId.value!),
          name: Value(nameController.text.trim()),
          sku: Value(skuController.text.trim().isNotEmpty ? skuController.text.trim() : null),
          barcode: Value(barcodeController.text.trim().isNotEmpty ? barcodeController.text.trim() : null),
          unit: Value(selectedUnit.value),
          purchasePriceMinor: Value(purchasePrice),
          sellingPriceMinor: Value(sellingPrice),
          openingQuantity: Value(openingQty),
          minimumStock: Value(minStock),
          isActive: const Value(1),
          createdAt: Value(now),
        ),
      );

      AppSnackbar.success('পণ্য সফলভাবে যুক্ত হয়েছে');
      nameController.clear();
      skuController.clear();
      barcodeController.clear();
      purchasePriceController.clear();
      sellingPriceController.clear();
      await loadProducts();
      return true;
    } catch (e) {
      AppSnackbar.error('Error: $e');
      return false;
    }
  }

  Future<void> recordMovement(String productId) async {
    final qty = double.tryParse(movementQtyController.text) ?? 0.0;
    if (qty <= 0) return;

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _dbService.inventoryDao.insertMovement(
      InventoryMovementsCompanion(
        id: Value(_uuid.v4()),
        productId: Value(productId),
        businessId: Value(activeBusinessId.value!),
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
    skuController.dispose();
    barcodeController.dispose();
    purchasePriceController.dispose();
    sellingPriceController.dispose();
    openingQtyController.dispose();
    minStockController.dispose();
    movementQtyController.dispose();
    movementNotesController.dispose();
    super.onClose();
  }
}
