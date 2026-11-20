import 'package:drift/drift.dart';
import 'core_tables.dart';

class Cattle extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get tagNumber => text()();
  TextColumn get name => text().nullable()();
  TextColumn get breed => text().nullable()();
  TextColumn get gender =>
      text().nullable()(); // bull, cow, steer, heifer, calf
  IntColumn get birthDate => integer().nullable()();
  TextColumn get estimatedAge => text().nullable()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get purchaseDate => integer()();
  IntColumn get purchasePriceMinor => integer()();
  TextColumn get sellerId => text().nullable()();
  TextColumn get status => text().withDefault(
      const Constant('active'))(); // active, sold, deceased, quarantined
  TextColumn get photoPath => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class CattleExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get cattleId =>
      text().references(Cattle, #id, onDelete: KeyAction.cascade)();
  TextColumn get expenseType =>
      text()(); // feed, medical, vaccination, vet, labor, transport, other
  IntColumn get amountMinor => integer()();
  IntColumn get expenseDate => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get transactionId =>
      text().nullable().references(Transactions, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

class CattleSales extends Table {
  TextColumn get id => text()();
  TextColumn get cattleId => text().references(Cattle, #id)();
  TextColumn get buyerName => text()();
  IntColumn get saleDate => integer()();
  IntColumn get salePriceMinor => integer()();
  IntColumn get paidMinor => integer()();
  IntColumn get dueMinor => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
