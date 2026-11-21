import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/active_business_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class CashbookController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ActiveBusinessService _activeBizService = Get.find<ActiveBusinessService>();
  final _uuid = const Uuid();

  Rx<BusinessesData?> get currentBusiness => _activeBizService.activeBusiness;
  final Rx<CashSession?> activeSession = Rx<CashSession?>(null);
  final RxList<CashSession> pastSessions = <CashSession>[].obs;
  final RxBool isLoading = true.obs;

  // Opening Cash Form
  final openingCashController = TextEditingController(text: '0');
  final openingNotesController = TextEditingController();

  // Inflows & Outflows for Today
  final RxInt todayCashSalesMinor = 0.obs;
  final RxInt todayCustomerCollectionsMinor = 0.obs;
  final RxInt todayCashPurchasesMinor = 0.obs;
  final RxInt todayCashExpensesMinor = 0.obs;
  final RxInt todaySupplierPaymentsMinor = 0.obs;

  // Denominations Counter (BDT Notes)
  final count1000 = TextEditingController(text: '0');
  final count500 = TextEditingController(text: '0');
  final count200 = TextEditingController(text: '0');
  final count100 = TextEditingController(text: '0');
  final count50 = TextEditingController(text: '0');
  final count20 = TextEditingController(text: '0');
  final count10 = TextEditingController(text: '0');
  final count5 = TextEditingController(text: '0');
  final count2 = TextEditingController(text: '0');
  final count1 = TextEditingController(text: '0');

  // Manual Closing Entry (Alternative to denomination counter)
  final manualClosingController = TextEditingController();
  final RxBool useManualClosing = false.obs;
  final closingNotesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    ever(_activeBizService.activeBusiness, (BusinessesData? b) {
      if (b != null) {
        loadSession(b.id);
      } else {
        activeSession.value = null;
        pastSessions.clear();
      }
    });

    initCashbook();
  }

  Future<void> initCashbook() async {
    final b = _activeBizService.activeBusiness.value;
    if (b != null) {
      await loadSession(b.id);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> loadSession(String businessId) async {
    try {
      isLoading.value = true;
      final session = await _dbService.businessDao.getOpenCashSession(businessId);
      activeSession.value = session;

      // Watch history
      _dbService.businessDao.watchCashSessions(businessId).listen((list) {
        pastSessions.value = list;
      });

      await calculateTodayCashFlow(businessId, session?.openingCashMinor ?? 0);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> calculateTodayCashFlow(String businessId, int openingMinor) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;

    // Today's Sales paid in cash
    final sales = await _dbService.businessDao.getSales(businessId, startDate: startOfDay, endDate: endOfDay);
    int cashSales = 0;
    for (var s in sales) {
      if (s.paidMinor > 0 && s.paymentMethod != 'bank') {
        cashSales += s.paidMinor;
      }
    }
    todayCashSalesMinor.value = cashSales;

    // Today's Purchases paid in cash
    final purchases = await _dbService.businessDao.getPurchases(businessId, startDate: startOfDay, endDate: endOfDay);
    int cashPurchases = 0;
    for (var p in purchases) {
      if (p.paidMinor > 0 && p.paymentMethod != 'bank') {
        cashPurchases += p.paidMinor;
      }
    }
    todayCashPurchasesMinor.value = cashPurchases;

    // Today's Business Cash Expenses
    final expList = await (_dbService.database.select(_dbService.database.transactions)
          ..where((t) =>
              t.businessId.equals(businessId) &
              t.transactionType.equals('expense') &
              t.transactionDate.isBiggerOrEqualValue(startOfDay) &
              t.transactionDate.isSmallerOrEqualValue(endOfDay) &
              t.deletedAt.isNull() &
              (t.sourceType.isNull() | t.sourceType.equals('manual'))))
        .get();
    int cashExpenses = 0;
    for (var e in expList) {
      cashExpenses += e.amountMinor;
    }
    todayCashExpensesMinor.value = cashExpenses;

    // Today's Customer Collections
    final collections = await (_dbService.database.select(_dbService.database.partyPayments)
          ..where((t) =>
              t.businessId.equals(businessId) &
              t.partyType.equals('customer') &
              t.paymentDate.isBiggerOrEqualValue(startOfDay) &
              t.paymentDate.isSmallerOrEqualValue(endOfDay)))
        .get();
    int custCollections = 0;
    for (var c in collections) {
      custCollections += c.amountMinor;
    }
    todayCustomerCollectionsMinor.value = custCollections;

    // Today's Supplier Payments
    final suppPayments = await (_dbService.database.select(_dbService.database.partyPayments)
          ..where((t) =>
              t.businessId.equals(businessId) &
              t.partyType.equals('supplier') &
              t.paymentDate.isBiggerOrEqualValue(startOfDay) &
              t.paymentDate.isSmallerOrEqualValue(endOfDay)))
        .get();
    int suppPaid = 0;
    for (var s in suppPayments) {
      suppPaid += s.amountMinor;
    }
    todaySupplierPaymentsMinor.value = suppPaid;
  }

  int get expectedClosingCashMinor {
    final opening = activeSession.value?.openingCashMinor ?? 0;
    final totalIn = todayCashSalesMinor.value + todayCustomerCollectionsMinor.value;
    final totalOut = todayCashPurchasesMinor.value + todayCashExpensesMinor.value + todaySupplierPaymentsMinor.value;
    final exp = opening + totalIn - totalOut;
    return exp > 0 ? exp : 0;
  }

  int get actualCountedCashMinor {
    if (useManualClosing.value) {
      return CurrencyUtils.takaToMinor(manualClosingController.text);
    }
    final n1000 = (int.tryParse(count1000.text) ?? 0) * 1000;
    final n500 = (int.tryParse(count500.text) ?? 0) * 500;
    final n200 = (int.tryParse(count200.text) ?? 0) * 200;
    final n100 = (int.tryParse(count100.text) ?? 0) * 100;
    final n50 = (int.tryParse(count50.text) ?? 0) * 50;
    final n20 = (int.tryParse(count20.text) ?? 0) * 20;
    final n10 = (int.tryParse(count10.text) ?? 0) * 10;
    final n5 = (int.tryParse(count5.text) ?? 0) * 5;
    final n2 = (int.tryParse(count2.text) ?? 0) * 2;
    final n1 = (int.tryParse(count1.text) ?? 0) * 1;
    final totalTaka = n1000 + n500 + n200 + n100 + n50 + n20 + n10 + n5 + n2 + n1;
    return totalTaka * 100;
  }

  int get differenceMinor => actualCountedCashMinor - expectedClosingCashMinor;

  Future<bool> startSession() async {
    final biz = _activeBizService.activeBusiness.value;
    if (biz == null) return false;
    final openingMinor = CurrencyUtils.takaToMinor(openingCashController.text);
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    try {
      final sessionId = _uuid.v4();
      await _dbService.businessDao.openCashSession(
        CashSessionsCompanion(
          id: Value(sessionId),
          businessId: Value(biz.id),
          sessionDate: Value(todayMidnight),
          openingCashMinor: Value(openingMinor),
          expectedClosingMinor: Value(openingMinor),
          status: const Value('open'),
          notes: Value(openingNotesController.text.trim().isNotEmpty
              ? openingNotesController.text.trim()
              : null),
          openedAt: Value(now.millisecondsSinceEpoch),
        ),
      );

      AppSnackbar.success('দৈনিক ক্যাশ হিসাব শুরু হয়েছে');
      await loadSession(biz.id);
      return true;
    } catch (e) {
      AppSnackbar.error('ত্রুটি: $e');
      return false;
    }
  }

  Future<bool> closeSession() async {
    if (activeSession.value == null) return false;
    final session = activeSession.value!;
    final actual = actualCountedCashMinor;
    final diff = differenceMinor;
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      await _dbService.businessDao.closeCashSession(
        sessionId: session.id,
        actualClosingMinor: actual,
        differenceMinor: diff,
        notes: closingNotesController.text.trim().isNotEmpty
            ? closingNotesController.text.trim()
            : null,
        closedAt: now,
      );

      AppSnackbar.success('আজকের ক্যাশ ক্লোজিং সম্পন্ন হয়েছে');
      await loadSession(session.businessId);
      return true;
    } catch (e) {
      AppSnackbar.error('ত্রুটি: $e');
      return false;
    }
  }

  @override
  void onClose() {
    openingCashController.dispose();
    openingNotesController.dispose();
    manualClosingController.dispose();
    closingNotesController.dispose();
    count1000.dispose();
    count500.dispose();
    count200.dispose();
    count100.dispose();
    count50.dispose();
    count20.dispose();
    count10.dispose();
    count5.dispose();
    count2.dispose();
    count1.dispose();
    super.onClose();
  }
}
