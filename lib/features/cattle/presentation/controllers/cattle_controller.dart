import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/cattle_dao.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class CattleController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<CattleData> cattleList = <CattleData>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<String?> activeBusinessId = Rx<String?>(null);

  // Selected Cattle Details & Calculation
  final Rx<CattleData?> selectedCattle = Rx<CattleData?>(null);
  final Rx<CattleProfitCalculation?> selectedProfit = Rx<CattleProfitCalculation?>(null);
  final RxList<CattleExpense> selectedCattleExpenses = <CattleExpense>[].obs;

  // Form Fields for Add Cattle
  final tagNumberController = TextEditingController();
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final weightController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final sellerController = TextEditingController();
  final RxString selectedGender = 'bull'.obs; // bull, cow, steer, heifer, calf

  // Expense Dialog Fields
  final expenseAmountController = TextEditingController();
  final expenseDescController = TextEditingController();
  final RxString selectedExpenseType = 'feed'.obs;

  // Sale Dialog Fields
  final buyerNameController = TextEditingController();
  final salePriceController = TextEditingController();
  final salePaidController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initCattleBusiness();
  }

  Future<void> initCattleBusiness() async {
    final businesses = await _dbService.businessDao.getAllBusinesses();
    final cattleBiz = businesses.firstWhereOrNull((b) => b.businessType == 'cattle');
    if (cattleBiz != null) {
      activeBusinessId.value = cattleBiz.id;
    } else if (businesses.isNotEmpty) {
      activeBusinessId.value = businesses.first.id;
    }

    if (activeBusinessId.value != null) {
      watchCattle(activeBusinessId.value!);
    } else {
      isLoading.value = false;
    }
  }

  void watchCattle(String businessId) {
    _dbService.cattleDao.watchCattleList(businessId).listen((list) {
      cattleList.value = list;
      isLoading.value = false;
    });
  }

  Future<void> loadCattleDetails(CattleData cattle) async {
    selectedCattle.value = cattle;
    final expenses = await _dbService.cattleDao.getCattleExpenses(cattle.id);
    selectedCattleExpenses.value = expenses;
    final calc = await _dbService.cattleDao.calculateCattleProfit(cattle.id);
    selectedProfit.value = calc;
  }

  Future<bool> saveCattle() async {
    if (tagNumberController.text.trim().isEmpty) {
      AppSnackbar.error('ট্যাগ নম্বর লিখুন');
      return false;
    }

    final priceMinor = CurrencyUtils.takaToMinor(purchasePriceController.text);
    if (priceMinor <= 0) {
      AppSnackbar.error('ক্রয় মূল্য লিখুন');
      return false;
    }

    final bizId = activeBusinessId.value;
    if (bizId == null) {
      AppSnackbar.error('অনুগ্রহ করে আগে একটি ব্যবসা যোগ করুন');
      return false;
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final weight = double.tryParse(weightController.text) ?? 0.0;

    try {
      await _dbService.cattleDao.insertCattle(
        CattleCompanion(
          id: Value(_uuid.v4()),
          businessId: Value(bizId),
          tagNumber: Value(tagNumberController.text.trim()),
          name: Value(nameController.text.trim()),
          breed: Value(breedController.text.trim()),
          gender: Value(selectedGender.value),
          weightKg: Value(weight),
          purchaseDate: Value(now),
          purchasePriceMinor: Value(priceMinor),
          status: const Value('active'),
          createdAt: Value(now),
        ),
      );

      AppSnackbar.success('গরু সফলভাবে নিবন্ধন করা হয়েছে');
      tagNumberController.clear();
      nameController.clear();
      breedController.clear();
      weightController.clear();
      purchasePriceController.clear();
      return true;
    } catch (e) {
      AppSnackbar.error('Error: $e');
      return false;
    }
  }

  Future<void> addExpense(String cattleId) async {
    final amount = CurrencyUtils.takaToMinor(expenseAmountController.text);
    if (amount <= 0) return;

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _dbService.cattleDao.insertCattleExpense(
      CattleExpensesCompanion(
        id: Value(_uuid.v4()),
        cattleId: Value(cattleId),
        expenseType: Value(selectedExpenseType.value),
        amountMinor: Value(amount),
        expenseDate: Value(now),
        description: Value(expenseDescController.text.trim()),
      ),
    );

    expenseAmountController.clear();
    expenseDescController.clear();
    if (selectedCattle.value != null) {
      await loadCattleDetails(selectedCattle.value!);
    }
    AppSnackbar.success('খরচ সফলভাবে যোগ করা হয়েছে');
  }

  Future<bool> recordSale(String cattleId) async {
    final salePrice = CurrencyUtils.takaToMinor(salePriceController.text);
    if (salePrice <= 0 || buyerNameController.text.trim().isEmpty) {
      AppSnackbar.error('ক্রেতার নাম ও বিক্রয় মূল্য লিখুন');
      return false;
    }

    final paid = salePaidController.text.trim().isNotEmpty
        ? CurrencyUtils.takaToMinor(salePaidController.text)
        : salePrice;
    final due = salePrice - paid;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    await _dbService.cattleDao.recordCattleSale(
      sale: CattleSalesCompanion(
        id: Value(_uuid.v4()),
        cattleId: Value(cattleId),
        buyerName: Value(buyerNameController.text.trim()),
        saleDate: Value(now),
        salePriceMinor: Value(salePrice),
        paidMinor: Value(paid),
        dueMinor: Value(due < 0 ? 0 : due),
      ),
    );

    buyerNameController.clear();
    salePriceController.clear();
    salePaidController.clear();
    if (selectedCattle.value != null) {
      final updated = await _dbService.cattleDao.getCattleById(cattleId);
      if (updated != null) {
        await loadCattleDetails(updated);
      }
    }
    AppSnackbar.success('গরু বিক্রয় সম্পন্ন হয়েছে');
    return true;
  }

  @override
  void onClose() {
    tagNumberController.dispose();
    nameController.dispose();
    breedController.dispose();
    weightController.dispose();
    purchasePriceController.dispose();
    sellerController.dispose();
    expenseAmountController.dispose();
    expenseDescController.dispose();
    buyerNameController.dispose();
    salePriceController.dispose();
    salePaidController.dispose();
    super.onClose();
  }
}
