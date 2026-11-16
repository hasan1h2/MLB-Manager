import 'package:drift/drift.dart';
import 'core_tables.dart';

class ShoppingRecords extends Table {
  TextColumn get id => text()();
  IntColumn get shoppingDate => integer()();
  TextColumn get storeName => text().nullable()();
  TextColumn get purchasedByMemberId => text().nullable().references(FamilyMembers, #id)();
  IntColumn get subtotalMinor => integer().withDefault(const Constant(0))();
  IntColumn get discountMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer().withDefault(const Constant(0))();
  IntColumn get paidMinor => integer().withDefault(const Constant(0))();
  IntColumn get dueMinor => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class ShoppingItems extends Table {
  TextColumn get id => text()();
  TextColumn get shoppingRecordId => text().references(ShoppingRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get productName => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get totalMinor => integer()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

class ShoppingLists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get createdByMemberId => text().nullable().references(FamilyMembers, #id)();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class ShoppingListItems extends Table {
  TextColumn get id => text()();
  TextColumn get shoppingListId => text().references(ShoppingLists, #id, onDelete: KeyAction.cascade)();
  TextColumn get itemName => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text()();
  IntColumn get isPurchased => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
