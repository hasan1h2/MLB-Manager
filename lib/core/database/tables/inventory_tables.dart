import 'package:drift/drift.dart';
import 'core_tables.dart';
import 'party_tables.dart';

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get name => text()();
  TextColumn get nameBn => text().nullable()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get unit => text()();
  IntColumn get purchasePriceMinor =>
      integer().withDefault(const Constant(0))();
  IntColumn get sellingPriceMinor => integer().withDefault(const Constant(0))();
  IntColumn get wholesalePriceMinor =>
      integer().withDefault(const Constant(0))();
  TextColumn get brand => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get expiryDate => integer().nullable()();
  TextColumn get batchNumber => text().nullable()();
  TextColumn get defaultSupplierId =>
      text().nullable().references(Suppliers, #id)();
  RealColumn get openingQuantity => real().withDefault(const Constant(0.0))();
  RealColumn get minimumStock => real().withDefault(const Constant(0.0))();
  IntColumn get isActive => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProductPriceTiers extends Table {
  TextColumn get id => text()();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  RealColumn get minQuantity => real()();
  RealColumn get maxQuantity => real().nullable()();
  IntColumn get priceMinor => integer()();
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
  TextColumn get purchaseTime => text().nullable()();
  IntColumn get isCustomDateTime => integer().withDefault(const Constant(0))();
  TextColumn get invoiceNumber => text().nullable()();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get subtotalMinor => integer().withDefault(const Constant(0))();
  IntColumn get discountMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer().withDefault(const Constant(0))();
  IntColumn get paidMinor => integer().withDefault(const Constant(0))();
  IntColumn get dueMinor => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class PurchaseItems extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId =>
      text().references(PurchaseRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productName => text().nullable()();
  TextColumn get unit => text().nullable()();
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
  TextColumn get saleTime => text().nullable()();
  IntColumn get isCustomDateTime => integer().withDefault(const Constant(0))();
  TextColumn get invoiceNumber => text().nullable()();
  TextColumn get saleType =>
      text().withDefault(const Constant('retail'))(); // retail, wholesale, quick_sale
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get subtotalMinor => integer().withDefault(const Constant(0))();
  IntColumn get discountMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer().withDefault(const Constant(0))();
  IntColumn get paidMinor => integer().withDefault(const Constant(0))();
  IntColumn get dueMinor => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class SalesItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId =>
      text().references(SalesRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text().nullable().references(Products, #id)();
  TextColumn get productName => text().nullable()();
  TextColumn get unit => text().nullable()();
  RealColumn get quantity => real()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get unitCostMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
