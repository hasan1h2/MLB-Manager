import 'package:drift/drift.dart';
import '../app_database.dart';

class HouseholdDao {
  final AppDatabase db;
  HouseholdDao(this.db);

  Stream<List<ShoppingRecord>> watchShoppingRecords({int limit = 50}) {
    return (db.select(db.shoppingRecords)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.shoppingDate)])
          ..limit(limit))
        .watch();
  }

  Future<List<ShoppingRecord>> getShoppingRecordsInRange(
      int startMs, int endMs) {
    return (db.select(db.shoppingRecords)
          ..where((tbl) =>
              tbl.shoppingDate.isBiggerOrEqualValue(startMs) &
              tbl.shoppingDate.isSmallerOrEqualValue(endMs))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.shoppingDate)]))
        .get();
  }

  Future<List<ShoppingItem>> getItemsForRecord(String recordId) {
    return (db.select(db.shoppingItems)
          ..where((tbl) => tbl.shoppingRecordId.equals(recordId)))
        .get();
  }

  /// Inserts a shopping record with line items atomically.
  /// If [expenseTransaction] and [journalEntries] are provided, posts the linked household expense
  /// transaction simultaneously so shopping expenses are never duplicated.
  Future<void> postShoppingRecordWithItems({
    required ShoppingRecordsCompanion record,
    required List<ShoppingItemsCompanion> items,
    TransactionsCompanion? expenseTransaction,
    List<TransactionEntriesCompanion>? journalEntries,
  }) async {
    await db.transaction(() async {
      await db.into(db.shoppingRecords).insert(record);
      for (var item in items) {
        await db.into(db.shoppingItems).insert(item);
      }
      if (expenseTransaction != null && journalEntries != null) {
        await db.into(db.transactions).insert(expenseTransaction);
        for (var entry in journalEntries) {
          await db.into(db.transactionEntries).insert(entry);
        }
      }
    });
  }

  // --- Shopping Lists ---
  Stream<List<ShoppingList>> watchShoppingLists() {
    return (db.select(db.shoppingLists)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  Future<List<ShoppingListItem>> getShoppingListItems(String listId) {
    return (db.select(db.shoppingListItems)
          ..where((tbl) => tbl.shoppingListId.equals(listId)))
        .get();
  }

  Stream<List<ShoppingListItem>> watchShoppingListItems(String listId) {
    return (db.select(db.shoppingListItems)
          ..where((tbl) => tbl.shoppingListId.equals(listId)))
        .watch();
  }

  Future<int> insertShoppingList(ShoppingListsCompanion list) {
    return db.into(db.shoppingLists).insert(list);
  }

  Future<int> insertShoppingListItem(ShoppingListItemsCompanion item) {
    return db.into(db.shoppingListItems).insert(item);
  }

  Future<void> toggleListItemPurchased(String itemId, bool isPurchased) async {
    await (db.update(db.shoppingListItems)
          ..where((tbl) => tbl.id.equals(itemId)))
        .write(ShoppingListItemsCompanion(
            isPurchased: Value(isPurchased ? 1 : 0)));
  }
}
