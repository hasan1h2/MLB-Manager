import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/business_dao.dart';
import '../../../../core/services/active_business_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class BusinessController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ActiveBusinessService _activeBizService = Get.find<ActiveBusinessService>();
  final _uuid = const Uuid();

  RxList<BusinessesData> get businesses => _activeBizService.allBusinesses;
  Rx<BusinessesData?> get selectedBusiness => _activeBizService.activeBusiness;
  RxBool get isLoading => _activeBizService.isLoading;

  final Rx<BusinessMetricsResult?> currentMetrics =
      Rx<BusinessMetricsResult?>(null);

  // Filter Chip for Dashboard: 'today', 'yesterday', 'last_7_days', 'this_month', 'last_month', 'this_year', 'custom'
  final RxString selectedPeriod = 'this_month'.obs;
  final Rx<DateTimeRange?> customDateRange = Rx<DateTimeRange?>(null);

  // Category-wise sales & top products for active period
  final RxList<CategorySalesResult> categorySales = <CategorySalesResult>[].obs;
  final RxList<TopProductResult> topProducts = <TopProductResult>[].obs;

  // Form Fields for Add Business
  final nameController = TextEditingController();
  final initialCapitalController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedType = 'retail'.obs; // retail, wholesale, hybrid, grocery, cattle

  // Form Fields for Business Settings
  final settingsNameController = TextEditingController();
  final settingsLocationController = TextEditingController();
  final settingsPhoneController = TextEditingController();
  final settingsDescriptionController = TextEditingController();
  final RxString settingsType = 'retail'.obs;
  final RxString settingsTimeFormat = '12h'.obs;
  final RxBool settingsAllowNegativeStock = false.obs;

  // Cash Session State
  final Rx<CashSession?> activeCashSession = Rx<CashSession?>(null);

  // Recent Sales & Purchases
  final RxList<SalesRecord> recentSales = <SalesRecord>[].obs;
  final RxList<PurchaseRecord> recentPurchases = <PurchaseRecord>[].obs;
  final RxList<Transaction> recentExpenses = <Transaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    // React to active business changes
    ever(_activeBizService.activeBusiness, (BusinessesData? b) {
      if (b != null) {
        _onActiveBusinessChanged(b);
      } else {
        currentMetrics.value = null;
        recentSales.clear();
        recentPurchases.clear();
        recentExpenses.clear();
        activeCashSession.value = null;
      }
    });

    if (_activeBizService.activeBusiness.value != null) {
      _onActiveBusinessChanged(_activeBizService.activeBusiness.value!);
    }
  }

  Future<void> _onActiveBusinessChanged(BusinessesData business) async {
    _populateSettingsForm(business);
    await calculateMetrics(business.id);
    await loadRecentTransactions(business.id);
    await checkCashSession(business.id);
  }

  Future<void> selectBusinessForDashboard(BusinessesData business) async {
    await _activeBizService.switchBusiness(business);
  }

  void _populateSettingsForm(BusinessesData business) {
    settingsNameController.text = business.name;
    settingsLocationController.text = business.location ?? '';
    settingsPhoneController.text = business.phone ?? '';
    settingsDescriptionController.text = business.description ?? '';
    settingsType.value = business.businessType;
    settingsTimeFormat.value = business.timeFormat;
    settingsAllowNegativeStock.value = business.allowNegativeStock == 1;
  }

  void setFilterPeriod(String period) {
    selectedPeriod.value = period;
    if (selectedBusiness.value != null) {
      calculateMetrics(selectedBusiness.value!.id);
    }
  }

  (int? start, int? end) _getFilterRange() {
    final now = DateTime.now();
    switch (selectedPeriod.value) {
      case 'today':
        final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;
        return (start, end);
      case 'yesterday':
        final y = now.subtract(const Duration(days: 1));
        final start = DateTime(y.year, y.month, y.day).millisecondsSinceEpoch;
        final end = DateTime(y.year, y.month, y.day, 23, 59, 59, 999).millisecondsSinceEpoch;
        return (start, end);
      case 'last_7_days':
        final start = now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;
        final end = now.millisecondsSinceEpoch;
        return (start, end);
      case 'this_month':
        final start = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999).millisecondsSinceEpoch;
        return (start, end);
      case 'last_month':
        final start = DateTime(now.year, now.month - 1, 1).millisecondsSinceEpoch;
        final end = DateTime(now.year, now.month, 0, 23, 59, 59, 999).millisecondsSinceEpoch;
        return (start, end);
      case 'this_year':
        final start = DateTime(now.year, 1, 1).millisecondsSinceEpoch;
        final end = DateTime(now.year, 12, 31, 23, 59, 59, 999).millisecondsSinceEpoch;
        return (start, end);
      case 'custom':
        if (customDateRange.value != null) {
          final s = customDateRange.value!.start;
          final e = customDateRange.value!.end;
          final start = DateTime(s.year, s.month, s.day).millisecondsSinceEpoch;
          final end = DateTime(e.year, e.month, e.day, 23, 59, 59, 999).millisecondsSinceEpoch;
          return (start, end);
        }
        return (null, null);
      case 'all':
      default:
        return (null, null);
    }
  }

  Future<void> calculateMetrics(String businessId) async {
    final range = _getFilterRange();
    final res = await _dbService.businessDao.calculateMetrics(
      businessId,
      startDate: range.$1,
      endDate: range.$2,
    );
    currentMetrics.value = res;

    final catSales = await _dbService.businessDao.getCategoryWiseSales(
      businessId,
      startDate: range.$1,
      endDate: range.$2,
    );
    categorySales.value = catSales;

    final top = await _dbService.businessDao.getTopSellingProducts(
      businessId,
      startDate: range.$1,
      endDate: range.$2,
    );
    topProducts.value = top;
  }

  Future<void> loadRecentTransactions(String businessId) async {
    final sales = await _dbService.businessDao.getSales(businessId);
    recentSales.value = sales.take(5).toList();

    final purchases = await _dbService.businessDao.getPurchases(businessId);
    recentPurchases.value = purchases.take(5).toList();

    final expenses = await (_dbService.database.select(_dbService.database.transactions)
          ..where((t) =>
              t.businessId.equals(businessId) &
              t.transactionType.equals('expense') &
              t.deletedAt.isNull() &
              (t.sourceType.isNull() | t.sourceType.equals('manual')))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(5))
        .get();
    recentExpenses.value = expenses;
  }

  Future<void> checkCashSession(String businessId) async {
    final session = await _dbService.businessDao.getOpenCashSession(businessId);
    activeCashSession.value = session;
  }

  Future<bool> saveBusiness() async {
    if (nameController.text.trim().isEmpty) {
      AppSnackbar.error('ব্যবসার নাম লিখুন');
      return false;
    }

    final capital = CurrencyUtils.takaToMinor(initialCapitalController.text);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final newId = _uuid.v4();

    try {
      await _dbService.businessDao.insertBusiness(
        BusinessesCompanion(
          id: Value(newId),
          name: Value(nameController.text.trim()),
          businessType: Value(selectedType.value),
          description: Value(descriptionController.text.trim()),
          openingDate: Value(now),
          initialCapitalMinor: Value(capital),
          location: Value(locationController.text.trim()),
          phone: Value(phoneController.text.trim()),
          currency: const Value('BDT'),
          timeFormat: const Value('12h'),
          allowNegativeStock: const Value(0),
          costingMethod: const Value('fifo'),
          status: const Value('active'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final created = await _dbService.businessDao.getBusinessById(newId);
      if (created != null) {
        await _activeBizService.switchBusiness(created);
      }

      AppSnackbar.success('ব্যবসা সফলভাবে যুক্ত হয়েছে');
      nameController.clear();
      initialCapitalController.clear();
      locationController.clear();
      phoneController.clear();
      descriptionController.clear();
      return true;
    } catch (e) {
      AppSnackbar.error('ত্রুটি: $e');
      return false;
    }
  }

  Future<bool> updateSettings() async {
    if (selectedBusiness.value == null) return false;
    if (settingsNameController.text.trim().isEmpty) {
      AppSnackbar.error('ব্যবসার নাম লিখুন');
      return false;
    }

    try {
      await _dbService.businessDao.updateBusinessSettings(
        selectedBusiness.value!.id,
        name: settingsNameController.text.trim(),
        businessType: settingsType.value,
        location: settingsLocationController.text.trim(),
        phone: settingsPhoneController.text.trim(),
        description: settingsDescriptionController.text.trim(),
        timeFormat: settingsTimeFormat.value,
        allowNegativeStock: settingsAllowNegativeStock.value ? 1 : 0,
      );

      AppSnackbar.success('ব্যবসার সেটিংস আপডেট করা হয়েছে');
      final updated = await _dbService.businessDao.getBusinessById(selectedBusiness.value!.id);
      if (updated != null) {
        await _activeBizService.switchBusiness(updated);
      }
      return true;
    } catch (e) {
      AppSnackbar.error('ত্রুটি: $e');
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
    settingsNameController.dispose();
    settingsLocationController.dispose();
    settingsPhoneController.dispose();
    settingsDescriptionController.dispose();
    super.onClose();
  }
}
