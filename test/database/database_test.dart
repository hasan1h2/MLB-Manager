import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mlb_manager/core/database/app_database.dart';
import 'package:mlb_manager/core/database/daos/core_dao.dart';
import 'package:mlb_manager/core/database/daos/cattle_dao.dart';
import 'package:mlb_manager/core/database/daos/inventory_dao.dart';
import 'package:mlb_manager/core/database/daos/loan_dao.dart';

void main() {
  late AppDatabase db;
  late CoreDao coreDao;
  late CattleDao cattleDao;
  late InventoryDao inventoryDao;
  late LoanDao loanDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    coreDao = CoreDao(db);
    cattleDao = CattleDao(db);
    inventoryDao = InventoryDao(db);
    loanDao = LoanDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift In-Memory Database Tests', () {
    test('Can insert and retrieve Family Members', () async {
      const id = 'mem-1';
      final now = DateTime.now().millisecondsSinceEpoch;

      await coreDao.insertFamilyMember(
        FamilyMembersCompanion(
          id: const Value(id),
          name: const Value('মালিক (Owner)'),
          role: const Value('owner'),
          isActive: const Value(1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final member = await coreDao.getFamilyMemberById(id);
      expect(member, isNotNull);
      expect(member!.name, equals('মালিক (Owner)'));
      expect(member.role, equals('owner'));
    });

    test(
        'Can insert Accounts and compute balance from atomic double-entry journal',
        () async {
      const accId = 'acc-cash';
      const offsetAccId = 'acc-income-offset';
      const now = 1700000000000;

      await coreDao.insertAccount(
        const AccountsCompanion(
          id: Value(accId),
          name: Value('নগদ ক্যাশ'),
          accountType: Value('cash'),
          openingBalanceMinor: Value(50000), // 500 BDT opening
          isActive: Value(1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await coreDao.insertAccount(
        const AccountsCompanion(
          id: Value(offsetAccId),
          name: Value('আয় হিসাব'),
          accountType: Value('custom'),
          openingBalanceMinor: Value(0),
          isActive: Value(1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      // Verify opening balance
      int balance = await coreDao.getAccountBalance(accId);
      expect(balance, equals(50000));

      // Post atomic income transaction of 200 BDT (20,000 Poisha)
      const txId = 'tx-1';
      await coreDao.postTransaction(
        transaction: const TransactionsCompanion(
          id: Value(txId),
          transactionNumber: Value('TX-1001'),
          transactionType: Value('income'),
          scopeType: Value('personal'),
          accountId: Value(accId),
          amountMinor: Value(20000),
          transactionDate: Value(now),
          paymentStatus: Value('paid'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        entries: [
          const TransactionEntriesCompanion(
            id: Value('ent-1'),
            transactionId: Value(txId),
            accountId: Value(accId),
            debitMinor: Value(0),
            creditMinor: Value(20000), // Inflow to cash
            createdAt: Value(now),
          ),
          const TransactionEntriesCompanion(
            id: Value('ent-2'),
            transactionId: Value(txId),
            accountId: Value(offsetAccId),
            debitMinor: Value(20000), // Balancing entry
            creditMinor: Value(0),
            createdAt: Value(now),
          ),
        ],
      );

      balance = await coreDao.getAccountBalance(accId);
      expect(balance, equals(70000)); // 500 + 200 = 700 BDT
    });

    test(
        'Enforces atomic transaction rollback if double-entry sum is not balanced',
        () async {
      const txId = 'tx-imbalanced';
      const now = 1700000000000;

      expect(
        () async => await coreDao.postTransaction(
          transaction: const TransactionsCompanion(
            id: Value(txId),
            transactionNumber: Value('TX-ERR'),
            transactionType: Value('expense'),
            scopeType: Value('personal'),
            amountMinor: Value(50000),
            transactionDate: Value(now),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
          entries: [
            const TransactionEntriesCompanion(
              id: Value('ent-err1'),
              transactionId: Value(txId),
              accountId: Value('acc-1'),
              debitMinor: Value(50000),
              creditMinor: Value(0),
              createdAt: Value(now),
            ),
            const TransactionEntriesCompanion(
              id: Value('ent-err2'),
              transactionId: Value(txId),
              accountId: Value('acc-1'),
              debitMinor: Value(0),
              creditMinor: Value(40000), // Imbalanced! 50k != 40k
              createdAt: Value(now),
            ),
          ],
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Calculates Cattle Net Profit correctly in database', () async {
      const cattleId = 'cattle-01';
      const bizId = 'biz-01';
      const now = 1700000000000;

      await db.into(db.businesses).insert(
            const BusinessesCompanion(
              id: Value(bizId),
              name: Value('খামার'),
              businessType: Value('cattle'),
              openingDate: Value(now),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      await cattleDao.insertCattle(
        const CattleCompanion(
          id: Value(cattleId),
          businessId: Value(bizId),
          tagNumber: Value('TAG-99'),
          purchaseDate: Value(now),
          purchasePriceMinor: Value(8000000), // 80,000 BDT
          status: Value('active'),
          createdAt: Value(now),
        ),
      );

      // Add feed expense
      await cattleDao.insertCattleExpense(
        const CattleExpensesCompanion(
          id: Value('exp-1'),
          cattleId: Value(cattleId),
          expenseType: Value('feed'),
          amountMinor: Value(1500000), // 15,000 BDT
          expenseDate: Value(now),
        ),
      );

      var profitCalc = await cattleDao.calculateCattleProfit(cattleId);
      expect(profitCalc.totalExpensesMinor, equals(1500000));
      expect(profitCalc.totalCostMinor, equals(9500000));
      expect(profitCalc.isSold, isFalse);

      // Record Sale
      await cattleDao.recordCattleSale(
        sale: const CattleSalesCompanion(
          id: Value('sale-1'),
          cattleId: Value(cattleId),
          buyerName: Value('ক্রেতা'),
          saleDate: Value(now),
          salePriceMinor: Value(12000000), // 120,000 BDT
          paidMinor: Value(12000000),
          dueMinor: Value(0),
        ),
      );

      profitCalc = await cattleDao.calculateCattleProfit(cattleId);
      expect(profitCalc.isSold, isTrue);
      expect(profitCalc.netProfitMinor,
          equals(2500000)); // 120k - 95k = 25,000 BDT Net Profit
    });

    test('InventoryDao: Can insert product and calculate current stock',
        () async {
      const prodId = 'prod-001';
      const bizId = 'biz-01';
      const now = 1700000000000;

      await db.into(db.businesses).insert(
            const BusinessesCompanion(
              id: Value(bizId),
              name: Value('মুদি দোকান'),
              businessType: Value('retail'),
              openingDate: Value(now),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      await inventoryDao.insertProduct(
        const ProductsCompanion(
          id: Value(prodId),
          businessId: Value(bizId),
          name: Value('সয়াবিন তেল'),
          unit: Value('লিটার'),
          openingQuantity: Value(50.0),
          purchasePriceMinor: Value(16000), // 160 BDT
          sellingPriceMinor: Value(18500), // 185 BDT
          createdAt: Value(now),
        ),
      );

      final stock = await inventoryDao.getProductCurrentStock(prodId);
      expect(stock, equals(50.0));

      final fetched = await inventoryDao.getProductById(prodId);
      expect(fetched, isNotNull);
      expect(fetched?.name, equals('সয়াবিন তেল'));
    });

    test('LoanDao: Can insert loan account and fetch by id', () async {
      const loanId = 'loan-001';
      const now = 1700000000000;

      await loanDao.insertLoan(
        const LoanAccountsCompanion(
          id: Value(loanId),
          loanType: Value('receivable'),
          partyName: Value('করিম উদ্দিন'),
          principalMinor: Value(5000000), // 50,000 BDT
          startDate: Value(now),
          dueDate: Value(now + 864000000),
          status: Value('active'),
        ),
      );

      final loan = await loanDao.getLoanById(loanId);
      expect(loan, isNotNull);
      expect(loan?.partyName, equals('করিম উদ্দিন'));
      expect(loan?.principalMinor, equals(5000000));
    });
  });
}
