import 'package:drift/drift.dart';
import '../app_database.dart';

class InventoryDao {
  final AppDatabase db;
  InventoryDao(this.db);

  Stream<List<Product>> watchProducts(String businessId) {
    return (db.select(db.products)
          ..where((tbl) => tbl.businessId.equals(businessId) & tbl.isActive.equals(1)))
        .watch();
  }

  Future<List<Product>> getAllProducts(String businessId) {
    return (db.select(db.products)
          ..where((tbl) => tbl.businessId.equals(businessId) & tbl.isActive.equals(1)))
        .get();
  }

  Future<Product?> getProductById(String id) {
    return (db.select(db.products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertProduct(ProductsCompanion product) {
    return db.into(db.products).insert(product);
  }

  Future<bool> updateProduct(Product product) {
    return db.update(db.products).replace(product);
  }

  /// Calculates actual real-time stock quantity for a product:
  /// Current Stock = Opening Stock + Stock In - Stock Out + Adjustments
  Future<double> getProductCurrentStock(String productId) async {
    final product = await getProductById(productId);
    if (product == null) return 0.0;

    final movements = await (db.select(db.inventoryMovements)..where((tbl) => tbl.productId.equals(productId))).get();
    double netMovements = 0.0;
    for (var m in movements) {
      if (m.movementType == 'in' || m.movementType == 'purchase' || m.movementType == 'return') {
        netMovements += m.quantity;
      } else if (m.movementType == 'out' || m.movementType == 'sale' || m.movementType == 'damage' || m.movementType == 'wastage') {
        netMovements -= m.quantity;
      } else if (m.movementType == 'adjustment') {
        netMovements += m.quantity; // positive or negative
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
  }) async {
    await db.transaction(() async {
      await db.into(db.purchaseRecords).insert(purchase);
      for (var item in items) {
        await db.into(db.purchaseItems).insert(item);
      }
      for (var movement in movements) {
        await db.into(db.inventoryMovements).insert(movement);
      }
    });
  }

  /// Posts a sales record with items and inventory movements atomically
  Future<void> postSaleWithItems({
    required SalesRecordsCompanion sale,
    required List<SalesItemsCompanion> items,
    required List<InventoryMovementsCompanion> movements,
  }) async {
    await db.transaction(() async {
      await db.into(db.salesRecords).insert(sale);
      for (var item in items) {
        await db.into(db.salesItems).insert(item);
      }
      for (var movement in movements) {
        await db.into(db.inventoryMovements).insert(movement);
      }
    });
  }
}
