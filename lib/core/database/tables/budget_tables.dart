import 'package:drift/drift.dart';
import 'core_tables.dart';

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get scopeType => text()(); // personal, family, business
  TextColumn get businessId => text().nullable().references(Businesses, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get periodType => text()(); // monthly, yearly
  IntColumn get startDate => integer()();
  IntColumn get endDate => integer()();
  IntColumn get limitMinor => integer()();
  IntColumn get alertPercentage => integer().withDefault(const Constant(80))();
  TextColumn get status => text().withDefault(const Constant('active'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get reminderType => text()(); // loan_due, supplier_payable, customer_collection, bill_payment, salary, low_stock, budget_alert, savings, custom
  TextColumn get referenceId => text().nullable()();
  IntColumn get scheduledAt => integer()();
  TextColumn get repeatRule => text().nullable()();
  IntColumn get isCompleted => integer().withDefault(const Constant(0))();
  IntColumn get notificationEnabled => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
