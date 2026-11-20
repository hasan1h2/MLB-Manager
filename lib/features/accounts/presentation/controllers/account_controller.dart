import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class AccountItemWithBalance {
  final Account account;
  final int balanceMinor;
  AccountItemWithBalance({required this.account, required this.balanceMinor});
}

class AccountController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<AccountItemWithBalance> accountsWithBalance =
      <AccountItemWithBalance>[].obs;
  final RxBool isLoading = true.obs;

  // Form fields
  final nameController = TextEditingController();
  final openingBalanceController = TextEditingController();
  final RxString selectedType =
      'bank'.obs; // cash, bank, bkash, nagad, rocket, other_wallet, custom

  @override
  void onInit() {
    super.onInit();
    loadAccountsWithBalances();
  }

  Future<void> loadAccountsWithBalances() async {
    try {
      isLoading.value = true;
      final accounts = await _dbService.coreDao.getAllAccounts();
      final list = <AccountItemWithBalance>[];
      for (var acc in accounts) {
        final bal = await _dbService.coreDao.getAccountBalance(acc.id);
        list.add(AccountItemWithBalance(account: acc, balanceMinor: bal));
      }
      accountsWithBalance.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveAccount() async {
    if (nameController.text.trim().isEmpty) {
      AppSnackbar.error('হিসাবের নাম লিখুন');
      return false;
    }

    final openingMinor =
        CurrencyUtils.takaToMinor(openingBalanceController.text);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    try {
      await _dbService.coreDao.insertAccount(
        AccountsCompanion(
          id: Value(_uuid.v4()),
          name: Value(nameController.text.trim()),
          accountType: Value(selectedType.value),
          openingBalanceMinor: Value(openingMinor),
          isActive: const Value(1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      AppSnackbar.success('হিসাব সফলভাবে তৈরি হয়েছে');
      nameController.clear();
      openingBalanceController.clear();
      await loadAccountsWithBalances();
      return true;
    } catch (e) {
      AppSnackbar.error('Error: $e');
      return false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    openingBalanceController.dispose();
    super.onClose();
  }
}
