import 'package:drift/drift.dart';
import 'core_tables.dart';

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get name => text()();
  TextColumn get company => text().nullable()();
  TextColumn get customerType =>
      text().withDefault(const Constant('retail'))(); // retail, wholesale, regular, walk_in
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  IntColumn get openingBalanceMinor =>
      integer().withDefault(const Constant(0))();
  IntColumn get creditLimitMinor =>
      integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get name => text()();
  TextColumn get company => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  IntColumn get openingBalanceMinor =>
      integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class PartyPayments extends Table {
  TextColumn get id => text()();
  TextColumn get partyType => text()(); // customer, supplier
  TextColumn get partyId => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get transactionId =>
      text().nullable().references(Transactions, #id)();
  IntColumn get amountMinor => integer()();
  IntColumn get paymentDate => integer()();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
