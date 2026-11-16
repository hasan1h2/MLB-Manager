import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/date_utils.dart';

class DashboardController extends GetxController {
  DatabaseService get _dbService => Get.find<DatabaseService>();

  final RxString selectedFilter = 'filter_this_month'.obs;
  final RxBool isLoading = true.obs;

  // Real-time calculated financial metrics (all in integer minor units - Poisha)
  final RxInt totalAvailableBalanceMinor = 0.obs;
  final RxInt totalIncomeMinor = 0.obs;
  final RxInt totalExpensesMinor = 0.obs;
  final RxInt businessProfitMinor = 0.obs;
  final RxInt moneyReceivableMinor = 0.obs;
  final RxInt moneyPayableMinor = 0.obs;
  final RxInt totalSavingsMinor = 0.obs;
  final RxInt totalAssetsMinor = 0.obs;

  final RxList<Transaction> recentTransactions = <Transaction>[].obs;
  final RxList<Product> lowStockProducts = <Product>[].obs;
  final RxList<Reminder> upcomingReminders = <Reminder>[].obs;

  StreamSubscription<List<Transaction>>? _txSubscription;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    _subscribeRecentTransactions();
  }

  void _subscribeRecentTransactions() {
    _txSubscription?.cancel();
    try {
      _txSubscription = _dbService.coreDao.watchTransactions(limit: 5).listen(
        (list) {
          recentTransactions.value = list;
        },
        onError: (e) {
          debugPrint('Error in watchTransactions: $e');
        },
      );
    } catch (e) {
      debugPrint('Failed to watch transactions: $e');
    }
  }

  Future<void> setDateFilter(String filterKey) async {
    selectedFilter.value = filterKey;
    await loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      final range = AppDateUtils.getFilterRange(selectedFilter.value);

      // 1. Total Available Balance across all active accounts
      final accounts = await _dbService.coreDao.getAllAccounts();
      int totalBal = 0;
      for (var acc in accounts) {
        totalBal += await _dbService.coreDao.getAccountBalance(acc.id);
      }
      totalAvailableBalanceMinor.value = totalBal;

      // 2. Total Income & Expense in filter date range (excluding internal transfers)
      final txs = await _dbService.coreDao.getTransactionsInRange(range.startMs, range.endMs);
      int income = 0;
      int expense = 0;
      int busProfit = 0;

      for (var tx in txs) {
        if (tx.transactionType == 'income') {
          income += tx.amountMinor;
          if (tx.scopeType == 'business') {
            busProfit += tx.amountMinor;
          }
        } else if (tx.transactionType == 'expense') {
          expense += tx.amountMinor;
          if (tx.scopeType == 'business') {
            busProfit -= tx.amountMinor;
          }
        }
      }
      totalIncomeMinor.value = income;
      totalExpensesMinor.value = expense;
      businessProfitMinor.value = busProfit;

      // 3. Money Receivable (Customer dues + Loan receivables)
      int receivable = 0;
      final loansRec = await _dbService.loanDao.getLoans(loanType: 'receivable', status: 'active');
      for (var l in loansRec) {
        receivable += await _dbService.loanDao.getLoanRemainingPrincipal(l.id);
      }
      final businesses = await _dbService.businessDao.getAllBusinesses();
      for (var b in businesses) {
        final custs = await _dbService.businessDao.getAllCustomers(b.id);
        for (var c in custs) {
          receivable += await _dbService.businessDao.getCustomerOutstandingDue(c.id);
        }
      }
      moneyReceivableMinor.value = receivable;

      // 4. Money Payable (Supplier payables + Loan payables)
      int payable = 0;
      final loansPay = await _dbService.loanDao.getLoans(loanType: 'payable', status: 'active');
      for (var l in loansPay) {
        payable += await _dbService.loanDao.getLoanRemainingPrincipal(l.id);
      }
      for (var b in businesses) {
        final supps = await _dbService.businessDao.getAllSuppliers(b.id);
        for (var s in supps) {
          payable += await _dbService.businessDao.getSupplierOutstandingPayable(s.id);
        }
      }
      moneyPayableMinor.value = payable;

      // 5. Total Savings
      final savings = await _dbService.assetDao.getAllSavingsGoals();
      int totalSav = 0;
      for (var s in savings) {
        totalSav += s.currentAmountMinor;
      }
      totalSavingsMinor.value = totalSav;

      // 6. Total Assets
      final assets = await _dbService.assetDao.getAllAssets();
      int totalAst = 0;
      for (var a in assets) {
        totalAst += a.currentValueMinor;
      }
      totalAssetsMinor.value = totalAst;

      // 7. Recent Transactions (snapshot)
      final allRecent = await _dbService.coreDao.getTransactionsInRange(0, DateTime.now().millisecondsSinceEpoch + 86400000);
      recentTransactions.value = allRecent.take(5).toList();

      // 8. Low Stock
      final allProducts = <Product>[];
      for (var b in businesses) {
        final prods = await _dbService.inventoryDao.getAllProducts(b.id);
        for (var p in prods) {
          final stock = await _dbService.inventoryDao.getProductCurrentStock(p.id);
          if (stock <= p.minimumStock) {
            allProducts.add(p);
          }
        }
      }
      lowStockProducts.value = allProducts;

      // 9. Upcoming Reminders
      final reminders = await _dbService.budgetDao.getPendingReminders();
      upcomingReminders.value = reminders.take(5).toList();
    } catch (e, st) {
      debugPrint('Error loading dashboard data: $e\n$st');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _txSubscription?.cancel();
    super.onClose();
  }
}
