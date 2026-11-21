import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';

class InventoryDao {
  final AppDatabase db;
  final _uuid = const Uuid();

  InventoryDao(this.db);

  Stream<List<Product>> watchProducts(
    String businessId, {
    String? categoryId,
    String? search,
  }) {
    var query = db.select(db.products)
      ..where((tbl) =>
          tbl.businessId.equals(businessId) & tbl.isActive.equals(1));

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query..where((tbl) => tbl.categoryId.equals(categoryId));
    }

    if (search != null && search.trim().isNotEmpty) {
      final term = '%${search.trim().toLowerCase()}%';
      query = query
        ..where((tbl) =>
            tbl.name.lower().like(term) |
            tbl.sku.lower().like(term) |
            tbl.barcode.lower().like(term) |
            tbl.nameBn.lower().like(term) |
            tbl.nameEn.lower().like(term));
    }

    return (query..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<List<Product>> getAllProducts(String businessId) {
    return (db.select(db.products)
          ..where((tbl) =>
              tbl.businessId.equals(businessId) & tbl.isActive.equals(1))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<Product?> getProductById(String id) {
    return (db.select(db.products)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Product?> getProductByBarcode(String businessId, String barcode) {
    return (db.select(db.products)
          ..where((tbl) =>
              tbl.businessId.equals(businessId) &
              tbl.barcode.equals(barcode) &
              tbl.isActive.equals(1)))
        .getSingleOrNull();
  }

  Future<int> insertProduct(ProductsCompanion product) {
    return db.into(db.products).insert(product);
  }

  Future<bool> updateProduct(Product product) {
    return db.update(db.products).replace(product);
  }

  Future<void> batchInsertProducts(List<ProductsCompanion> products) async {
    await db.batch((batch) {
      batch.insertAll(db.products, products);
    });
  }

  // --- Wholesale Price Tiers ---
  Future<List<ProductPriceTier>> getProductPriceTiers(String productId) {
    return (db.select(db.productPriceTiers)
          ..where((tbl) => tbl.productId.equals(productId))
          ..orderBy([(t) => OrderingTerm.asc(t.minQuantity)]))
        .get();
  }

  Future<void> setProductPriceTiers(
    String productId,
    List<ProductPriceTiersCompanion> tiers,
  ) async {
    await db.transaction(() async {
      await (db.delete(db.productPriceTiers)
            ..where((tbl) => tbl.productId.equals(productId)))
          .go();
      for (var tier in tiers) {
        await db.into(db.productPriceTiers).insert(tier);
      }
    });
  }

  /// Determines the effective selling price for a product given quantity and mode:
  /// 1. If quantity matches a specific wholesale price tier, use that tier's price.
  /// 2. If isWholesale is true and product has wholesalePriceMinor > 0, use wholesalePriceMinor.
  /// 3. Otherwise use product's default retail sellingPriceMinor.
  Future<int> getProductPriceForQuantity(
    String productId,
    double quantity, {
    bool isWholesale = false,
  }) async {
    final product = await getProductById(productId);
    if (product == null) return 0;

    final tiers = await getProductPriceTiers(productId);
    for (var tier in tiers) {
      if (quantity >= tier.minQuantity) {
        if (tier.maxQuantity == null || quantity <= tier.maxQuantity!) {
          return tier.priceMinor;
        }
      }
    }

    if (isWholesale && product.wholesalePriceMinor > 0) {
      return product.wholesalePriceMinor;
    }

    return product.sellingPriceMinor;
  }

  /// Calculates actual real-time stock quantity for a product:
  /// Current Stock = Opening Stock + Inflow (purchase, return, in) - Outflow (sale, damage, wastage, out) + Adjustments
  Future<double> getProductCurrentStock(String productId) async {
    final product = await getProductById(productId);
    if (product == null) return 0.0;

    final movements = await (db.select(db.inventoryMovements)
          ..where((tbl) => tbl.productId.equals(productId)))
        .get();
    double netMovements = 0.0;
    for (var m in movements) {
      if (m.movementType == 'in' ||
          m.movementType == 'purchase' ||
          m.movementType == 'return') {
        netMovements += m.quantity;
      } else if (m.movementType == 'out' ||
          m.movementType == 'sale' ||
          m.movementType == 'damage' ||
          m.movementType == 'wastage') {
        netMovements -= m.quantity;
      } else if (m.movementType == 'adjustment') {
        netMovements += m.quantity;
      }
    }

    return product.openingQuantity + netMovements;
  }

  /// Records an inventory movement
  Future<int> insertMovement(InventoryMovementsCompanion movement) {
    return db.into(db.inventoryMovements).insert(movement);
  }

  /// Posts a purchase record with items and inventory movements atomically
  Future<void> postPurchaseWithItems({
    required PurchaseRecordsCompanion purchase,
    required List<PurchaseItemsCompanion> items,
    required List<InventoryMovementsCompanion> movements,
    String? accountId,
  }) async {
    await db.transaction(() async {
      await db.into(db.purchaseRecords).insert(purchase);
      for (var item in items) {
        await db.into(db.purchaseItems).insert(item);
      }
      for (var movement in movements) {
        await db.into(db.inventoryMovements).insert(movement);
      }

      // If money was paid out at the time of purchase, log a transaction
      final paidMinor = purchase.paidMinor.value;
      if (paidMinor > 0 && accountId != null) {
        final txId = _uuid.v4();
        final now = purchase.purchaseDate.value;
        await db.into(db.transactions).insert(
              TransactionsCompanion(
                id: Value(txId),
                transactionNumber: Value('PUR-${DateTime.now().millisecondsSinceEpoch}'),
                transactionType: const Value('expense'),
                scopeType: const Value('business'),
                businessId: purchase.businessId,
                accountId: Value(accountId),
                amountMinor: Value(paidMinor),
                transactionDate: Value(now),
                description: Value(purchase.notes.value ?? 'পণ্য ক্রয় / Purchase'),
                sourceType: const Value('purchase'),
                sourceId: purchase.id,
                purchaseTime: purchase.purchaseTime,
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );

        await db.into(db.transactionEntries).insert(
              TransactionEntriesCompanion(
                id: Value(_uuid.v4()),
                transactionId: Value(txId),
                accountId: Value(accountId),
                debitMinor: Value(paidMinor),
                creditMinor: const Value(0),
                createdAt: Value(now),
              ),
            );
      }
    });
  }

  /// Posts a sales record with items and inventory movements atomically
  Future<void> postSaleWithItems({
    required SalesRecordsCompanion sale,
    required List<SalesItemsCompanion> items,
    required List<InventoryMovementsCompanion> movements,
    String? accountId,
  }) async {
    await db.transaction(() async {
      await db.into(db.salesRecords).insert(sale);
      for (var item in items) {
        await db.into(db.salesItems).insert(item);
      }
      for (var movement in movements) {
        await db.into(db.inventoryMovements).insert(movement);
      }

      // If money was collected at the time of sale, log a transaction
      final paidMinor = sale.paidMinor.value;
      if (paidMinor > 0 && accountId != null) {
        final txId = _uuid.v4();
        final now = sale.saleDate.value;
        await db.into(db.transactions).insert(
              TransactionsCompanion(
                id: Value(txId),
                transactionNumber: Value('SALE-${DateTime.now().millisecondsSinceEpoch}'),
                transactionType: const Value('income'),
                scopeType: const Value('business'),
                businessId: sale.businessId,
                accountId: Value(accountId),
                amountMinor: Value(paidMinor),
                transactionDate: Value(now),
                description: Value(sale.notes.value ?? 'পণ্য বিক্রয় / Sale'),
                sourceType: const Value('sale'),
                sourceId: sale.id,
                purchaseTime: sale.saleTime,
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );

        await db.into(db.transactionEntries).insert(
              TransactionEntriesCompanion(
                id: Value(_uuid.v4()),
                transactionId: Value(txId),
                accountId: Value(accountId),
                debitMinor: const Value(0),
                creditMinor: Value(paidMinor),
                createdAt: Value(now),
              ),
            );
      }
    });
  }
}
