import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/active_business_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class CustomerWithDue {
  final Customer customer;
  final int dueMinor;
  CustomerWithDue({required this.customer, required this.dueMinor});
}

class SupplierWithPayable {
  final Supplier supplier;
  final int payableMinor;
  SupplierWithPayable({required this.supplier, required this.payableMinor});
}

class PartyController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ActiveBusinessService _activeBizService = Get.find<ActiveBusinessService>();
  final _uuid = const Uuid();

  final RxList<CustomerWithDue> customersWithDue = <CustomerWithDue>[].obs;
  final RxList<SupplierWithPayable> suppliersWithPayable =
      <SupplierWithPayable>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<String?> activeBusinessId = Rx<String?>(null);

  // Form Fields for Add Customer / Supplier
  final nameController = TextEditingController();
  final companyController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final openingBalanceController = TextEditingController(text: '0');
  final creditLimitController = TextEditingController(text: '0');
  final notesController = TextEditingController();
  final RxString selectedCustomerType = 'retail'.obs; // retail, wholesale

  // Payment Recording
  final paymentAmountController = TextEditingController();
  final paymentNotesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // React to active business change
    ever(_activeBizService.activeBusiness, (BusinessesData? b) {
      activeBusinessId.value = b?.id;
      if (b != null) {
        loadParties();
      } else {
        customersWithDue.clear();
        suppliersWithPayable.clear();
      }
    });

    final current = _activeBizService.activeBusiness.value;
    if (current != null) {
      activeBusinessId.value = current.id;
      loadParties();
    } else {
      isLoading.value = false;
    }
  }

  Future<void> loadParties() async {
    final bizId = activeBusinessId.value;
    if (bizId == null) {
      customersWithDue.clear();
      suppliersWithPayable.clear();
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;

      // Customers
      final custs = await _dbService.businessDao.getAllCustomers(bizId);
      final custList = <CustomerWithDue>[];
      for (var c in custs) {
        final due =
            await _dbService.businessDao.getCustomerOutstandingDue(c.id);
        custList.add(CustomerWithDue(customer: c, dueMinor: due));
      }
      customersWithDue.value = custList;

      // Suppliers
      final supps = await _dbService.businessDao.getAllSuppliers(bizId);
      final suppList = <SupplierWithPayable>[];
      for (var s in supps) {
        final payable =
            await _dbService.businessDao.getSupplierOutstandingPayable(s.id);
        suppList.add(SupplierWithPayable(supplier: s, payableMinor: payable));
      }
      suppliersWithPayable.value = suppList;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveCustomer() async {
    final bizId = activeBusinessId.value;
    if (bizId == null) {
      AppSnackbar.error('কোন সক্রিয় ব্যবসা নির্বাচন করা নেই');
      return false;
    }

    if (nameController.text.trim().isEmpty) {
      AppSnackbar.error('নাম লিখুন');
      return false;
    }

    final openingMinor =
        CurrencyUtils.takaToMinor(openingBalanceController.text);
    final creditLimitMinor =
        CurrencyUtils.takaToMinor(creditLimitController.text);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    try {
      await _dbService.businessDao.insertCustomer(
        CustomersCompanion(
          id: Value(_uuid.v4()),
          businessId: Value(bizId),
          name: Value(nameController.text.trim()),
          company: Value(companyController.text.trim().isNotEmpty
              ? companyController.text.trim()
              : null),
          customerType: Value(selectedCustomerType.value),
          phone: Value(phoneController.text.trim().isNotEmpty
              ? phoneController.text.trim()
              : null),
          address: Value(addressController.text.trim().isNotEmpty
              ? addressController.text.trim()
              : null),
          openingBalanceMinor: Value(openingMinor),
          creditLimitMinor: Value(creditLimitMinor),
          notes: Value(notesController.text.trim().isNotEmpty
              ? notesController.text.trim()
              : null),
          createdAt: Value(now),
        ),
      );

      AppSnackbar.success('কাস্টমার সফলভাবে যোগ করা হয়েছে');
      _clearForm();
      await loadParties();
      return true;
    } catch (e) {
      AppSnackbar.error('Error: $e');
      return false;
    }
  }

  Future<bool> saveSupplier() async {
    final bizId = activeBusinessId.value;
    if (bizId == null) {
      AppSnackbar.error('কোন সক্রিয় ব্যবসা নির্বাচন করা নেই');
      return false;
    }

    if (nameController.text.trim().isEmpty) {
      AppSnackbar.error('নাম লিখুন');
      return false;
    }

    final openingMinor =
        CurrencyUtils.takaToMinor(openingBalanceController.text);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    try {
      await _dbService.businessDao.insertSupplier(
        SuppliersCompanion(
          id: Value(_uuid.v4()),
          businessId: Value(bizId),
          name: Value(nameController.text.trim()),
          company: Value(companyController.text.trim().isNotEmpty
              ? companyController.text.trim()
              : null),
          phone: Value(phoneController.text.trim().isNotEmpty
              ? phoneController.text.trim()
              : null),
          address: Value(addressController.text.trim().isNotEmpty
              ? addressController.text.trim()
              : null),
          openingBalanceMinor: Value(openingMinor),
          notes: Value(notesController.text.trim().isNotEmpty
              ? notesController.text.trim()
              : null),
          createdAt: Value(now),
        ),
      );

      AppSnackbar.success('সাপ্লায়ার সফলভাবে যোগ করা হয়েছে');
      _clearForm();
      await loadParties();
      return true;
    } catch (e) {
      AppSnackbar.error('Error: $e');
      return false;
    }
  }

  Future<void> recordPayment(
      {required String partyType, required String partyId}) async {
    final bizId = activeBusinessId.value;
    if (bizId == null) return;

    final amount = CurrencyUtils.takaToMinor(paymentAmountController.text);
    if (amount <= 0) {
      AppSnackbar.validation('সঠিক পেমেন্টের পরিমাণ লিখুন');
      return;
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _dbService.businessDao.insertPartyPayment(
      PartyPaymentsCompanion(
        id: Value(_uuid.v4()),
        partyType: Value(partyType),
        partyId: Value(partyId),
        businessId: Value(bizId),
        amountMinor: Value(amount),
        paymentDate: Value(now),
        notes: Value(paymentNotesController.text.trim()),
      ),
    );

    paymentAmountController.clear();
    paymentNotesController.clear();
    await loadParties();
    AppSnackbar.success('পেমেন্ট সফলভাবে সংরক্ষিত হয়েছে');
  }

  void _clearForm() {
    nameController.clear();
    companyController.clear();
    phoneController.clear();
    addressController.clear();
    openingBalanceController.text = '0';
    creditLimitController.text = '0';
    notesController.clear();
    selectedCustomerType.value = 'retail';
  }

  @override
  void onClose() {
    nameController.dispose();
    companyController.dispose();
    phoneController.dispose();
    addressController.dispose();
    openingBalanceController.dispose();
    creditLimitController.dispose();
    notesController.dispose();
    paymentAmountController.dispose();
    paymentNotesController.dispose();
    super.onClose();
  }
}
