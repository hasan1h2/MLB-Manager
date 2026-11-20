import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class BudgetWithSpending {
  final Budget budget;
  final int actualSpendingMinor;
  BudgetWithSpending({required this.budget, required this.actualSpendingMinor});

  int get remainingMinor {
    final rem = budget.limitMinor - actualSpendingMinor;
    return rem < 0 ? 0 : rem;
  }

  double get utilizationPercent {
    if (budget.limitMinor <= 0) return 0.0;
    return (actualSpendingMinor / budget.limitMinor).clamp(0.0, 1.5);
  }

  bool get isOverBudget => actualSpendingMinor > budget.limitMinor;
  bool get isWarning =>
      (actualSpendingMinor / budget.limitMinor * 100) >= budget.alertPercentage;
}

class BudgetController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<BudgetWithSpending> budgetsWithSpending =
      <BudgetWithSpending>[].obs;
  final RxBool isLoading = true.obs;

  // Form Fields
  final nameController = TextEditingController();
  final limitController = TextEditingController();
  final alertPercentController = TextEditingController(text: '80');
  final RxString selectedScope = 'family'.obs; // personal, family, business
  final RxString selectedPeriod = 'monthly'.obs; // monthly, yearly

  @override
  void onInit() {
    super.onInit();
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    try {
      isLoading.value = true;
      final active = await _dbService.budgetDao.getActiveBudgets();
      final list = <BudgetWithSpending>[];
      for (var b in active) {
        final spending =
            await _dbService.budgetDao.getActualSpendingForBudget(b);
        list.add(BudgetWithSpending(budget: b, actualSpendingMinor: spending));
      }
      budgetsWithSpending.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveBudget() async {
    if (nameController.text.trim().isEmpty) return false;
    final limit = CurrencyUtils.takaToMinor(limitController.text);
    if (limit <= 0) return false;

    final alert = int.tryParse(alertPercentController.text) ?? 80;
    final now = DateTime.now();
    final start =
        DateTime(now.year, now.month, 1).toUtc().millisecondsSinceEpoch;
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59)
        .toUtc()
        .millisecondsSinceEpoch;

    await _dbService.budgetDao.insertBudget(
      BudgetsCompanion(
        id: Value(_uuid.v4()),
        name: Value(nameController.text.trim()),
        scopeType: Value(selectedScope.value),
        periodType: Value(selectedPeriod.value),
        startDate: Value(start),
        endDate: Value(end),
        limitMinor: Value(limit),
        alertPercentage: Value(alert),
        status: const Value('active'),
      ),
    );

    nameController.clear();
    limitController.clear();
    await loadBudgets();
    AppSnackbar.success('বাজেট সফলভাবে সংরক্ষিত হয়েছে');
    return true;
  }

  @override
  void onClose() {
    nameController.dispose();
    limitController.dispose();
    alertPercentController.dispose();
    super.onClose();
  }
}
