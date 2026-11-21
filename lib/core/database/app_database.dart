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
    ProductUnitConversions,
    ProductPriceTiers,
    InventoryMovements,
    PurchaseRecords,
    PurchaseItems,
    SalesRecords,
    SalesItems,
    CashSessions,
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
          if (from < 3) {
            await m.createTable(productPriceTiers);
            await m.createTable(cashSessions);

            await m.addColumn(products, products.nameBn);
            await m.addColumn(products, products.nameEn);
            await m.addColumn(products, products.wholesalePriceMinor);
            await m.addColumn(products, products.brand);
            await m.addColumn(products, products.imagePath);
            await m.addColumn(products, products.description);
            await m.addColumn(products, products.expiryDate);
            await m.addColumn(products, products.batchNumber);
            await m.addColumn(products, products.defaultSupplierId);

            await m.addColumn(purchaseRecords, purchaseRecords.purchaseTime);
            await m.addColumn(purchaseRecords, purchaseRecords.isCustomDateTime);
            await m.addColumn(purchaseRecords, purchaseRecords.invoiceNumber);
            await m.addColumn(purchaseRecords, purchaseRecords.paymentMethod);
            await m.addColumn(purchaseRecords, purchaseRecords.notes);
            await m.addColumn(purchaseRecords, purchaseRecords.createdAt);
            await m.addColumn(purchaseRecords, purchaseRecords.updatedAt);

            await m.addColumn(purchaseItems, purchaseItems.productName);
            await m.addColumn(purchaseItems, purchaseItems.unit);

            await m.addColumn(salesRecords, salesRecords.saleTime);
            await m.addColumn(salesRecords, salesRecords.isCustomDateTime);
            await m.addColumn(salesRecords, salesRecords.invoiceNumber);
            await m.addColumn(salesRecords, salesRecords.saleType);
            await m.addColumn(salesRecords, salesRecords.paymentMethod);
            await m.addColumn(salesRecords, salesRecords.notes);
            await m.addColumn(salesRecords, salesRecords.createdAt);
            await m.addColumn(salesRecords, salesRecords.updatedAt);

            await m.addColumn(salesItems, salesItems.productName);
            await m.addColumn(salesItems, salesItems.unit);

            await m.addColumn(businesses, businesses.currency);
            await m.addColumn(businesses, businesses.timeFormat);
            await m.addColumn(businesses, businesses.allowNegativeStock);
            await m.addColumn(businesses, businesses.costingMethod);

            await m.addColumn(customers, customers.company);
            await m.addColumn(customers, customers.customerType);
            await m.addColumn(customers, customers.creditLimitMinor);

            await m.addColumn(suppliers, suppliers.company);
          }
          if (from < 4) {
            await m.addColumn(categories, categories.businessId);
            await m.addColumn(categories, categories.isActive);

            await m.addColumn(products, products.subcategoryId);
            await m.addColumn(products, products.packageUnit);
            await m.addColumn(products, products.packageQuantity);

            await m.createTable(productUnitConversions);

            await m.addColumn(purchaseItems, purchaseItems.conversionFactor);
            await m.addColumn(purchaseItems, purchaseItems.baseQuantity);
            await m.addColumn(purchaseItems, purchaseItems.retailPriceMinor);
            await m.addColumn(purchaseItems, purchaseItems.wholesalePriceMinor);

            await m.addColumn(salesItems, salesItems.conversionFactor);
            await m.addColumn(salesItems, salesItems.baseQuantity);
          }
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: AppConstants.databaseName);
}
