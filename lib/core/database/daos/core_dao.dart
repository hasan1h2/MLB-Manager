import 'package:drift/drift.dart';
import '../app_database.dart';

class CoreDao {
  final AppDatabase db;
  CoreDao(this.db);

  // --- Family Members ---
  Stream<List<FamilyMember>> watchFamilyMembers() {
    return (db.select(db.familyMembers)..where((tbl) => tbl.isActive.equals(1)))
        .watch();
  }

  Future<List<FamilyMember>> getAllFamilyMembers() {
    return (db.select(db.familyMembers)..where((tbl) => tbl.isActive.equals(1)))
        .get();
  }

  Future<FamilyMember?> getFamilyMemberById(String id) {
    return (db.select(db.familyMembers)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertFamilyMember(FamilyMembersCompanion entry) {
    return db.into(db.familyMembers).insert(entry);
  }

  Future<bool> updateFamilyMember(FamilyMember entry) {
    return db.update(db.familyMembers).replace(entry);
  }

  // --- Accounts ---
  Stream<List<Account>> watchAccounts() {
    return (db.select(db.accounts)..where((tbl) => tbl.isActive.equals(1)))
        .watch();
  }

  Future<List<Account>> getAllAccounts() {
    return (db.select(db.accounts)..where((tbl) => tbl.isActive.equals(1)))
        .get();
  }

  Future<Account?> getAccountById(String id) {
    return (db.select(db.accounts)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertAccount(AccountsCompanion entry) {
    return db.into(db.accounts).insert(entry);
  }

  Future<bool> updateAccount(Account entry) {
    return db.update(db.accounts).replace(entry);
  }

  /// Calculates real-time account balance from journal entries + opening balance
  Future<int> getAccountBalance(String accountId) async {
    final account = await getAccountById(accountId);
    if (account == null) return 0;

    // Sum credits and debits from transaction_entries
    final debits = await (db.selectOnly(db.transactionEntries)
          ..addColumns([db.transactionEntries.debitMinor.sum()])
          ..where(db.transactionEntries.accountId.equals(accountId)))
        .getSingle();
    final int totalDebits =
        debits.read(db.transactionEntries.debitMinor.sum()) ?? 0;

    final credits = await (db.selectOnly(db.transactionEntries)
          ..addColumns([db.transactionEntries.creditMinor.sum()])
          ..where(db.transactionEntries.accountId.equals(accountId)))
        .getSingle();
    final int totalCredits =
        credits.read(db.transactionEntries.creditMinor.sum()) ?? 0;

    // Formula: Balance = Opening + Credits (Inflow) - Debits (Outflow)
    return account.openingBalanceMinor + totalCredits - totalDebits;
  }

  // --- Categories ---
  Stream<List<Category>> watchCategories({String? type}) {
    var query = db.select(db.categories);
    if (type != null) {
      query = query..where((tbl) => tbl.categoryType.equals(type));
    }
    return query.watch();
  }

  Future<List<Category>> getAllCategories({String? type}) {
    var query = db.select(db.categories);
    if (type != null) {
      query = query..where((tbl) => tbl.categoryType.equals(type));
    }
    return query.get();
  }

  Future<Category?> getCategoryById(String id) {
    return (db.select(db.categories)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertCategory(CategoriesCompanion entry) {
    return db.into(db.categories).insert(entry);
  }

  Stream<List<Category>> watchProductCategories({String? businessId, bool activeOnly = true}) {
    var query = db.select(db.categories)
      ..where((tbl) => tbl.categoryType.equals('product'));
    if (activeOnly) {
      query = query..where((tbl) => tbl.isActive.equals(1));
    }
    if (businessId != null) {
      query = query..where((tbl) => tbl.businessId.isNull() | tbl.businessId.equals(businessId));
    } else {
      query = query..where((tbl) => tbl.businessId.isNull());
    }
    return (query..orderBy([(tbl) => OrderingTerm.asc(tbl.nameBn)])).watch();
  }

  Future<List<Category>> getProductCategories({String? businessId, bool activeOnly = true}) {
    var query = db.select(db.categories)
      ..where((tbl) => tbl.categoryType.equals('product'));
    if (activeOnly) {
      query = query..where((tbl) => tbl.isActive.equals(1));
    }
    if (businessId != null) {
      query = query..where((tbl) => tbl.businessId.isNull() | tbl.businessId.equals(businessId));
    } else {
      query = query..where((tbl) => tbl.businessId.isNull());
    }
    return (query..orderBy([(tbl) => OrderingTerm.asc(tbl.nameBn)])).get();
  }

  Future<List<Category>> getSubcategories(String parentCategoryId, {String? businessId, bool activeOnly = true}) {
    var query = db.select(db.categories)
      ..where((tbl) => tbl.parentId.equals(parentCategoryId));
    if (activeOnly) {
      query = query..where((tbl) => tbl.isActive.equals(1));
    }
    if (businessId != null) {
      query = query..where((tbl) => tbl.businessId.isNull() | tbl.businessId.equals(businessId));
    }
    return (query..orderBy([(tbl) => OrderingTerm.asc(tbl.nameBn)])).get();
  }

  Future<bool> updateCategory(Category entry) {
    return db.update(db.categories).replace(entry);
  }

  Future<void> archiveCategory(String categoryId) async {
    await (db.update(db.categories)..where((tbl) => tbl.id.equals(categoryId)))
        .write(const CategoriesCompanion(isActive: Value(0)));
  }

  // --- Transactions & Double-Entry Journal ---
  Future<Transaction?> getTransactionById(String id) {
    return (db.select(db.transactions)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<Transaction>> watchTransactions({int limit = 50}) {
    return (db.select(db.transactions)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.transactionDate)])
          ..limit(limit))
        .watch();
  }

  Future<List<Transaction>> getTransactionsInRange(int startMs, int endMs,
      {String? scopeType}) {
    var query = db.select(db.transactions)
      ..where((tbl) =>
          tbl.deletedAt.isNull() &
          tbl.transactionDate.isBiggerOrEqualValue(startMs) &
          tbl.transactionDate.isSmallerOrEqualValue(endMs));
    if (scopeType != null) {
      query = query..where((tbl) => tbl.scopeType.equals(scopeType));
    }
    return query.get();
  }

  /// Posts transaction atomically with double-entry journal entries
  Future<void> postTransaction({
    required TransactionsCompanion transaction,
    required List<TransactionEntriesCompanion> entries,
  }) async {
    // Validate double-entry balance: Sum(Debit) == Sum(Credit)
    int totalDebit = 0;
    int totalCredit = 0;
    for (var entry in entries) {
      totalDebit += entry.debitMinor.value;
      totalCredit += entry.creditMinor.value;
    }

    if (totalDebit != totalCredit) {
      throw Exception(
          'Double-entry imbalance! Total Debit ($totalDebit) != Total Credit ($totalCredit)');
    }

    await db.transaction(() async {
      await db.into(db.transactions).insert(transaction);
      for (var entry in entries) {
        await db.into(db.transactionEntries).insert(entry);
      }
    });
  }

  Future<void> softDeleteTransaction(String transactionId) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (db.update(db.transactions)
          ..where((tbl) => tbl.id.equals(transactionId)))
        .write(TransactionsCompanion(deletedAt: Value(now)));
  }
}
