import 'package:drift/drift.dart';

class FamilyMembers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get relationship => text().nullable()();
  TextColumn get role => text()(); // owner, admin, member, viewer
  TextColumn get photoPath => text().nullable()();
  IntColumn get isActive => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Businesses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get businessType =>
      text()(); // cattle, grocery, wholesale, retail, hybrid, etc.
  TextColumn get description => text().nullable()();
  IntColumn get openingDate => integer()();
  IntColumn get initialCapitalMinor =>
      integer().withDefault(const Constant(0))();
  TextColumn get location => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('BDT'))();
  TextColumn get timeFormat =>
      text().withDefault(const Constant('12h'))(); // 12h, 24h
  IntColumn get allowNegativeStock =>
      integer().withDefault(const Constant(0))();
  TextColumn get costingMethod =>
      text().withDefault(const Constant('fifo'))(); // fifo, weighted_avg
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class CashSessions extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  IntColumn get sessionDate => integer()();
  IntColumn get openingCashMinor =>
      integer().withDefault(const Constant(0))();
  IntColumn get expectedClosingMinor =>
      integer().withDefault(const Constant(0))();
  IntColumn get actualClosingMinor => integer().nullable()();
  IntColumn get differenceMinor => integer().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('open'))(); // open, closed
  TextColumn get notes => text().nullable()();
  IntColumn get openedAt => integer()();
  IntColumn get closedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get accountType =>
      text()(); // cash, bank, bkash, nagad, rocket, other_wallet, custom
  TextColumn get ownerMemberId =>
      text().nullable().references(FamilyMembers, #id)();
  TextColumn get businessId => text().nullable().references(Businesses, #id)();
  IntColumn get openingBalanceMinor =>
      integer().withDefault(const Constant(0))();
  TextColumn get currencyCode => text().withDefault(const Constant('BDT'))();
  IntColumn get isActive => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get nameBn => text()();
  TextColumn get nameEn => text()();
  TextColumn get categoryType => text()(); // income, expense, product
  TextColumn get parentId => text().nullable().references(Categories, #id)();
  TextColumn get scope => text()(); // personal, family, business, both
  TextColumn get businessId => text().nullable().references(Businesses, #id)();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get isSystem => integer().withDefault(const Constant(0))();
  IntColumn get isActive => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get transactionNumber => text()();
  TextColumn get transactionType => text()(); // income, expense, transfer
  TextColumn get scopeType => text()(); // personal, family, business
  TextColumn get familyMemberId =>
      text().nullable().references(FamilyMembers, #id)();
  TextColumn get businessId => text().nullable().references(Businesses, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get accountId => text().nullable().references(Accounts, #id)();
  IntColumn get amountMinor => integer()();
  IntColumn get transactionDate => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get paymentStatus =>
      text().withDefault(const Constant('paid'))(); // paid, due, partial
  TextColumn get purchaseTime => text().nullable()();
  TextColumn get sourceType => text()
      .nullable()(); // manual, voice, ocr, shopping, cattle, sale, purchase
  TextColumn get sourceId => text().nullable()();
  TextColumn get createdByMemberId =>
      text().nullable().references(FamilyMembers, #id)();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionEntries extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get accountId => text().references(Accounts, #id)();
  IntColumn get debitMinor => integer().withDefault(const Constant(0))();
  IntColumn get creditMinor => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text()();
  TextColumn get fileType => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
