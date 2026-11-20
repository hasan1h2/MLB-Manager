import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../constants/app_constants.dart';
import 'tables/core_tables.dart';
import 'tables/household_tables.dart';
import 'tables/party_tables.dart';
import 'tables/inventory_tables.dart';
import 'tables/cattle_tables.dart';
import 'tables/loan_tables.dart';
import 'tables/asset_tables.dart';
import 'tables/budget_tables.dart';
import 'tables/app_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    FamilyMembers,
    Businesses,
    Accounts,
    Categories,
    Transactions,
    TransactionEntries,
    TransactionAttachments,
    ShoppingRecords,
    ShoppingItems,
    ShoppingLists,
    ShoppingListItems,
    Customers,
    Suppliers,
    PartyPayments,
    Products,
    InventoryMovements,
    PurchaseRecords,
    PurchaseItems,
    SalesRecords,
    SalesItems,
    Cattle,
    CattleExpenses,
    CattleSales,
    LoanAccounts,
    LoanPayments,
    Assets,
    SavingsGoals,
    Investments,
    Budgets,
    Reminders,
    AiExtractions,
    AppSettings,
    AuditLogs,
    Attachments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
        },
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(transactions, transactions.purchaseTime);
            await m.addColumn(shoppingRecords, shoppingRecords.purchaseTime);
            await m.addColumn(shoppingRecords, shoppingRecords.entryMode);
            await m.addColumn(shoppingItems, shoppingItems.note);
            await m.addColumn(shoppingItems, shoppingItems.imagePath);
          }
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: AppConstants.databaseName);
}
