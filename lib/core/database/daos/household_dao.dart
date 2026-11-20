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

  Future<ShoppingRecord?> getShoppingRecordById(String id) {
    return (db.select(db.shoppingRecords)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<ShoppingItem>> getAllShoppingItems() {
    return db.select(db.shoppingItems).get();
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

  /// Atomically deletes a shopping record, its items, and reverses/deletes the linked journal transaction
  Future<void> deleteShoppingRecordWithItems(String recordId) async {
    await db.transaction(() async {
      // Find linked transactions
      final linkedTxs = await (db.select(db.transactions)
            ..where((tbl) => tbl.sourceId.equals(recordId)))
          .get();

      for (var tx in linkedTxs) {
        // Delete journal entries for this transaction
        await (db.delete(db.transactionEntries)
              ..where((tbl) => tbl.transactionId.equals(tx.id)))
            .go();
        // Delete the transaction
        await (db.delete(db.transactions)
              ..where((tbl) => tbl.id.equals(tx.id)))
            .go();
      }

      // Delete child shopping items
      await (db.delete(db.shoppingItems)
            ..where((tbl) => tbl.shoppingRecordId.equals(recordId)))
          .go();

      // Delete the shopping record
      await (db.delete(db.shoppingRecords)
            ..where((tbl) => tbl.id.equals(recordId)))
          .go();
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
