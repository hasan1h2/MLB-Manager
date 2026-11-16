import 'package:drift/drift.dart';
import 'core_tables.dart';

class LoanAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get partyName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get loanType => text()(); // receivable, payable
  TextColumn get businessId => text().nullable().references(Businesses, #id)();
  IntColumn get principalMinor => integer()();
  TextColumn get interestType => text().nullable()(); // none, flat, reducing
  RealColumn get interestRate => real().withDefault(const Constant(0.0))();
  IntColumn get startDate => integer()();
  IntColumn get dueDate => integer()();
  TextColumn get status => text().withDefault(const Constant('active'))(); // active, settled, overdue
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LoanPayments extends Table {
  TextColumn get id => text()();
  TextColumn get loanId => text().references(LoanAccounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get transactionId => text().nullable().references(Transactions, #id)();
  IntColumn get principalPaidMinor => integer()();
  IntColumn get interestPaidMinor => integer().withDefault(const Constant(0))();
  IntColumn get paymentDate => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
