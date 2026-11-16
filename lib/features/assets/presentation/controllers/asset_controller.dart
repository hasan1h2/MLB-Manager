import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class AssetController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<Asset> assets = <Asset>[].obs;
  final RxList<SavingsGoal> savingsGoals = <SavingsGoal>[].obs;
  final RxList<Investment> investments = <Investment>[].obs;
  final RxBool isLoading = true.obs;

  // Form Fields - Assets
  final assetNameController = TextEditingController();
  final assetPurchaseValueController = TextEditingController();
  final assetCurrentValueController = TextEditingController();
  final assetLocationController = TextEditingController();
  final assetNotesController = TextEditingController();
  final RxString selectedAssetCategory = 'land'.obs; // land, house, gold, vehicle, cattle, equipment, other

  // Form Fields - Savings
  final goalNameController = TextEditingController();
  final goalTargetAmountController = TextEditingController();
  final goalCurrentAmountController = TextEditingController(text: '0');
  final Rx<DateTime> goalTargetDate = DateTime.now().add(const Duration(days: 365)).obs;

  // Form Fields - Investment
  final investmentNameController = TextEditingController();
  final investmentAmountController = TextEditingController();
  final investmentValueController = TextEditingController();
  final RxString selectedInvestmentType = 'business'.obs; // business, shares, savings_cert, agriculture, other

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void loadAll() {
    _dbService.assetDao.watchAssets().listen((list) => assets.value = list);
    _dbService.assetDao.watchSavingsGoals().listen((list) => savingsGoals.value = list);
    _dbService.assetDao.watchInvestments().listen((list) {
      investments.value = list;
      isLoading.value = false;
    });
  }

  Future<bool> saveAsset() async {
    if (assetNameController.text.trim().isEmpty) return false;
    final purchaseVal = CurrencyUtils.takaToMinor(assetPurchaseValueController.text);
    final currentVal = assetCurrentValueController.text.trim().isNotEmpty
        ? CurrencyUtils.takaToMinor(assetCurrentValueController.text)
        : purchaseVal;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    final members = await _dbService.coreDao.getAllFamilyMembers();
    final ownerId = members.isNotEmpty ? members.first.id : 'default_owner';

    await _dbService.assetDao.insertAsset(
      AssetsCompanion(
        id: Value(_uuid.v4()),
        name: Value(assetNameController.text.trim()),
        category: Value(selectedAssetCategory.value),
        ownerMemberId: Value(ownerId),
        purchaseDate: Value(now),
        purchaseValueMinor: Value(purchaseVal),
        currentValueMinor: Value(currentVal),
        notes: Value(assetNotesController.text.trim()),
      ),
    );

    assetNameController.clear();
    assetPurchaseValueController.clear();
    assetCurrentValueController.clear();
    AppSnackbar.success('সম্পদ সফলভাবে যুক্ত হয়েছে');
    return true;
  }

  Future<bool> saveSavingsGoal() async {
    if (goalNameController.text.trim().isEmpty) return false;
    final target = CurrencyUtils.takaToMinor(goalTargetAmountController.text);
    final current = CurrencyUtils.takaToMinor(goalCurrentAmountController.text);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final targetMs = goalTargetDate.value.toUtc().millisecondsSinceEpoch;

    await _dbService.assetDao.insertSavingsGoal(
      SavingsGoalsCompanion(
        id: Value(_uuid.v4()),
        name: Value(goalNameController.text.trim()),
        targetAmountMinor: Value(target),
        currentAmountMinor: Value(current),
        startDate: Value(now),
        targetDate: Value(targetMs),
      ),
    );

    goalNameController.clear();
    goalTargetAmountController.clear();
    goalCurrentAmountController.clear();
    AppSnackbar.success('সঞ্চয় লক্ষ্য সফলভাবে যুক্ত হয়েছে');
    return true;
  }

  Future<bool> saveInvestment() async {
    if (investmentNameController.text.trim().isEmpty) return false;
    final amount = CurrencyUtils.takaToMinor(investmentAmountController.text);
    final value = investmentValueController.text.trim().isNotEmpty
        ? CurrencyUtils.takaToMinor(investmentValueController.text)
        : amount;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    await _dbService.assetDao.insertInvestment(
      InvestmentsCompanion(
        id: Value(_uuid.v4()),
        name: Value(investmentNameController.text.trim()),
        investmentType: Value(selectedInvestmentType.value),
        initialAmountMinor: Value(amount),
        currentValueMinor: Value(value),
        investmentDate: Value(now),
      ),
    );

    investmentNameController.clear();
    investmentAmountController.clear();
    investmentValueController.clear();
    AppSnackbar.success('বিনিয়োগ সফলভাবে যুক্ত হয়েছে');
    return true;
  }

  @override
  void onClose() {
    assetNameController.dispose();
    assetPurchaseValueController.dispose();
    assetCurrentValueController.dispose();
    assetLocationController.dispose();
    assetNotesController.dispose();
    goalNameController.dispose();
    goalTargetAmountController.dispose();
    goalCurrentAmountController.dispose();
    investmentNameController.dispose();
    investmentAmountController.dispose();
    investmentValueController.dispose();
    super.onClose();
  }
}
