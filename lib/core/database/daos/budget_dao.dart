import 'package:drift/drift.dart';
import '../app_database.dart';

class BudgetDao {
  final AppDatabase db;
  BudgetDao(this.db);

  // --- Budgets ---
  Stream<List<Budget>> watchBudgets() {
    return (db.select(db.budgets)..where((tbl) => tbl.status.equals('active'))).watch();
  }

  Future<List<Budget>> getActiveBudgets() {
    return (db.select(db.budgets)..where((tbl) => tbl.status.equals('active'))).get();
  }

  Future<int> insertBudget(BudgetsCompanion budget) {
    return db.into(db.budgets).insert(budget);
  }

  /// Calculates actual spending within the budget period and category/scope
  Future<int> getActualSpendingForBudget(Budget budget) async {
    var query = db.selectOnly(db.transactions)
      ..addColumns([db.transactions.amountMinor.sum()])
      ..where(
        db.transactions.deletedAt.isNull() &
        db.transactions.transactionType.equals('expense') &
        db.transactions.transactionDate.isBiggerOrEqualValue(budget.startDate) &
        db.transactions.transactionDate.isSmallerOrEqualValue(budget.endDate),
      );

    if (budget.categoryId != null) {
      query = query..where(db.transactions.categoryId.equals(budget.categoryId!));
    }
    if (budget.businessId != null) {
      query = query..where(db.transactions.businessId.equals(budget.businessId!));
    } else if (budget.scopeType != 'business') {
      query = query..where(db.transactions.scopeType.equals(budget.scopeType));
    }

    final result = await query.getSingle();
    return result.read(db.transactions.amountMinor.sum()) ?? 0;
  }

  // --- Reminders ---
  Stream<List<Reminder>> watchReminders({bool pendingOnly = true}) {
    var query = db.select(db.reminders);
    if (pendingOnly) {
      query = query..where((tbl) => tbl.isCompleted.equals(0));
    }
    return (query..orderBy([(tbl) => OrderingTerm.asc(tbl.scheduledAt)])).watch();
  }

  Future<List<Reminder>> getPendingReminders() {
    return (db.select(db.reminders)
          ..where((tbl) => tbl.isCompleted.equals(0))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.scheduledAt)]))
        .get();
  }

  Future<int> insertReminder(RemindersCompanion reminder) {
    return db.into(db.reminders).insert(reminder);
  }

  Future<void> markReminderCompleted(String reminderId) async {
    await (db.update(db.reminders)..where((tbl) => tbl.id.equals(reminderId)))
        .write(const RemindersCompanion(isCompleted: Value(1)));
  }
}
