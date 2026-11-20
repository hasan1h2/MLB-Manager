import 'package:drift/drift.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../database/daos/core_dao.dart';
import '../database/daos/household_dao.dart';
import '../database/daos/business_dao.dart';
import '../database/daos/inventory_dao.dart';
import '../database/daos/cattle_dao.dart';
import '../database/daos/loan_dao.dart';
import '../database/daos/asset_dao.dart';
import '../database/daos/budget_dao.dart';

class DatabaseService extends GetxService {
  late final AppDatabase database;
  late final CoreDao coreDao;
  late final HouseholdDao householdDao;
  late final BusinessDao businessDao;
  late final InventoryDao inventoryDao;
  late final CattleDao cattleDao;
  late final LoanDao loanDao;
  late final AssetDao assetDao;
  late final BudgetDao budgetDao;

  final _uuid = const Uuid();

  Future<DatabaseService> init({AppDatabase? customDb}) async {
    database = customDb ?? AppDatabase();
    coreDao = CoreDao(database);
    householdDao = HouseholdDao(database);
    businessDao = BusinessDao(database);
    inventoryDao = InventoryDao(database);
    cattleDao = CattleDao(database);
    loanDao = LoanDao(database);
    assetDao = AssetDao(database);
    budgetDao = BudgetDao(database);

    await _seedDefaultCategoriesAndAccounts();
    return this;
  }

  Future<void> _seedDefaultCategoriesAndAccounts() async {
    final existingCategories = await coreDao.getAllCategories();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    if (existingCategories.isEmpty) {
      // Income categories
      final incomeCategories = [
        {'bn': 'বেতন', 'en': 'Salary', 'icon': 'payments'},
        {'bn': 'ফ্রিল্যান্সিং', 'en': 'Freelancing', 'icon': 'computer'},
        {'bn': 'ব্যবসায়িক আয়', 'en': 'Business Income', 'icon': 'storefront'},
        {'bn': 'ভাড়া আয়', 'en': 'Rental Income', 'icon': 'apartment'},
        {'bn': 'কৃষি আয়', 'en': 'Agriculture Income', 'icon': 'agriculture'},
        {'bn': 'সেবামূলক আয়', 'en': 'Service Income', 'icon': 'build'},
        {
          'bn': 'বিনিয়োগের মুনাফা',
          'en': 'Investment Return',
          'icon': 'trending_up'
        },
        {'bn': 'উপহার', 'en': 'Gifts', 'icon': 'card_giftcard'},
        {'bn': 'অন্যান্য আয়', 'en': 'Other Income', 'icon': 'more_horiz'},
      ];

      for (var cat in incomeCategories) {
        await coreDao.insertCategory(
          CategoriesCompanion(
            id: Value(_uuid.v4()),
            nameBn: Value(cat['bn']!),
            nameEn: Value(cat['en']!),
            categoryType: const Value('income'),
            scope: const Value('both'),
            icon: Value(cat['icon']),
            isSystem: const Value(1),
            createdAt: Value(now),
          ),
        );
      }

      // Expense categories
      final expenseCategories = [
        {
          'bn': 'ব্যক্তিগত কেনাকাটা',
          'en': 'Personal Shopping',
          'icon': 'shopping_bag'
        },
        {
          'bn': 'খাবার ও রেস্তোরাঁ',
          'en': 'Food & Dining',
          'icon': 'restaurant'
        },
        {'bn': 'পোশাক', 'en': 'Clothing', 'icon': 'checkroom'},
        {'bn': 'যাতায়াত ও ভাড়া', 'en': 'Transport', 'icon': 'directions_bus'},
        {'bn': 'চিকিৎসা ও ওষুধ', 'en': 'Healthcare', 'icon': 'local_hospital'},
        {'bn': 'শিক্ষা', 'en': 'Education', 'icon': 'school'},
        {'bn': 'বিনোদন', 'en': 'Entertainment', 'icon': 'sports_esports'},
        {'bn': 'মোবাইল ও ইন্টারনেট', 'en': 'Mobile & Internet', 'icon': 'wifi'},
        {'bn': 'ভ্রমণ', 'en': 'Travel', 'icon': 'flight'},
        {
          'bn': 'বাজার ও গ্রোসারি',
          'en': 'Household Grocery',
          'icon': 'shopping_cart'
        },
        {'bn': 'ইউটিলিটি ও বিল', 'en': 'Utilities & Bills', 'icon': 'receipt'},
        {'bn': 'অন্যান্য ব্যয়', 'en': 'Other Expenses', 'icon': 'more_horiz'},
      ];

      for (var cat in expenseCategories) {
        await coreDao.insertCategory(
          CategoriesCompanion(
            id: Value(_uuid.v4()),
            nameBn: Value(cat['bn']!),
            nameEn: Value(cat['en']!),
            categoryType: const Value('expense'),
            scope: const Value('both'),
            icon: Value(cat['icon']),
            isSystem: const Value(1),
            createdAt: Value(now),
          ),
        );
      }
    }

    final existingAccounts = await coreDao.getAllAccounts();
    if (existingAccounts.isEmpty) {
      await coreDao.insertAccount(
        AccountsCompanion(
          id: Value(_uuid.v4()),
          name: const Value('নগদ ক্যাশ (Cash)'),
          accountType: const Value('cash'),
          openingBalanceMinor: const Value(0),
          currencyCode: const Value(AppConstants.defaultCurrencyCode),
          isActive: const Value(1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
  }

  @override
  void onClose() {
    database.close();
    super.onClose();
  }
}
