import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class LoanWithRemaining {
  final LoanAccount loan;
  final int remainingPrincipalMinor;
  LoanWithRemaining({required this.loan, required this.remainingPrincipalMinor});
}

class LoanController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<LoanWithRemaining> loans = <LoanWithRemaining>[].obs;
  final RxList<LoanPayment> selectedLoanPayments = <LoanPayment>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedTypeFilter = 'receivable'.obs; // receivable, payable

  // Form Fields
  final partyNameController = TextEditingController();
  final phoneController = TextEditingController();
  final principalController = TextEditingController();
  final notesController = TextEditingController();
  final RxString loanType = 'receivable'.obs;
  final Rx<DateTime> dueDate = DateTime.now().add(const Duration(days: 30)).obs;

  // Payment Form Fields
  final paymentAmountController = TextEditingController();
  final paymentNotesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    watchLoans();
  }

  void watchLoans() {
    _dbService.loanDao.watchLoans().listen((_) async {
      await loadLoans();
    });
  }

  Future<void> loadLoans() async {
    try {
      isLoading.value = true;
      final list = await _dbService.loanDao.getLoans(loanType: selectedTypeFilter.value);
      final withRemaining = <LoanWithRemaining>[];
      for (var l in list) {
        final rem = await _dbService.loanDao.getLoanRemainingPrincipal(l.id);
        withRemaining.add(LoanWithRemaining(loan: l, remainingPrincipalMinor: rem));
      }
      loans.value = withRemaining;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setTypeFilter(String type) async {
    selectedTypeFilter.value = type;
    await loadLoans();
  }

  Future<void> loadLoanPayments(String loanId) async {
    final list = await _dbService.loanDao.getLoanPayments(loanId);
    selectedLoanPayments.value = list;
  }

  Future<bool> saveLoan() async {
    if (partyNameController.text.trim().isEmpty) {
      AppSnackbar.error('ব্যক্তির নাম লিখুন');
      return false;
    }

    final principal = CurrencyUtils.takaToMinor(principalController.text);
    if (principal <= 0) {
      AppSnackbar.error('মূল টাকার পরিমাণ লিখুন');
      return false;
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final dueMs = dueDate.value.toUtc().millisecondsSinceEpoch;

    try {
      await _dbService.loanDao.insertLoan(
        LoanAccountsCompanion(
          id: Value(_uuid.v4()),
          partyName: Value(partyNameController.text.trim()),
          phone: Value(phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null),
          loanType: Value(loanType.value),
          principalMinor: Value(principal),
          interestRate: const Value(0.0),
          startDate: Value(now),
          dueDate: Value(dueMs),
          status: const Value('active'),
          notes: Value(notesController.text.trim()),
        ),
      );

      AppSnackbar.success('ঋণ রেকর্ড সফলভাবে যুক্ত হয়েছে');
      partyNameController.clear();
      phoneController.clear();
      principalController.clear();
      notesController.clear();
      await loadLoans();
      return true;
    } catch (e) {
      AppSnackbar.error('Error: $e');
      return false;
    }
  }

  Future<void> recordPayment(String loanId) async {
    final amount = CurrencyUtils.takaToMinor(paymentAmountController.text);
    if (amount <= 0) return;

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _dbService.loanDao.recordLoanPayment(
      payment: LoanPaymentsCompanion(
        id: Value(_uuid.v4()),
        loanId: Value(loanId),
        principalPaidMinor: Value(amount),
        interestPaidMinor: const Value(0),
        paymentDate: Value(now),
        notes: Value(paymentNotesController.text.trim()),
      ),
    );

    paymentAmountController.clear();
    paymentNotesController.clear();
    await loadLoanPayments(loanId);
    await loadLoans();
    AppSnackbar.success('পরিশোধ সফলভাবে সংরক্ষিত হয়েছে');
  }

  @override
  void onClose() {
    partyNameController.dispose();
    phoneController.dispose();
    principalController.dispose();
    notesController.dispose();
    paymentAmountController.dispose();
    paymentNotesController.dispose();
    super.onClose();
  }
}
