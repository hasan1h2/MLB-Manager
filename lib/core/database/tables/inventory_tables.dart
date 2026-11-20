import 'package:drift/drift.dart';
import 'core_tables.dart';
import 'party_tables.dart';

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get name => text()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get unit => text()();
  IntColumn get purchasePriceMinor =>
      integer().withDefault(const Constant(0))();
  IntColumn get sellingPriceMinor => integer().withDefault(const Constant(0))();
  RealColumn get openingQuantity => real().withDefault(const Constant(0.0))();
  RealColumn get minimumStock => real().withDefault(const Constant(0.0))();
  IntColumn get isActive => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class InventoryMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get movementType =>
      text()(); // in, out, purchase, sale, return, adjustment, damage, wastage, transfer
  RealColumn get quantity => real()();
  IntColumn get unitCostMinor => integer().withDefault(const Constant(0))();
  TextColumn get referenceType => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  IntColumn get movementDate => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseRecords extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get supplierId => text().nullable().references(Suppliers, #id)();
  IntColumn get purchaseDate => integer()();
  IntColumn get subtotalMinor => integer().withDefault(const Constant(0))();
  IntColumn get discountMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer().withDefault(const Constant(0))();
  IntColumn get paidMinor => integer().withDefault(const Constant(0))();
  IntColumn get dueMinor => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseItems extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId =>
      text().references(PurchaseRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text().references(Products, #id)();
  RealColumn get quantity => real()();
  IntColumn get unitCostMinor => integer()();
  IntColumn get totalMinor => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class SalesRecords extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  IntColumn get saleDate => integer()();
  IntColumn get subtotalMinor => integer().withDefault(const Constant(0))();
  IntColumn get discountMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer().withDefault(const Constant(0))();
  IntColumn get paidMinor => integer().withDefault(const Constant(0))();
  IntColumn get dueMinor => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class SalesItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId =>
      text().references(SalesRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text().references(Products, #id)();
  RealColumn get quantity => real()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get unitCostMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
