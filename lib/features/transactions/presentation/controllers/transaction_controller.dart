import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class TransactionController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  // Observable state
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Account> accounts = <Account>[].obs;
  final RxList<FamilyMember> members = <FamilyMember>[].obs;
  final RxList<BusinessesData> businesses = <BusinessesData>[].obs;

  final RxString selectedTypeFilter = 'all'.obs;
  final RxString selectedScopeFilter = 'all'.obs;
  final RxBool isLoading = true.obs;

  // Form Fields
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString transactionType = 'expense'.obs; // income, expense, transfer
  final RxString scopeType = 'personal'.obs; // personal, family, business
  final Rx<String?> selectedCategoryId = Rx<String?>(null);
  final Rx<String?> selectedAccountId = Rx<String?>(null);
  final Rx<String?> toAccountId = Rx<String?>(null);
  final Rx<String?> selectedMemberId = Rx<String?>(null);
  final Rx<String?> selectedBusinessId = Rx<String?>(null);
  final Rx<DateTime> transactionDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadDependencies();
  }

  void loadDependencies() {
    // Watch transactions
    _dbService.coreDao.watchTransactions(limit: 100).listen((list) {
      transactions.value = list;
      isLoading.value = false;
    });

    // Watch accounts
    _dbService.coreDao.watchAccounts().listen((list) {
      accounts.value = list;
      if (selectedAccountId.value == null && list.isNotEmpty) {
        selectedAccountId.value = list.first.id;
      }
    });

    // Watch categories
    _dbService.coreDao.watchCategories().listen((list) {
      categories.value = list;
    });

    // Watch family members
    _dbService.coreDao.watchFamilyMembers().listen((list) {
      members.value = list;
    });

    // Watch businesses
    _dbService.businessDao.watchBusinesses().listen((list) {
      businesses.value = list;
    });
  }

  List<Transaction> get filteredTransactions {
    return transactions.where((tx) {
      if (selectedTypeFilter.value != 'all' && tx.transactionType != selectedTypeFilter.value) {
        return false;
      }
      if (selectedScopeFilter.value != 'all' && tx.scopeType != selectedScopeFilter.value) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Category> get categoriesForCurrentType {
    if (transactionType.value == 'transfer') return [];
    return categories.where((c) => c.categoryType == transactionType.value).toList();
  }

  Future<bool> saveTransaction() async {
    final amountMinor = CurrencyUtils.takaToMinor(amountController.text);
    if (amountMinor <= 0) {
      AppSnackbar.error('must_be_positive'.tr);
      return false;
    }

    if (selectedAccountId.value == null) {
      AppSnackbar.error('select_account'.tr);
      return false;
    }

    if (transactionType.value == 'transfer') {
      if (toAccountId.value == null || toAccountId.value == selectedAccountId.value) {
        AppSnackbar.error('Please select different destination account');
        return false;
      }
    } else {
      if (selectedCategoryId.value == null && categoriesForCurrentType.isNotEmpty) {
        selectedCategoryId.value = categoriesForCurrentType.first.id;
      }
    }

    try {
      final txId = _uuid.v4();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final txDateMs = transactionDate.value.toUtc().millisecondsSinceEpoch;
      final txNumber = 'TX-${now.toString().substring(5)}';

      final txCompanion = TransactionsCompanion(
        id: Value(txId),
        transactionNumber: Value(txNumber),
        transactionType: Value(transactionType.value),
        scopeType: Value(scopeType.value),
        familyMemberId: Value(selectedMemberId.value),
        businessId: Value(scopeType.value == 'business' ? selectedBusinessId.value : null),
        categoryId: Value(selectedCategoryId.value),
        accountId: Value(selectedAccountId.value),
        amountMinor: Value(amountMinor),
        transactionDate: Value(txDateMs),
        description: Value(descriptionController.text.trim()),
        paymentStatus: const Value('paid'),
        sourceType: const Value('manual'),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      final entries = <TransactionEntriesCompanion>[];

      if (transactionType.value == 'income') {
        // Double-entry: Debit account (Asset increases) by amountMinor, Credit income entry by amountMinor
        entries.add(
          TransactionEntriesCompanion(
            id: Value(_uuid.v4()),
            transactionId: Value(txId),
            accountId: Value(selectedAccountId.value!),
            debitMinor: const Value(0),
            creditMinor: Value(amountMinor), // Inflow to account
            createdAt: Value(now),
          ),
        );
        // Balancing entry
        entries.add(
          TransactionEntriesCompanion(
            id: Value(_uuid.v4()),
            transactionId: Value(txId),
            accountId: Value(selectedAccountId.value!),
            debitMinor: Value(amountMinor),
            creditMinor: const Value(0),
            createdAt: Value(now),
          ),
        );
      } else if (transactionType.value == 'expense') {
        // Double-entry: Debit expense, Credit account (Asset decreases)
        entries.add(
          TransactionEntriesCompanion(
            id: Value(_uuid.v4()),
            transactionId: Value(txId),
            accountId: Value(selectedAccountId.value!),
            debitMinor: Value(amountMinor), // Outflow from account
            creditMinor: const Value(0),
            createdAt: Value(now),
          ),
        );
        entries.add(
          TransactionEntriesCompanion(
            id: Value(_uuid.v4()),
            transactionId: Value(txId),
            accountId: Value(selectedAccountId.value!),
            debitMinor: const Value(0),
            creditMinor: Value(amountMinor),
            createdAt: Value(now),
          ),
        );
      } else if (transactionType.value == 'transfer') {
        // Internal transfer: From account debited (outflow), To account credited (inflow)
        entries.add(
          TransactionEntriesCompanion(
            id: Value(_uuid.v4()),
            transactionId: Value(txId),
            accountId: Value(selectedAccountId.value!),
            debitMinor: Value(amountMinor),
            creditMinor: const Value(0),
            createdAt: Value(now),
          ),
        );
        entries.add(
          TransactionEntriesCompanion(
            id: Value(_uuid.v4()),
            transactionId: Value(txId),
            accountId: Value(toAccountId.value!),
            debitMinor: const Value(0),
            creditMinor: Value(amountMinor),
            createdAt: Value(now),
          ),
        );
      }

      await _dbService.coreDao.postTransaction(
        transaction: txCompanion,
        entries: entries,
      );

      AppSnackbar.success('transaction_saved'.tr);
      resetForm();
      return true;
    } catch (e) {
      AppSnackbar.error('Error saving transaction: $e');
      return false;
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _dbService.coreDao.softDeleteTransaction(id);
    AppSnackbar.info('Transaction deleted');
  }

  void resetForm() {
    amountController.clear();
    descriptionController.clear();
    transactionDate.value = DateTime.now();
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
