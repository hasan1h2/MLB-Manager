import 'package:drift/drift.dart';
import 'core_tables.dart';

class Assets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category =>
      text()(); // land, house, gold, vehicle, cattle, equipment, machinery, other
  TextColumn get ownerMemberId => text().references(FamilyMembers, #id)();
  TextColumn get businessId => text().nullable().references(Businesses, #id)();
  IntColumn get purchaseDate => integer()();
  IntColumn get purchaseValueMinor => integer()();
  IntColumn get currentValueMinor => integer()();
  TextColumn get notes => text().nullable()();
  TextColumn get photoPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetAmountMinor => integer()();
  IntColumn get currentAmountMinor =>
      integer().withDefault(const Constant(0))();
  IntColumn get startDate => integer()();
  IntColumn get targetDate => integer()();
  TextColumn get linkedAccountId =>
      text().nullable().references(Accounts, #id)();
  TextColumn get status => text().withDefault(const Constant('in_progress'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Investments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get investmentType => text()();
  IntColumn get initialAmountMinor => integer()();
  IntColumn get currentValueMinor => integer()();
  IntColumn get investmentDate => integer()();
  TextColumn get businessId => text().nullable().references(Businesses, #id)();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
