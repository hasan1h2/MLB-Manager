import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class BusinessDashboardMetrics {
  final int totalInvestmentMinor;
  final int totalSalesMinor;
  final int totalPurchasesMinor;
  final int operatingExpensesMinor;
  final int grossProfitMinor;
  final int netProfitMinor;
  final int inventoryValueMinor;
  final int customerReceivablesMinor;
  final int supplierPayablesMinor;

  BusinessDashboardMetrics({
    required this.totalInvestmentMinor,
    required this.totalSalesMinor,
    required this.totalPurchasesMinor,
    required this.operatingExpensesMinor,
    required this.grossProfitMinor,
    required this.netProfitMinor,
    required this.inventoryValueMinor,
    required this.customerReceivablesMinor,
    required this.supplierPayablesMinor,
  });
}

class BusinessController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<BusinessesData> businesses = <BusinessesData>[].obs;
  final RxBool isLoading = true.obs;

  // Selected Business Dashboard Metrics
  final Rx<BusinessesData?> selectedBusiness = Rx<BusinessesData?>(null);
  final Rx<BusinessDashboardMetrics?> currentMetrics = Rx<BusinessDashboardMetrics?>(null);

  // Form Fields
  final nameController = TextEditingController();
  final initialCapitalController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedType = 'grocery'.obs;

  @override
  void onInit() {
    super.onInit();
    watchBusinesses();
  }

  void watchBusinesses() {
    _dbService.businessDao.watchBusinesses().listen((list) {
      businesses.value = list;
      isLoading.value = false;
      if (selectedBusiness.value == null && list.isNotEmpty) {
        selectBusinessForDashboard(list.first);
      }
    });
  }

  Future<void> selectBusinessForDashboard(BusinessesData business) async {
    selectedBusiness.value = business;
    await calculateMetrics(business.id);
  }

  Future<void> calculateMetrics(String businessId) async {
    final business = await _dbService.businessDao.getBusinessById(businessId);
    if (business == null) return;

    // Total sales
    final sales = await (_dbService.database.selectOnly(_dbService.database.salesRecords)
          ..addColumns([_dbService.database.salesRecords.totalMinor.sum()])
          ..where(_dbService.database.salesRecords.businessId.equals(businessId)))
        .getSingle();
    final int totalSales = sales.read(_dbService.database.salesRecords.totalMinor.sum()) ?? 0;

    // Total purchases
    final purchases = await (_dbService.database.selectOnly(_dbService.database.purchaseRecords)
          ..addColumns([_dbService.database.purchaseRecords.totalMinor.sum()])
          ..where(_dbService.database.purchaseRecords.businessId.equals(businessId)))
        .getSingle();
    final int totalPurchases = purchases.read(_dbService.database.purchaseRecords.totalMinor.sum()) ?? 0;

    // Operating expenses
    final opExp = await (_dbService.database.selectOnly(_dbService.database.transactions)
          ..addColumns([_dbService.database.transactions.amountMinor.sum()])
          ..where(_dbService.database.transactions.businessId.equals(businessId) &
              _dbService.database.transactions.transactionType.equals('expense') &
              _dbService.database.transactions.deletedAt.isNull()))
        .getSingle();
    final int operatingExpenses = opExp.read(_dbService.database.transactions.amountMinor.sum()) ?? 0;

    // Gross Profit = Sales - Purchases
    final int grossProfit = totalSales - totalPurchases;
    // Net Profit = Gross Profit - Operating Expenses
    final int netProfit = grossProfit - operatingExpenses;

    // Receivables
    int receivables = 0;
    final customers = await _dbService.businessDao.getAllCustomers(businessId);
    for (var c in customers) {
      receivables += await _dbService.businessDao.getCustomerOutstandingDue(c.id);
    }

    // Payables
    int payables = 0;
    final suppliers = await _dbService.businessDao.getAllSuppliers(businessId);
    for (var s in suppliers) {
      payables += await _dbService.businessDao.getSupplierOutstandingPayable(s.id);
    }

    // Inventory Value
    int invValue = 0;
    final products = await _dbService.inventoryDao.getAllProducts(businessId);
    for (var p in products) {
      final stock = await _dbService.inventoryDao.getProductCurrentStock(p.id);
      invValue += (stock * p.purchasePriceMinor).round();
    }

    currentMetrics.value = BusinessDashboardMetrics(
      totalInvestmentMinor: business.initialCapitalMinor,
      totalSalesMinor: totalSales,
      totalPurchasesMinor: totalPurchases,
      operatingExpensesMinor: operatingExpenses,
      grossProfitMinor: grossProfit,
      netProfitMinor: netProfit,
      inventoryValueMinor: invValue,
      customerReceivablesMinor: receivables,
      supplierPayablesMinor: payables,
    );
  }

  Future<bool> saveBusiness() async {
    if (nameController.text.trim().isEmpty) {
      AppSnackbar.error('ব্যবসার নাম লিখুন');
      return false;
    }

    final capital = CurrencyUtils.takaToMinor(initialCapitalController.text);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    try {
      await _dbService.businessDao.insertBusiness(
        BusinessesCompanion(
          id: Value(_uuid.v4()),
          name: Value(nameController.text.trim()),
          businessType: Value(selectedType.value),
          description: Value(descriptionController.text.trim()),
          openingDate: Value(now),
          initialCapitalMinor: Value(capital),
          location: Value(locationController.text.trim()),
          phone: Value(phoneController.text.trim()),
          status: const Value('active'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      AppSnackbar.success('ব্যবসা সফলভাবে যুক্ত হয়েছে');
      nameController.clear();
      initialCapitalController.clear();
      locationController.clear();
      phoneController.clear();
      descriptionController.clear();
      return true;
    } catch (e) {
      AppSnackbar.error('Error: $e');
      return false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    initialCapitalController.dispose();
    locationController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
