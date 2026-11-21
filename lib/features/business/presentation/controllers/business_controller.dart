import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/business_dao.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class BusinessController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<BusinessesData> businesses = <BusinessesData>[].obs;
  final RxBool isLoading = true.obs;

  // Selected Business Dashboard Metrics
  final Rx<BusinessesData?> selectedBusiness = Rx<BusinessesData?>(null);
  final Rx<BusinessMetricsResult?> currentMetrics =
      Rx<BusinessMetricsResult?>(null);

  // Filter Chip for Dashboard: 'today', 'last_7_days', 'this_month', 'this_year', 'all'
  final RxString selectedPeriod = 'this_month'.obs;

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
      } else if (selectedBusiness.value != null) {
        final current = list.firstWhereOrNull((b) => b.id == selectedBusiness.value!.id);
        if (current != null) {
          selectedBusiness.value = current;
          calculateMetrics(current.id);
        }
      }
    });
  }

  Future<void> selectBusinessForDashboard(BusinessesData business) async {
    selectedBusiness.value = business;
    _populateSettingsForm(business);
    await calculateMetrics(business.id);
    await loadRecentTransactions(business.id);
    await checkCashSession(business.id);
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
  }

  Future<void> loadRecentTransactions(String businessId) async {
    final sales = await _dbService.businessDao.getSales(businessId);
    recentSales.value = sales.take(5).toList();

    final purchases = await _dbService.businessDao.getPurchases(businessId);
    recentPurchases.value = purchases.take(5).toList();
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
          currency: const Value('BDT'),
          timeFormat: const Value('12h'),
          allowNegativeStock: const Value(0),
          costingMethod: const Value('fifo'),
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
        selectedBusiness.value = updated;
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
